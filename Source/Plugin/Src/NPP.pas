unit NPP;

// =============================================================================
// Unit: NPP
// Description: Notepad++ API Interface Unit
//
// Copyright 2010 Prapin Peethambaran
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// =============================================================================
{$IFDEF FPC}{$mode delphiunicode}{$ENDIF}

interface

uses
  // std delphi units
  Windows, Messages, Graphics;

{$I 'Include\Scintilla.inc'}
{$I 'Include\Npp.inc'}
{$I 'Include\DarkMode.inc'}
{$I 'Include\Docking.inc'}
{$I 'Include\DockingResource.inc'}

const

  /// <summary>
  /// ID of function that invokes the FSI plugin.
  /// </summary>
  FSI_INVOKE_CMD_ID = 0;

  /// <summary>
  /// ID of the functions that sends text to the FSI plugin.
  /// </summary>
  FSI_SEND_TEXT_CMD_ID = 1;

  /// <summary>
  /// ID of a separator menu item.
  /// </summary>
  FSI_SEP_1_CMD_ID = 2;

  /// <summary>
  /// ID of function that invokes the configuration dialog.
  /// </summary>
  FSI_CONFIG_CMD_ID = 3;

  /// <summary>
  /// ID of function that invokes the about dialog.
  /// </summary>
  FSI_ABOUT_CMD_ID = 4;

  /// <summary>
  /// Number of public functions exposed by FSI.
  /// </summary>
  FSI_PLUGIN_FUNC_COUNT = 5;

type

  TPluginFuncList = array [0 .. FSI_PLUGIN_FUNC_COUNT - 1] of TFuncItem;
  PTPluginFuncList = ^TPluginFuncList;
{$IFDEF FPC}
  TPngImage = TPortableNetworkGraphic;
{$ENDIF}

  /// <summary>
  /// Get the version number of the running application.
  /// </summary>
  function GetNppVersion: Cardinal;

  /// <summary>
  /// Return `true` if the Scintilla API level is at least 5.2.1 -- i.e., if the Npp version is >= 8.4.
  /// https://github.com/notepad-plus-plus/notepad-plus-plus/commit/a61b03ea8887e21c6e1b7374068962f635b79b80
  /// </summary>
  function HasV5Apis: Boolean;

  /// <summary>
  /// Return `true` if the dark mode setting can be detected by sending the NPPM_ISDARKMODEENABLED message;
  /// works in Npp versions >= 8.4.1.
  /// https://github.com/notepad-plus-plus/notepad-plus-plus/commit/1eb5b10e41d7ab92b60aa32b28d4fe7739d15b53
  /// </summary>
  function IsDarkModeEnabled: Boolean;

  /// <summary>
  /// Return `true` if the NPPM_CREATELEXER message is defined -- i.e., if the Npp version is >= 8.4.3.
  /// https://github.com/notepad-plus-plus/notepad-plus-plus/commit/f1ed4de78dbe8f5d85f4d199bae2970148cca8ed
  /// </summary>
  function SupportsILexer: Boolean;

  /// <summary>
  /// Get the dir where NPP stores the config information of its plugins.
  /// </summary>
  function GetPluginConfigDirectory: String;

  /// <summary>
  /// Get the window handle of the active scintilla control in NPP.
  /// </summary>
  function GetActiveEditorHandle: HWND;

  /// <summary>
  /// Get selected text, if any, from the active editor in NPP.
  /// </summary>
  function GetSelectedText: String;

  /// <summary>
  /// Dock a window in NPP. Doking params, window details etc are specified in the param.
  /// </summary>
  procedure DockDialog(registrationData: PTbData);

  /// <summary>
  /// Send a message to a docked plugin dialog in NPP.
  /// </summary>
  procedure SendDockDialogMsg(regData: PTbData);

  /// <summary>
  /// Show a plugin dialog.
  /// </summary>
  procedure ShowDialog(dialogHandle: HWND);

  /// <summary>
  /// Initializes an instance of TDarkModeColors with the editor's active dark mode styles.
  /// </summary>
  procedure GetDarkModeColors( PColors: PDarkModeColors);

  procedure SetToolBarIcon(const pluginFuncList: PTPluginFuncList; var tbBmp: TBitmap);

  procedure SetILexer(const LexerName: string);

