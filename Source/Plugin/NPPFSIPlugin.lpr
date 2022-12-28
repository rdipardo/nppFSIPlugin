library NPPFSIPlugin;
// =============================================================================
// Unit: NPPFSIPlugin
// Description: Main library source for plugin, ported to Free Pascal.
//
// Copyright 2010 Prapin Peethambaran
// Copyright 2022 Robert Di Pardo (Free Pascal version)
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
{$mode delphiunicode}

uses
  Interfaces,
  LCLIntf,
  LCLType,
  Forms,
  SysUtils,
  Windows,
  Graphics,
  FpcPipes in 'Src\FpcPipes.pas',
  NPP in 'Src\NPP.pas',
  Constants in 'Src\Constants.pas',
  LexFSharp in 'Src\ClassLib\LexFSharp.pas',
  FSIHostForm in 'Forms\FSIHostForm.pas' {FrmFSIHost},
  ConfigForm in 'Forms\ConfigForm.pas' {FrmConfiguration},
  AboutForm in 'Forms\AboutForm.pas' {FrmAbout};

{$R *.res}

var
  PluginLoaded: Boolean;
  PluginFuncs: TPluginFuncList;
  FSIHostForm: TFrmFSIHost;
  ConfigForm: TFrmConfiguration;
  Bmp: TBitMap;
{$REGION 'Methods exported by plugin'}
/// Supports Unicode
///
function isUnicode: BOOL; cdecl;
begin
  Result := True;
end;
/// Loads basic NPP info.
///
procedure setInfo(data: TNppData); cdecl;
begin
  NppData := data;
end;
/// Define the name of the plugin.
///
function getName: PChar; cdecl;
begin
  Result := PChar(FSI_PLUGIN_NAME);
end;
/// Message handler for NPP messages
///
function messageProc(Message: Cardinal; wParam: wParam; lParam: lParam): LRESULT; cdecl;
begin
  Result := 0;
end;
/// Handle Notifications from Scintilla.
///
procedure beNotified(msg: PSCNotification); cdecl;
var
  sciMsg: TSCNotification;
begin
  sciMsg := TSCNotification(msg^);
  case sciMsg.nmhdr.code of
    NPPN_TBMODIFICATION: begin
      Bmp := TBitMap.Create;
      SetToolBarIcon(@PluginFuncs, Bmp);
      TLexFSharp.Init;
    end;
    NPPN_DARKMODECHANGED: begin
      if Assigned(FSIHostForm) then
        FSIHostForm.ToggleDarkMode;
    end;
    NPPN_BUFFERACTIVATED, NPPN_LANGCHANGED, NPPN_WORDSTYLESUPDATED: begin
      TLexFSharp.Lex;
    end;
  end;
end;
/// Get the custom functions defined by the plugin.
///
function getFuncsArray(var funcCount: Integer): Pointer; cdecl;
begin
  funcCount := FSI_PLUGIN_FUNC_COUNT;
  Result := @PluginFuncs;
end;
{$ENDREGION}
{$REGION 'Methods called by NPP'}
/// <summary>
/// Handle host form close notification.
/// </summary>
procedure DoOnFSIFormClose();
begin
  FSIHostForm := Nil;
end;
/// <summary>
/// Load the FSI window and show it.
/// </summary>
procedure LoadFSI; cdecl;
begin
  if not Assigned(FSIHostForm) then
  begin
    Application.CreateForm(TFrmFSIHost, FSIHostForm);
    FSIHostForm.OnClose := DoOnFSIFormClose;
  end;
  FSIHostForm.Show;
end;
/// <summary>
/// Send text from NPP to FSI.
/// </summary>
procedure SendText; cdecl;
begin
  if Assigned(FSIHostForm) then
  begin
    FSIHostForm.SendSelectedTextInNPPToFSI;
  end;
end;
/// <summary>
/// Show the plugin configuration window.
/// </summary>
procedure ShowConfig; cdecl;
begin
  if not Assigned(configForm) then
    Application.CreateForm(TFrmConfiguration, configForm);

  configForm.ShowModal;
