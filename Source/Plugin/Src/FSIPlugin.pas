unit FSIPlugin;

// =============================================================================
// Unit: FSIPlugin
// Description: FSI plugin implementation
//
// Copyright 2023 Robert Di Pardo
//
// This program is free software: you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version
// 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General
// Public License along with this program. If not, see
// <https://www.gnu.org/licenses/>.
// =============================================================================

{$IFNDEF FPC} {$MESSAGE FATAL 'This unit is compatible with FPC only!'} {$ENDIF}
{$mode delphiunicode}

interface

uses
  Interfaces,
  LCLIntf,
  LCLType,
  Forms,
  Graphics,
  NppPlugin,
  FSIHostForm {FrmFSIHost},
  ConfigForm {FrmConfiguration},
  AboutForm {FrmAbout};

type
  TFsiPlugin = class(TNppPlugin)
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetInfo(NppData: TNppData); override;
    procedure BeNotified(msg: PSciNotification); override;
    procedure DoUpdateUI(const Hwnd: HWND; const Updated: Integer); override;
    procedure DoNppnToolbarModification; override;
    procedure DoNppnShutdown; override;

    /// True if the NPPM_CREATELEXER message is defined -- i.e., if the Npp version is >= 8.4.3.
    /// https://github.com/notepad-plus-plus/notepad-plus-plus/commit/f1ed4de78dbe8f5d85f4d199bae2970148cca8ed
    function SupportsILexer: Boolean;
    function GetILexerPtr(const LexerName: string): NativeInt;
    procedure SetILexer(const LexerName: string);

    /// Get the general config directory for all plugins.
    property GetUserConfigDirectory: String read GetPluginsConfigDir;
    /// Get the unique config directory of *this* plugin.
    function GetPluginConfigDirectory: String;
    /// Get the full path of the buffer with the given ID.
    function GetCurrentBufferPath(BuffrN: NativeUInt = 0): String;
    /// Get the extension of the buffer with the given ID.
    function GetCurrentFileExt(BuffrN: NativeUInt = 0): String;
    /// Get the active selection from the current edit window.
    function GetSelectedText: String;
    /// Register a docked window.
    procedure SendDockDialogMsg(regData: PToolbarData);
    /// Show/hide a plugin dialog.
    procedure ShowDialog(dialogHandle: HWND);
    procedure HideDialog(dialogHandle: HWND);

    { Command menu procedures }
    procedure ToggleFSI; // Toggle the FSI window.
    procedure SendText;  // Send text from NPP to FSI.
    procedure LoadFile; // Call '#load' with the current file name, launching FSI if needed.
    procedure ShowConfig; // Show the plugin configuration form.
    procedure ShowAbout; //  Show the About dialog.

  private
    FSIHostForm: TFrmFSIHost;
    ConfigForm: TFrmConfiguration;
    PluginLoaded: Boolean;

    /// (Dis/en)able the command to evaluate selected text in the FSI console.
    procedure ToggleSendTextCmd(Disable: Boolean = False);
    /// (Dis/en)able command to '#load' current buffer based on file extension.
    procedure ToggleLoadFileCmd(BuffrN: NativeUInt);
  end;

var
  Npp: TFsiPlugin;

implementation

uses
  Windows, SysUtils, Constants, Config;

{$REGION 'C wrappers for command menu procedures'}
procedure _toggleFSI; cdecl;
begin
  Npp.ToggleFSI;
end;

procedure _sendText; cdecl;
begin
  Npp.SendText;
end;

procedure _loadFile; cdecl;
begin
  Npp.LoadFile;
end;

procedure _showConfig; cdecl;
begin
  Npp.ShowConfig;
end;

procedure _showAbout; cdecl;
begin
  Npp.ShowAbout;
end;
{$ENDREGION}

{ ================================================================================================ }
{ TFsiPlugin }

constructor TFsiPlugin.Create;
var
  Id: TFsiCmdID;
  Cmd: PFuncPluginCmd;
  PSk: PShortcutKey;
  Title: String;