var
  // global var to store info provided by NPP
  NppData: TNppData;

implementation

uses
  Constants,
  // standard delphi units
  SysUtils {$IFNDEF FPC}, Imaging.pngimage{$ENDIF};

function GetPluginConfigDirectory: String;
var
  dirBuffer: array [0..MAX_PATH] of Char;
  configDir: string;
begin
  SendMessage(NppData._nppHandle, NPPM_GETPLUGINSCONFIGDIR, MAX_PATH, LPARAM(@dirBuffer[0]));
  SetString(configDir, PChar(@dirBuffer[0]), StrLen(PChar(@dirBuffer[0])));
  Result := WideFormat('%s%s%s', [configDir, PathDelim, ChangeFileExt(FSI_PLUGIN_MODULE_FILENAME, '')]);
end;

function GetActiveEditorHandle: HWND;
var
  activeEditorIndex: Integer;
begin
  SendMessage(NppData._nppHandle, NPPM_GETCURRENTSCINTILLA, 0, LPARAM(@activeEditorIndex));

  if (activeEditorIndex = 0) then
    Result := NppData._scintillaMainHandle
  else
    Result := NppData._scintillaSecondHandle;
end;

function GetSelectedText: String;
var
  activeEditorHandle: HWND;
  selTextLength: Integer;
  textBuffer: PAnsiChar;
begin
  activeEditorHandle := GetActiveEditorHandle;
  Result := '';

  if (activeEditorHandle <> 0) then
  begin
    selTextLength := SendMessage(GetActiveEditorHandle, SCI_GETSELTEXT, 0, 0);
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

procedure DockDialog(registrationData: PTbData);
begin
  SendMessage(NppData._nppHandle, NPPM_DMMREGASDCKDLG, 0, LPARAM(registrationData));
end;

procedure SendDockDialogMsg(regData: PTbData);
begin
  SendMessage(NppData._nppHandle, NPPM_DMMREGASDCKDLG, 0, LPARAM(regData));
end;

procedure ShowDialog(dialogHandle: HWND);
begin
  SendMessage(NppData._nppHandle, NPPM_DMMSHOW, 0, WPARAM(dialogHandle));
end;

procedure SetToolBarIcon(const pluginFuncList: PTPluginFuncList; var tbBmp: TBitmap);
var
  tbBmpSource: TPngImage;
  tbIcons: TTbIcons;
  tbIconsDM: TTbIconsDarkMode;
  funcList: TPluginFuncList;
  haveDarkMode: Boolean;
begin
  tbBmpSource := TPngImage.Create;
  tbIcons := Default (TTbIcons);
  tbIconsDM := Default (TTbIconsDarkMode);
  haveDarkMode := HIWORD(GetNppVersion) >= 8;

  try
    tbBmpSource.LoadFromResourceName(HInstance, 'tbBmpSource');
    tbBmp.Assign(tbBmpSource);
    {$IFNDEF FPC}tbBmp.PixelFormat := pf32bit;{$ENDIF}
    tbBmp.Width := 16;
    tbBmp.Height := 16;
  finally
    FreeAndNil(tbBmpSource);
  end;

  tbIcons.hToolbarBmp := tbBmp.handle;
  tbIcons.hToolbarIcon := LoadImage(Hinstance, 'tbIcon', IMAGE_ICON, 0, 0,
    (LR_DEFAULTSIZE or LR_LOADTRANSPARENT));

  if haveDarkMode then begin
    tbIconsDM.hToolbarBmp := tbIcons.hToolbarBmp;
    tbIconsDM.hToolbarIcon := tbIcons.hToolbarIcon;
    tbIconsDM.hToolbarIconDarkMode := LoadImage(Hinstance, 'tbIconDark', IMAGE_ICON,
      0, 0, (LR_DEFAULTSIZE or LR_LOADTRANSPARENT));
  end;

  funcList := TPluginFuncList(pluginFuncList^);

  if tbIconsDM.hToolbarIconDarkMode <> 0 then
    SendMessage(NppData._nppHandle, NPPM_ADDTOOLBARICON_FORDARKMODE,
      funcList[FSI_INVOKE_CMD_ID]._cmdID, LPARAM(@tbIconsDM))
  else begin
    SendMessage(NppData._nppHandle, NPPM_ADDTOOLBARICON,
      funcList[FSI_INVOKE_CMD_ID]._cmdID, LPARAM(@tbIcons))
  end;