end;
/// <summary>
/// Show the About window
/// </summary>
procedure ShowAbout; cdecl;
var
  aboutForm: TFrmAbout;
begin
  aboutForm := TFrmAbout.Create;
  try
    aboutForm.ShowModal;
  finally
    aboutForm.Free;
  end;
end;
{$ENDREGION}
{$REGION 'Helper Methods'}
/// Create and store structure that registers custom functions exported by the FSI plugin.
///
procedure RegisterPluginFunction(funcIndex: Integer; funcName: String; func: TPluginProc;
  isMenuChecked: Boolean; shortcut: PShortcutKey);
begin
  FillChar(PluginFuncs[funcIndex], sizeof(TFuncItem), 0);
  StrLCopy(PluginFuncs[funcIndex]._itemName, PChar(funcName), 63);
  PluginFuncs[funcIndex]._pFunc := func;
  PluginFuncs[funcIndex]._init2Check := isMenuChecked;
  PluginFuncs[funcIndex]._cmdID := 0;
  PluginFuncs[funcIndex]._PShKey := shortcut;
end;
/// Defines a keyboard shortcut for a function exposed by the FSI plugin.
///
function MakeShortcutKey(const useCtrl, useAlt, useShift: Boolean; key: UCHAR): PShortcutKey;
begin
  New(Result);
  Result._isCtrl := useCtrl;
  Result._isAlt := useAlt;
  Result._isShift := useShift;
  Result._key := key;
end;
/// Loads plugin by registering all custom funcs exposed by the FSI plugin.
///
procedure LoadPlugin;
begin
  if (not PluginLoaded) then
  begin
    RegisterPluginFunction(FSI_INVOKE_CMD_ID, FSI_PLUGIN_LOAD_MENU, LoadFSI, false, MakeShortcutKey(false,
      true, false, $54));
    RegisterPluginFunction(FSI_SEND_TEXT_CMD_ID, FSI_PLUGIN_SEND_TEXT_MENU, SendText, false, MakeShortcutKey(false,
      true, false, VK_RETURN));
    RegisterPluginFunction(FSI_SEP_1_CMD_ID, '-', Nil, false, Nil);
    RegisterPluginFunction(FSI_CONFIG_CMD_ID, FSI_PLUGIN_CONFIG_MENU, ShowConfig, false, Nil);
    RegisterPluginFunction(FSI_ABOUT_CMD_ID, FSI_PLUGIN_ABOUT_MENU, ShowAbout, false, Nil);
    PluginLoaded := true;
  end;
end;
/// Releases rsources before unloading FSI plugin.
///
procedure UnLoadPlugin;
var
  i: Integer;
begin
  if Assigned(FSIHostForm) then
    FreeAndNil(FSIHostForm);
  if Assigned(ConfigForm) then
    FreeAndNil(ConfigForm);
  if Assigned(Bmp) then
    FreeAndNil(Bmp);
  for i := Low(PluginFuncs) to High(PluginFuncs) do
  begin
    if (PluginFuncs[i]._PShKey <> Nil) then
      Dispose(PluginFuncs[i]._PShKey);
  end;
  PluginLoaded := false;
end;
{$ENDREGION}
{$REGION 'DLL Proc'}
procedure DLLEntry(dwReason: DWORD);
begin
  case dwReason of
    DLL_PROCESS_ATTACH:
      LoadPlugin;
    DLL_PROCESS_DETACH:
      UnLoadPlugin;
  end;
end;
{$ENDREGION}
exports
  isUnicode,
  setInfo,
  getName,
  getFuncsArray,
  beNotified,
  messageProc;
begin
{$IFDEF VER3_2}
  Application.Scaled:=True;
{$ENDIF}
  Application.Initialize;
  DLL_PROCESS_DETACH_Hook := @DLLEntry;
  DLLEntry(DLL_PROCESS_ATTACH);
end.