begin
  inherited;

  if (not PluginLoaded) then
  begin
    for Id := Low(TFsiCmdID) to High(TFsiCmdID) do begin
      Title := FSI_PLUGIN_MENU_TITLES[Ord(Id)];
      Cmd := Nil; PSk := Nil;
      case Id of
        FSI_INVOKE_CMD_ID: begin
          Cmd := _toggleFSI;
          PSk := MakeShortcutKey(False, True, False, $54);
        end;
        FSI_SEND_TEXT_CMD_ID: begin
          Cmd := _sendText;
          PSk := MakeShortcutKey(False, True, False, VK_RETURN);
        end;
        FSI_LOAD_FILE_CMD_ID: begin
          Cmd := _loadFile;
        end;
        FSI_CONFIG_CMD_ID : Cmd := _showConfig;
        FSI_ABOUT_CMD_ID  : Cmd := _showAbout;
      end;
      AddFuncItem(Title, Cmd, PSk);
    end;
    PluginName := FSI_PLUGIN_NAME;
    PluginLoaded := True;
  end;
end;

destructor TFsiPlugin.Destroy;
begin
  if Assigned(FSIHostForm) then
    FreeAndNil(FSIHostForm);
  if Assigned(ConfigForm) then
    FreeAndNil(ConfigForm);

  PluginLoaded := False;

  inherited;
end;

{ ------------------------------------------------------------------------------------------------ }
{$REGION 'Base plugin overrides'}
procedure TFsiPlugin.SetInfo(NppData: TNppData);
begin
  inherited SetInfo(NppData);
  TLexerProperties.CreateStyler;
end;

procedure TFsiPlugin.BeNotified(msg: PSciNotification);
var
  sciMsg: TSciNotification;
begin
  inherited BeNotified(msg);

  sciMsg := TSciNotification(msg^);
  case sciMsg.nmhdr.code of
    NPPN_DARKMODECHANGED: begin
      if Assigned(FSIHostForm) then
        FSIHostForm.ToggleDarkMode;
    end;
    NPPN_BUFFERACTIVATED, NPPN_LANGCHANGED, NPPN_WORDSTYLESUPDATED: begin
      TLexerProperties.SetLexer;
      if sciMsg.nmhdr.code = NPPN_BUFFERACTIVATED then ToggleLoadFileCmd(sciMsg.nmhdr.idFrom);
    end;
    NPPN_FILERENAMED: begin
      ToggleLoadFileCmd(sciMsg.nmhdr.idFrom);
    end;
  end;
end;

procedure TFsiPlugin.DoNppnToolbarModification;
const
  hNil = THandle(Nil);
var
  tbBmpSource: TPortableNetworkGraphic;
  tbIcons: TToolbarIcons;
  tbIconsDM: TTbIconsDarkMode;
  hHDC: HDC;
  H, W: Integer;
begin
  tbBmpSource := TPortableNetworkGraphic.Create;
  tbBmpSource.HandleType := TBitmapHandleType.bmDDB;
  tbIcons := Default (TToolbarIcons);
  tbIconsDM := Default (TTbIconsDarkMode);
  hHDC := hNil;

  try
    hHDC := GetDC(hNil);
    H := MulDiv(16, GetDeviceCaps(hHDC, LOGPIXELSY), 96);
    W := MulDiv(16, GetDeviceCaps(hHDC, LOGPIXELSX), 96);
    tbBmpSource.LoadFromResourceName(HInstance, 'tbBmpSource');
    try
      tbIcons.ToolbarBmp := CopyImage(tbBmpSource.Handle, IMAGE_BITMAP, W, H, LR_COPYDELETEORG);
    except
      tbIcons.ToolbarBmp := LoadImage(Hinstance, 'tbBmp', IMAGE_BITMAP, 0, 0, 0);
    end;
  finally
    FreeAndNil(tbBmpSource);
    ReleaseDC(hNil, hHDC);
  end;

  tbIcons.ToolbarIcon := LoadImage(Hinstance, 'tbIcon', IMAGE_ICON, 0, 0,
    (LR_DEFAULTSIZE or LR_LOADTRANSPARENT));

  if SupportsDarkMode then begin
    tbIconsDM.ToolbarBmp := tbIcons.ToolbarBmp;
    tbIconsDM.ToolbarIcon := tbIcons.ToolbarIcon;
    tbIconsDM.ToolbarIconDarkMode := LoadImage(Hinstance, 'tbIconDark', IMAGE_ICON,
      0, 0, (LR_DEFAULTSIZE or LR_LOADTRANSPARENT));
  end;

  if tbIconsDM.ToolbarIconDarkMode <> 0 then
    SendNppMessage(NPPM_ADDTOOLBARICON_FORDARKMODE,
      CmdIdFromDlgId(Ord(Low(TFsiCmdID))), @tbIconsDM)
  else begin
    SendNppMessage(NPPM_ADDTOOLBARICON,
      CmdIdFromDlgId(Ord(Low(TFsiCmdID))), @tbIcons)
  end;

  ToggleSendTextCmd(True);
  ToggleLoadFileCmd(0);
