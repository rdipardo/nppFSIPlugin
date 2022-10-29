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

{$I 'Include\Scintilla.inc'}
{$I 'Include\Npp.inc'}
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
  SysUtils, Imaging.pngimage;

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
      if HasV5Apis then Inc(selTextLength);
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
  haveDarkMode: Boolean;
begin
  tbBmpSource := TPngImage.Create;
  tbIcons := Default (TTbIcons);
  tbIconsDM := Default (TTbIconsDarkMode);
  haveDarkMode := HIWORD(GetNppVersion) >= 8;

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

end.
