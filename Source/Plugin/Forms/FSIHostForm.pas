unit FSIHostForm;

// =============================================================================
// Unit: FSIHostForm
// Description: Source for the window used to host FSI
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
  // standard units
  Classes, Forms, Messages,
  // NPP interface unit
  NPP,
  // FSI wrapper unit
  FSIWrapper;

type

  /// <summary>
  /// The FSI host form close event type.
  /// </summary>
  TFSIHostCloseEvent = procedure;

  /// <summary>
  /// Form used to host the FSI wrapper control.
  /// </summary>
  TFrmFSIHost = class(TForm)
  private
    _configOK: Boolean;
    _formRegData: PToolbarData;
    _fsiViewer: TFSIViewer;
    _onClose: TFSIHostCloseEvent;
  private
    procedure registerForm;
    procedure createFSI;
    procedure quitFSI;
  protected
    procedure DoClose(var Action: TCloseAction); override;
    procedure WMNotify(var msg: TWMNotify); message WM_NOTIFY;
  public
    constructor Create(owner: TComponent); override;
    destructor Destroy; override;
  public
    procedure Show;
    procedure SendSelectedTextInNPPToFSI;
    procedure LoadFileInFSI(EchoFilePath: Boolean = True);
    procedure ToggleDarkMode;
  public
    property OnClose: TFSIHostCloseEvent read _onClose write _onClose;
  end;

implementation

uses
  // standard units
  SysUtils, StdCtrls, Controls, Dialogs, Graphics, System.UITypes, Windows,
  // plugin units
  Constants, Config;

{$IFDEF FPC}
{$R *.lfm}
{$ELSE}
{$R *.dfm}
{$ENDIF}

{$REGION 'Constructor & Destructor'}

constructor TFrmFSIHost.Create(owner: TComponent);
begin
  inherited Create(owner);

  _configOK := false;
  createFSI;
end;

destructor TFrmFSIHost.Destroy;
begin
  if Assigned(_formRegData) then
  begin
    FreeMem(_formRegData.Title, SizeOf(nppChar) * (Length(_formRegData.Title) + 1));
    FreeMem(_formRegData.ModuleName, SizeOf(nppChar) * (Length(_formRegData.ModuleName) + 1));
    if Assigned(_formRegData.AdditionalInfo) and (StrLen(_formRegData.AdditionalInfo) <> 0) then
      FreeMem(_formRegData.AdditionalInfo, SizeOf(nppChar) * (Length(_formRegData.AdditionalInfo) + 1));
    FreeMem(_formRegData, SizeOf(TToolbarData));
    _formRegData := Nil;
  end;

  _fsiViewer.Free;

  inherited;
end;

{$ENDREGION}

{$REGION 'Public Mehtods'}

procedure TFrmFSIHost.Show;
 begin
   if not Assigned(_fsiViewer) then
    createFSI;

   _configOK := _fsiViewer.Start;

   if (not _configOK) then
      MessageDlg(FSI_PLUGIN_START_FAILE_MSG, mtError, [mbClose], 0)
   else
   begin
      if not Assigned(_formRegData) then
         registerForm;

      ToggleDarkMode;
      Visible := true;
      ShowDialog(Handle);
   end;
end;

procedure TFrmFSIHost.SendSelectedTextInNPPToFSI;
var
  selText: String;
begin
  selText := GetSelectedText;
  if Length(selText) = 0 then
    Exit;

  // reload options in case they've changed
  _fsiViewer.Config.LoadFromConfigFile;
  _fsiViewer.SendText(selText, true, _fsiViewer.Config.EchoNPPTextInEditor);
end;

procedure TFrmFSIHost.LoadFileInFSI(EchoFilePath: Boolean);
begin
  _fsiViewer.SendText(WideFormat('#load @"%s"', [Npp.GetCurrentBufferPath]), True, EchoFilePath);
end;

procedure TFrmFSIHost.ToggleDarkMode;
var
  DarkModeColors: Npp.TDarkModeColors;
  currentBuffer:{$IFDEF FPC}AnsiString{$ELSE}String{$ENDIF};