end;

procedure TFsiPlugin.DoUpdateUI(const hwnd: HWND; const updated: Integer);
begin
  if SC_UPDATE_SELECTION = (updated and SC_UPDATE_SELECTION) then
    ToggleSendTextCmd;
end;

procedure TFsiPlugin.DoNppnShutdown;
begin
  if Assigned(FSIHostForm) then
    FSIHostForm.Close;
end;
{$ENDREGION}

{ ------------------------------------------------------------------------------------------------ }
{$REGION 'Lexer plugin methods'}
function TFsiPlugin.GetILexerPtr(const LexerName: string): NativeInt;
begin
  Result := SendNppMessage(NPPM_CREATELEXER, 0, PCHAR(LexerName));
end;

procedure TFsiPlugin.SetILexer(const LexerName: string);
begin
  SendMessage(CurrentScintilla, SCI_SETILEXER, 0, GetILexerPtr(LexerName));
end;

function TFsiPlugin.SupportsILexer: Boolean;
var
  NppVersion: Cardinal;
begin
  NppVersion := GetNppVersion;
  Result :=
    (HIWORD(NppVersion) > 8) or
    ((HIWORD(NppVersion) = 8) and
       ((LOWORD(NppVersion) >= 43) and (not (LOWORD(NppVersion) in [191, 192, 193]))));
end;
{$ENDREGION}

{ ------------------------------------------------------------------------------------------------ }
{$REGION 'Editor methods'}
function TFsiPlugin.GetPluginConfigDirectory: String;
begin
  Result := WideFormat('%s%s%s', [GetPluginsConfigDir, PathDelim, ChangeFileExt(FSI_PLUGIN_MODULE_FILENAME, '')]);
end;

function TFsiPlugin.GetCurrentBufferPath(BuffrN: NativeUInt): String;
const
  MAX_PATH_LEN = 1001;
var
  NppMsg: Cardinal;
  PathLen: Integer;
  PathBuff: array of Char;
