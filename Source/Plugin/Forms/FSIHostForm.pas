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
    procedure doOnResultOutput(sender: TObject);
    procedure doOnSendText(sender: TObject);
  protected
    procedure DoClose(var Action: TCloseAction); override;
    procedure WMNotify(var msg: TWMNotify); message WM_NOTIFY;
  public
    constructor Create(owner: TComponent); override;
    destructor Destroy; override;
  public
    procedure Show;
    procedure SendSelectedTextInNPPToFSI;
  public
    property OnClose: TFSIHostCloseEvent read _onClose write _onClose;
  end;

implementation

uses
  // standard units
  SysUtils, Controls, Dialogs,
  // plugin units
  Constants, Config;

{$R *.dfm}

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
    FreeMem(_formRegData.pszName, SizeOf(Char) * (Length(FSI_PLUGIN_WND_TITLE) + 1));
    FreeMem(_formRegData.pszModuleName,  SizeOf(Char) * (Length(FSI_PLUGIN_MODULE_FILENAME) + 1));
    FreeMem(_formRegData, SizeOf(TTbData));
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

{$ENDREGION}

{$REGION 'Protected Methods'}

procedure TFrmFSIHost.DoClose(var Action: TCloseAction);
begin
  inherited;

  Action := caFree;

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
begin
  SendDockDialogMsg(Handle, FSI_PLUGIN_WND_TITLE, '', FSI_PLUGIN_MODULE_FILENAME, FSI_INVOKE_CMD_ID, DEF_FSI_PLUGIN_WND_DOCK, 0);
end;

procedure TFrmFSIHost.createFSI;
begin
  _fsiViewer := TFSIViewer.Create;
  _fsiViewer.Editor.Align := alClient;
  _fsiViewer.Editor.Parent := self;
  _fsiViewer.OnSendText := doOnSendText;
  _fsiViewer.OnResultOutput := doOnResultOutput;
end;

procedure TFrmFSIHost.QuitFSI;
begin
  if Assigned(_fsiViewer) then
      _fsiViewer.SendText(PChar('#quit ;;' + #13#10), false, false);
end;

procedure TFrmFSIHost.doOnResultOutput(sender: TObject);
begin
  // disabled for ver 0.1
  //SendDockDialogMsg(Handle, FSI_PLUGIN_WND_TITLE, '', FSI_PLUGIN_MODULE_FILENAME, FSI_INVOKE_CMD_ID, DWS_ADDINFO, 0);
end;

procedure TFrmFSIHost.doOnSendText(sender: TObject);
begin
  // disabled for ver 0.1
  //SendDockDialogMsg(Handle, FSI_PLUGIN_WND_TITLE, 'working', FSI_PLUGIN_MODULE_FILENAME, FSI_INVOKE_CMD_ID, DWS_ADDINFO, 0);
end;

{$ENDREGION}

end.