end;

procedure SetILexer(const LexerName: string);
var
  lexerPtr: NativeInt;
begin
  lexerPtr := SendMessage(NppData._nppHandle, NPPM_CREATELEXER, 0, LPARAM(PCHAR(LexerName)));
  SendMessage(GetActiveEditorHandle, SCI_SETILEXER, 0, lexerPtr);
end;

function GetNppVersion: Cardinal;
var
  NppVersion: Cardinal;
begin
  NppVersion := SendMessage(NppData._nppHandle, NPPM_GETNPPVERSION, 0, 0);
  // retrieve the zero-padded version, if available
  // https://github.com/notepad-plus-plus/notepad-plus-plus/commit/ef609c896f209ecffd8130c3e3327ca8a8157e72
  if ((HIWORD(NppVersion) > 8) or
      ((HIWORD(NppVersion) = 8) and
        (((LOWORD(NppVersion) >= 41) and (not (LOWORD(NppVersion) in [191, 192, 193]))) or
          (LOWORD(NppVersion) in [5, 6, 7, 8, 9])))) then
    NppVersion := SendMessage(NppData._nppHandle, NPPM_GETNPPVERSION, 1, 0);

  Result := NppVersion;
end;

function HasV5Apis: Boolean;
var
  NppVersion: Cardinal;
begin
  NppVersion := GetNppVersion;
  Result :=
    (HIWORD(NppVersion) > 8) or
    ((HIWORD(NppVersion) = 8) and
        ((LOWORD(NppVersion) >= 4) and
           (not (LOWORD(NppVersion) in [11, 12, 13, 14, 15, 16, 17, 18, 19, 21, 31, 32, 33, 191, 192, 193]))));
end;

function IsDarkModeEnabled: Boolean;
var
  NppVersion: Cardinal;
  HasQueryApi: Boolean;
begin
  NppVersion := GetNppVersion;
  HasQueryApi :=
    ((HIWORD(NppVersion) > 8) or
     ((HIWORD(NppVersion) = 8) and
        (((LOWORD(NppVersion) >= 41) and (not (LOWORD(NppVersion) in [191, 192, 193]))))));
  Result := (HasQueryApi and Boolean(SendMessage(NppData._nppHandle, NPPM_ISDARKMODEENABLED, 0, 0)));
end;

function SupportsILexer: Boolean;
var
  NppVersion: Cardinal;
begin
  NppVersion := GetNppVersion;
  Result :=
    (HIWORD(NppVersion) > 8) or
    ((HIWORD(NppVersion) = 8) and
       ((LOWORD(NppVersion) >= 43) and (not (LOWORD(NppVersion) in [191, 192, 193]))));
end;

procedure GetDarkModeColors(PColors: PDarkModeColors);
begin
  if IsDarkModeEnabled then
    SendMessage(NppData._nppHandle, NPPM_GETDARKMODECOLORS, WPARAM(SizeOf(TDarkModeColors)), LPARAM(PColors));
end;

end.