begin
  Result := '';
  PathBuff := [#$0000];
  if BuffrN > 0 then begin
    NppMsg := NPPM_GETFULLPATHFROMBUFFERID;
    PathLen := SendNppMessage(NppMsg, BuffrN, 0);
    if PathLen <= 0 then
      Exit;
    SetLength(PathBuff, PathLen + 1);
    SendNppMessage(NppMsg, BuffrN, @PathBuff[0]);
  end else begin
    NppMsg := NPPM_GETFULLCURRENTPATH;
    SetLength(PathBuff, MAX_PATH_LEN);
    SendNppMessage(NppMsg, MAX_PATH_LEN, @PathBuff[0]);
  end;
  SetString(Result, PChar(@PathBuff[0]), StrLen(PChar(@PathBuff[0])));
end;

function TFsiPlugin.GetCurrentFileExt(BuffrN: NativeUInt): String;
begin
  Result := String(StrRScan(PWideChar(GetCurrentBufferPath(BuffrN)), '.'));
end;

function TFsiPlugin.GetSelectedText: String;
var
  activeEditorHandle: HWND;
  selTextLength: Integer;
  textBuffer: PAnsiChar;
begin
  activeEditorHandle := CurrentScintilla;
  Result := '';

  if (activeEditorHandle <> 0) then
  begin
    selTextLength := SendMessage(CurrentScintilla, SCI_GETSELTEXT, 0, 0);
    if HasV5Apis then Inc(selTextLength);
    if (selTextLength > 1) then
    begin
      GetMem(textBuffer, SizeOf(Char) * selTextLength);
      try
        SendMessage(activeEditorHandle, SCI_GETSELTEXT, 0, LPARAM(textBuffer));
        Result := UTF8ToString(textBuffer);
      finally
        FreeMem(textBuffer, SizeOf(Char) * selTextLength);
      end;
    end;
  end;
end;
{$ENDREGION}

{ ------------------------------------------------------------------------------------------------ }
{$REGION 'Window procedures'}
procedure TFsiPlugin.SendDockDialogMsg(regData: PToolbarData);
begin
  SendNppMessage(NPPM_DMMREGASDCKDLG, 0, regData);
end;

procedure TFsiPlugin.ShowDialog(dialogHandle: HWND);
begin
  SendNppMessage(NPPM_DMMSHOW, 0, NativeInt(dialogHandle));
end;

procedure TFsiPlugin.HideDialog(dialogHandle: HWND);
begin
  SendNppMessage(NPPM_DMMHIDE, 0, NativeInt(dialogHandle));
end;

procedure TFsiPlugin.ToggleSendTextCmd(Disable: Boolean);
var
  NppMenu: HMENU;
  CmdId: Cardinal;
begin
  NppMenu := GetMenu(NppData.nppHandle);
  CmdId := CmdIdFromDlgId(Ord(FSI_SEND_TEXT_CMD_ID));
  if Disable or Boolean(SendMessage(CurrentScintilla, SCI_GETSELECTIONEMPTY, 0, 0)) then
    EnableMenuItem(NppMenu, CmdId, MF_BYCOMMAND or MF_DISABLED or MF_GRAYED)
  else begin
    if Assigned(FSIHostForm) and FSIHostForm.Visible then
      EnableMenuItem(NppMenu, CmdId, MF_BYCOMMAND or MF_ENABLED);
  end;
end;

procedure TFsiPlugin.ToggleLoadFileCmd(BuffrN: NativeUInt);
var
  NppMenu: HMENU;
  BuffExt: WideString;
  LoadCmdId, LoadCmdStatus: Cardinal;
  LoadCmdEnabled, IsFSharp: Boolean;
begin
  BuffExt := GetCurrentFileExt(BuffrN);
  NppMenu := GetMenu(NppData.nppHandle);
  LoadCmdId := CmdIdFromDlgId(Ord(FSI_LOAD_FILE_CMD_ID));
  if WideCompareStr('', BuffExt) = 0 then begin
    EnableMenuItem(NppMenu, loadCmdId, MF_BYCOMMAND or MF_DISABLED or MF_GRAYED);
    Exit;
  end;
  LoadCmdStatus := GetMenuState(NppMenu, loadCmdId, MF_BYCOMMAND);
  LoadCmdEnabled := ((loadCmdStatus and (MF_DISABLED or MF_GRAYED)) = 0);
  IsFSharp := WideSameText('.fs', Copy(BuffExt, 1, 3));
  if (not IsFSharp) and LoadCmdEnabled then begin
    EnableMenuItem(NppMenu, loadCmdId, MF_BYCOMMAND or MF_DISABLED or MF_GRAYED);
  end else if IsFSharp and not LoadCmdEnabled then
    EnableMenuItem(NppMenu, loadCmdId, MF_BYCOMMAND or MF_ENABLED);
end;
{$ENDREGION}

{ ------------------------------------------------------------------------------------------------ }
{$REGION 'Command menu procedures'}
procedure DoOnFSIFormClose();
begin
  Npp.SendNppMessage(NPPM_SETMENUITEMCHECK, Npp.CmdIdFromDlgId(Ord(FSI_INVOKE_CMD_ID)), 0);
  Npp.ToggleSendTextCmd(True);
  Npp.FSIHostForm := Nil;
end;

procedure TFsiPlugin.ToggleFSI;
begin
  if not Assigned(FSIHostForm) then
  begin
    Application.CreateForm(TFrmFSIHost, FSIHostForm);
    FSIHostForm.OnClose := DoOnFSIFormClose;
  end;

  if FSIHostForm.Visible then
  begin
    FSIHostForm.Close;
    Exit;
  end;

  FSIHostForm.Show;
  ToggleSendTextCmd;
  if FSIHostForm.Visible then
    SendNppMessage(NPPM_SETMENUITEMCHECK, CmdIdFromDlgId(Ord(FSI_INVOKE_CMD_ID)), 1);
end;

procedure TFsiPlugin.LoadFile;
begin
  if (not Assigned(FSIHostForm)) or (not FSIHostForm.Visible) then begin
    ToggleFSI;
    FSIHostForm.LoadFileInFSI(False);
  end else
    FSIHostForm.LoadFileInFSI;
end;

procedure TFsiPlugin.SendText;
begin
  if Assigned(FSIHostForm) then
  begin
    FSIHostForm.SendSelectedTextInNPPToFSI;
  end;
end;

procedure TFsiPlugin.ShowConfig;
begin
  if not Assigned(configForm) then
    Application.CreateForm(TFrmConfiguration, configForm);

  configForm.ShowModal;
end;

procedure TFsiPlugin.ShowAbout;
begin
  TFrmAbout.ShowModal;
end;
{$ENDREGION}

initialization
{$IFDEF VER3_2}
  Application.Scaled := True;
{$ENDIF}
  Application.Initialize;

end.
