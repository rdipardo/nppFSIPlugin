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

interface

uses
  // std delphi units
  Windows, Messages, Graphics;

const

  // NPP messages
  NPPN_FIRST = 1000;
  NPPMSG = (WM_USER + 1000);
  NPPN_TBMODIFICATION = (NPPN_FIRST + 2);
	NPPM_GETCURRENTSCINTILLA = (NPPMSG + 4);
  NPPM_DMMREGASDCKDLG = (NPPMSG + 33);
	NPPM_DMMSHOW = (NPPMSG + 30);
	NPPM_DMMHIDE = (NPPMSG + 31);
	NPPM_DMMUPDATEDISPINFO = (NPPMSG + 32);
  NPPM_ADDTOOLBARICON = (NPPMSG + 41);
  NPPM_GETPLUGINSCONFIGDIR = (NPPMSG + 46);
  NPPM_GETNPPVERSION = (NPPMSG + 50);
  NPPM_ADDTOOLBARICON_FORDARKMODE = (NPPMSG + 101);

  // since 8.0
  // https://github.com/notepad-plus-plus/npp-usermanual/blob/master/content/docs/plugin-communication.md#nppm_addtoolbaricon-nppm_addtoolbaricon_deprecated-in-v80
  NPPM_ADDTOOLBARICON_DEPRECATED = NPPM_ADDTOOLBARICON;

  // docking manager related
  CONT_LEFT	= 0;
  CONT_RIGHT = 1;
  CONT_TOP = 2;
  CONT_BOTTOM = 3;
  DOCKCONT_MAX = 4;
  DMN_FIRST = 1050;
  DMN_CLOSE = (DMN_FIRST + 1);
  DMN_DOCK = (DMN_FIRST + 2);
  DMN_FLOAT = (DMN_FIRST + 3);

  // mask params for plugin internal dialogs
  DWS_ICONTAB	= $00000001;			              // icon for tabs are available
  DWS_ICONBAR	= $00000002;			              // icon for icon bar are available (currently not supported)
  DWS_ADDINFO	= $00000004;			              // additional information in use
  DWS_PARAMSALL	=	(DWS_ICONTAB or DWS_ICONBAR or DWS_ADDINFO);
  DWS_DF_CONT_LEFT =(CONT_LEFT	shl 28);	    // default docking on left
  DWS_DF_CONT_RIGHT	= (CONT_RIGHT	shl 28);	  // default docking on right
  DWS_DF_CONT_TOP	= (CONT_TOP	shl 28);	      // default docking on top
  DWS_DF_CONT_BOTTOM = (CONT_BOTTOM shl 28);	// default docking on bottom
  DWS_DF_FLOATING = $80000000;                // default state is floating

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

  TNppData = record
    _nppHandle: HWND;
    _scintillaMainHandle: HWND;
    _scintillaSecondHandle: HWND;
  end;

  TPluginProc = procedure; cdecl;

  TShortcutKey = record
    _isCtrl: Boolean;
    _isAlt: Boolean;
    _isShift: Boolean;
    _key: UCHAR;
  end;

  PShortcutKey = ^TShortcutKey;

  TFuncItem = record
    _itemName: array [0 .. 63] of Char;
    _pFunc: TPluginProc;
    _cmdID: Integer;
    _init2Check: BOOL;
    _PShKey: PShortcutKey;
  end;

  TTbData = record
    hClient: HWND;          // client Window Handle
    pszName: PChar;         // name of plugin (shown in window)
    dlgID: Integer;         // a funcItem provides the function pointer to start a dialog
    uMask: UINT;            // mask params
    hIconTab: HICON;        // icon for tabs
    pszAddInfo: PChar;      // for plugin to display additional informations
    rcFloat: TRect;         // floating position
    iPrevCont: Integer;     // stores the previous container (toggling between float and dock)
    pszModuleName: PChar;   // it's the plugin file name. It's used to identify the plugin
  end;
  PTbData = ^TTbData;

  TTbIcons = record
    hToolbarBmp: HBITMAP;
    hToolbarIcon: HICON;
  end;

  TTbIconsDarkMode = record
    hToolbarBmp: HBITMAP;
    hToolbarIcon: HICON;
    hToolbarIconDarkMode: HICON;
  end;

  TPluginFuncList = array [0 .. FSI_PLUGIN_FUNC_COUNT - 1] of TFuncItem;
  PTPluginFuncList = ^TPluginFuncList;

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
  procedure SendDockDialogMsg(handle: HWND; windowTitle, additionalInfo, pluginName: String;
    commandId: Integer; dlgMask: UINT; iconHandle: HICON);

  /// <summary>
  /// Show a plugin dialog.
  /// </summary>
  procedure ShowDialog(dialogHandle: HWND);


  procedure SetToolBarIcon(const pluginFuncList: PTPluginFuncList;
    const tbIcon: TIcon; const tbIconDark: TIcon; var tbBmp: TBitmap);

