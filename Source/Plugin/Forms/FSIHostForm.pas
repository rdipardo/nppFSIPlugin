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
    _formRegData: PTbData;
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
    procedure ToggleDarkMode;
  public
    property OnClose: TFSIHostCloseEvent read _onClose write _onClose;
  end;

implementation

uses
  // standard units
  SysUtils, StdCtrls, Controls, Dialogs, Graphics, System.UITypes,
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
    FreeMem(_formRegData.pszName, SizeOf(Char) * (Length(_formRegData.pszName) + 1));
    FreeMem(_formRegData.pszModuleName, SizeOf(Char) * (Length(_formRegData.pszModuleName) + 1));
    if Assigned(_formRegData.pszAddInfo) and (StrLen(_formRegData.pszAddInfo) <> 0) then
      FreeMem(_formRegData.pszAddInfo, SizeOf(Char) * (Length(_formRegData.pszAddInfo) + 1));
    FreeMem(_formRegData, SizeOf(TTbData));
    _formRegData := Nil;
  end;

  QuitFSI;
  // make sure the configuration reflects any changed options
  // so they're saved to disk
  _fsiViewer.Config.LoadFromConfigFile;
  _fsiViewer.Free;

  inherited;
end;

{$ENDREGION}

{$REGION 'Public Mehtods'}

procedure TFrmFSIHost.Show;
 begin
   if not Assigned(_fsiViewer) then
    createFSI;

   if (_fsiViewer.Editor.Lines.Count > 0) then
   begin
     QuitFSI;
     _fsiViewer.Editor.Clear;
   end;

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
begin
  // reload options in case they've changed
  _fsiViewer.Config.LoadFromConfigFile;
  _fsiViewer.SendText(GetSelectedText, true, _fsiViewer.Config.EchoNPPTextInEditor);
end;

procedure TFrmFSIHost.ToggleDarkMode;
var
  currentBuffer:{$IFDEF FPC}AnsiString{$ELSE}String{$ENDIF};
begin
  ParentBackground := (not Npp.IsDarkModeEnabled);
  _fsiViewer.Editor.ParentColor := ParentBackground;
  with _fsiViewer.Editor do begin
    if (not ParentColor) then
    begin
      Color := TColor($3C3838);
{$IFDEF FPC}
      BorderStyle := bsNone;
      BorderSpacing.Left := 8;
{$ENDIF}
    end else begin
      Color := clWhite;
{$IFDEF FPC}
      BorderStyle := bsSingle;
      BorderSpacing.Left := 0;
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
  inherited;

  Action := caHide;

  if Assigned(_onClose) then
    _onClose;
end;

procedure TFrmFSIHost.WMNotify(var msg: TWMNotify);
begin
  if (Npp.NppData._nppHandle = msg.NMHdr.hwndFrom) then
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
  _formRegData := PTbData(AllocMem(SizeOf(TTbData)));
  _formRegData.hClient := Handle;
  _formRegData.dlgID := FSI_INVOKE_CMD_ID;
  _formRegData.uMask := DWS_DF_CONT_BOTTOM or DWS_USEOWNDARKMODE;
  _formRegData.hIconTab := 0;
  lenTitle := SizeOf(Char) * (Length(FSI_PLUGIN_WND_TITLE) + 1);
  lenModName := SizeOf(Char) * (Length(FSI_PLUGIN_MODULE_FILENAME) + 1);
  GetMem(_formRegData.pszName, lenTitle);
  GetMem(_formRegData.pszModuleName, lenModName);
  StrLCopy(_formRegData.pszName, PChar(FSI_PLUGIN_WND_TITLE), lenTitle);
  StrLCopy(_formRegData.pszModuleName, PChar(FSI_PLUGIN_MODULE_FILENAME), lenModName);
  try
    SendDockDialogMsg(_formRegData);
  except
    FreeMem(_formRegData.pszName, lenTitle);
    FreeMem(_formRegData.pszModuleName, lenModName);
    if Assigned(_formRegData.pszAddInfo) and (StrLen(_formRegData.pszAddInfo) <> 0) then
      FreeMem(_formRegData.pszAddInfo, SizeOf(Char) * (Length(_formRegData.pszAddInfo) + 1));
    FreeMem(_formRegData, SizeOf(TTbData));
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
    ReadOnly := True;
{$IFNDEF FPC}
    AlignWithMargins := True;
    with Margins do begin
      Top := 0;
      Bottom := 0;
      Right := 0;
      Left := 8;
    end;
{$ENDIF}
  end;
end;

procedure TFrmFSIHost.QuitFSI;
begin
  if Assigned(_fsiViewer) then
      _fsiViewer.SendText(PChar('#quit ;;' + #13#10), false, false);
end;

{$ENDREGION}

end.