begin
  ParentBackground := (not Npp.IsDarkModeEnabled);
  _fsiViewer.Editor.ParentColor := ParentBackground;
  with _fsiViewer.Editor do begin
    if (not ParentColor) then
    begin
      DarkModeColors := Default(Npp.TDarkModeColors);
      Npp.GetDarkModeColors(@DarkModeColors);
      Color := TColor(DarkModeColors.SofterBackground);
{$IFDEF FPC}
      BorderStyle := bsNone;
{$ENDIF}
    end else begin
      Color := clWhite;
{$IFDEF FPC}
      BorderStyle := bsSingle;
{$ENDIF}
    end;
    Self.Color := Color;
    SelectAll;
    currentBuffer := SelText;
    Clear;
  end;
  _fsiViewer.AddToEditor(currentBuffer);
  _fsiViewer.updateEditableAreaStart(True);
end;
{$ENDREGION}

{$REGION 'Protected Methods'}

procedure TFrmFSIHost.DoClose(var Action: TCloseAction);
begin
  QuitFSI;
  // make sure the configuration reflects any changed options
  // so they're saved to disk
  _fsiViewer.Config.LoadFromConfigFile;
  HideDialog(Handle);
  inherited;

  Action := caHide;

  if Assigned(_onClose) then
    _onClose;
end;

procedure TFrmFSIHost.WMNotify(var msg: TWMNotify);
begin
  if (Npp.NppData.nppHandle = msg.NMHdr.hwndFrom) then
  begin
    msg.Result := 0;

    if (msg.NMHdr.code = DMN_CLOSE) then
    begin
      Close;
    end;
  end
  else
    inherited;
end;

{$ENDREGION}

{$REGION 'Private Methods'}

procedure TFrmFSIHost.registerForm;
var
  lenTitle, lenModName: Cardinal;
begin
  _formRegData := PToolbarData(AllocMem(SizeOf(TToolbarData)));
  _formRegData.ClientHandle := Handle;
  _formRegData.dlgID := Ord(FSI_INVOKE_CMD_ID);
  _formRegData.Mask := DWS_DF_CONT_BOTTOM or DWS_ICONTAB;
  _formRegData.IconTab := LoadImage(Hinstance, 'tbIcon', IMAGE_ICON, 0, 0,
    (LR_DEFAULTSIZE or LR_LOADTRANSPARENT));
  lenTitle := SizeOf(NppChar) * (Length(FSI_PLUGIN_WND_TITLE) + 1);
  lenModName := SizeOf(NppChar) * (Length(FSI_PLUGIN_MODULE_FILENAME) + 1);
  GetMem(_formRegData.Title, lenTitle);
  GetMem(_formRegData.ModuleName, lenModName);
  StrLCopy(_formRegData.Title, nppPChar(FSI_PLUGIN_WND_TITLE), lenTitle);
  StrLCopy(_formRegData.ModuleName, nppPChar(FSI_PLUGIN_MODULE_FILENAME), lenModName);
  try
    SendDockDialogMsg(_formRegData);
  except
    FreeMem(_formRegData.Title, lenTitle);
    FreeMem(_formRegData.ModuleName, lenModName);
    if Assigned(_formRegData.AdditionalInfo) and (StrLen(_formRegData.AdditionalInfo) <> 0) then
      FreeMem(_formRegData.AdditionalInfo, SizeOf(NppChar) * (Length(_formRegData.AdditionalInfo) + 1));
    FreeMem(_formRegData, SizeOf(TToolbarData));
    _formRegData := Nil;
  end;
end;

procedure TFrmFSIHost.createFSI;
begin
  _fsiViewer := TFSIViewer.Create;
  _fsiViewer.Editor.Align := alClient;
  _fsiViewer.Editor.Parent := self;
  with _fsiViewer.Editor do begin
    Parent := self;
    Align := alClient;
    BorderStyle := bsNone;
    Width := 10;
    Height := 10;
    ScrollBars := ssBoth;
    ReadOnly := False;
{$IFNDEF FPC}
    AlignWithMargins := True;
{$ENDIF}
  end;
end;

procedure TFrmFSIHost.QuitFSI;
begin
  if Assigned(_fsiViewer) and _fsiViewer.IsConsoleRunning(False) then
      _fsiViewer.SendText(PChar('#quit ;;' + #13#10), false, false);
end;

{$ENDREGION}

end.