var
  // global var to store info provided by NPP
  NppData: TNppData;

implementation

uses
  // standard delphi units
  SysUtils, Imaging.pngimage,
  // scintilla interface
  Scintilla
  ;

function GetPluginConfigDirectory: String;
var
  dirBuffer: String;
begin
  SetLength(dirBuffer, MAX_PATH);
  SendMessage(NppData._nppHandle, NPPM_GETPLUGINSCONFIGDIR, MAX_PATH, LPARAM(PChar(dirBuffer)));
  SetString(Result, PChar(dirBuffer), StrLen(PChar(dirBuffer)));
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

  if (activeEditorHandle <> 0) then
  begin
    selTextLength := SendMessage(GetActiveEditorHandle, SCI_GETSELTEXT, 0, 0);

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

procedure SendDockDialogMsg(handle: HWND; windowTitle, additionalInfo, pluginName: String; commandId: Integer; dlgMask: UINT; iconHandle: HICON);
var
  regData: PTbData;
begin
  regData := AllocMem(SizeOf(TTbData));
  GetMem(regData.pszName, SizeOf(Char) * (Length(windowTitle) + 1));
  if (additionalInfo <> '') then
  begin
    GetMem(regData.pszAddInfo, SizeOf(Char) * (Length(additionalInfo) + 1));
  end;
  GetMem(regData.pszModuleName,  SizeOf(Char) * (Length(pluginName) + 1));

  try
    regData.hClient := handle;
    StrCopy(regData.pszName, PChar(windowTitle));
    regData.dlgID := commandId;
    regData.uMask := dlgMask;
    regData.hIconTab := iconHandle;
    if (additionalInfo <> '') then
    begin
      StrCopy(regData.pszAddInfo, PChar(additionalInfo));
    end;
    StrCopy(regData.pszModuleName, PChar(pluginName));

    SendMessage(NppData._nppHandle, NPPM_DMMREGASDCKDLG, 0, LPARAM(regData));
  finally
    FreeMem(regData.pszModuleName, SizeOf(Char) * (Length(pluginName) + 1));
    if (additionalInfo <> '') then
    begin
      FreeMem(regData.pszAddInfo, SizeOf(Char) * (Length(additionalInfo) + 1));
    end;
    FreeMem(regData.pszName, SizeOf(Char) * (Length(windowTitle) + 1));
    FreeMem(regData);
  end;
end;

procedure ShowDialog(dialogHandle: HWND);
begin
  SendMessage(NppData._nppHandle, NPPM_DMMSHOW, 0, WPARAM(dialogHandle));
end;

procedure SetToolBarIcon(const pluginFuncList: PTPluginFuncList;
  const tbIcon: TIcon; const tbIconDark: TIcon; var tbBmp: TBitmap);
var
  tbBmpSource: TPngImage;
  tbIcons: TTbIcons;
  tbIconsDM: TTbIconsDarkMode;
  funcList: TPluginFuncList;
  nppVersion: LONG;
  haveDarkMode: Boolean;
begin
  tbBmpSource := TPngImage.Create;
  tbIcons := Default (TTbIcons);
  tbIconsDM := Default (TTbIconsDarkMode);
  nppVersion := SendMessage(NppData._nppHandle, NPPM_GETNPPVERSION, 0, 0);
  haveDarkMode := HIWORD(nppVersion) >= 8;

  try
    tbBmpSource.LoadFromResourceName(HInstance, 'tbBmpSource');
    tbBmp.Assign(tbBmpSource);
    tbBmp.PixelFormat := pf32bit;
    tbBmp.Width := 16;
    tbBmp.Height := 16;
  finally
    FreeAndNil(tbBmpSource);
  end;

  tbIcon.LoadFromResourceName(HInstance, 'tbIcon');
  tbIcons.hToolbarBmp := tbBmp.handle;
  tbIcons.hToolbarIcon := tbIcon.handle;

  if haveDarkMode then begin
    tbIconDark.LoadFromResourceName(HInstance, 'tbIconDark');
    tbIconsDM.hToolbarBmp := tbBmp.handle;
    tbIconsDM.hToolbarIcon := tbIcon.handle;
    tbIconsDM.hToolbarIconDarkMode := tbIconDark.handle;
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


end.
