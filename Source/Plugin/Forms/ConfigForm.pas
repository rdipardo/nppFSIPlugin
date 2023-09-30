unit ConfigForm;

// =============================================================================
// Unit: ConfigForm
// Description: Source for the UI for configuration management
//
// Ported to Free Pascal by Robert Di Pardo, Copyright 2022, 2023
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
//
// This software incorporates work covered by the following copyright and permission notice:
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
  Forms, Classes, Controls, ExtCtrls, StdCtrls, ComCtrls, Dialogs,
  // expose TConfiguration so we can manage the lifetime of a local instance,
  // preventing memory leaks
  Config;

type
  TFrmConfiguration = class(TForm)
  private
    _config: TConfiguration;
  published
    pnlBase: TPanel;
    pnlCustomFSI: TPanel;
    grpFSISettings: TGroupBox;
    grpEditorSettings: TGroupBox;
    cmdSave: TButton;
    cmdCancel: TButton;
    lblFSIBinaryPath: TLabel;
    txtFSIBinary: TEdit;
    lblFSIBinaryArgs: TLabel;
    txtFSIBinaryArgs: TEdit;
    cmdSelectBinary: TButton;
    chkConvertToTabs: TCheckBox;
    lblConvertTabsToSpaces: TLabel;
    lblTabLength: TLabel;
    updnTabLength: TUpDown;
    txtTabLength: TEdit;
    dlgFSIBinarySelect: TOpenDialog;
    lblEchoText: TLabel;
    chkEchoText: TCheckBox;
    chkUseDotnetFsi: TCheckBox;
    lblDotnetSdkSite: TLabel;
    pnlDotNetFSI: TPanel;
    chkFoldCompact: TCheckBox;
    chkFolding: TCheckBox;
    chkFoldOpenStatements: TCheckBox;
    chkFoldPreprocessor: TCheckBox;
    chkFoldComments: TCheckBox;
    chkFoldMultiLineComments: TCheckBox;
    grpLexerProps: TGroupBox;
    pnlFoldOptions: TPanel;
    procedure FormShow(Sender: TObject);
    procedure chkUseDotnetFsiClick(Sender: TObject);
    procedure chkConvertToTabsClick(Sender: TObject);
    procedure chkConvertToTabsKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cmdSelectBinaryClick(Sender: TObject);
    procedure cmdSaveClick(Sender: TObject);
    procedure cmdCancelClick(Sender: TObject);
    procedure lblDotnetSdkSiteClick(Sender: TObject);
    procedure lblDotnetSdkSiteMouseEnter(Sender: TObject);
    procedure lblDotnetSdkSiteMouseLeave(Sender: TObject);
    procedure chkFoldingChange(Sender: TObject);
    procedure updateFoldingOption(Sender: TObject);
    procedure {$IFNDEF FPC}DestroyWindowHandle{$ELSE}DestroyWnd{$ENDIF}; override;
  private
    procedure initialize;
    procedure doOnConvertToTabsCheckBoxStateChange;
    procedure toggleFoldOptions;
    procedure saveConfiguration;
  end;

implementation

uses
  // standard units
  SysUtils, ShellApi, Windows,
  // plugin units
  Constants;

{$IFDEF FPC}
{$R *.lfm}
{$ELSE}
{$R *.dfm}
{$ENDIF}


{ TFrmConfiguration }

procedure TFrmConfiguration.FormShow(Sender: TObject);
begin
  initialize;
  doOnConvertToTabsCheckBoxStateChange;
end;

procedure TFrmConfiguration.chkUseDotnetFsiClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to pnlCustomFSI.ControlCount - 1 do
  begin
    pnlCustomFSI.controls[i].Enabled := (not chkUseDotnetFsi.Checked);
  end;
end;

procedure TFrmConfiguration.chkConvertToTabsClick(Sender: TObject);
begin
  doOnConvertToTabsCheckBoxStateChange;
end;

procedure TFrmConfiguration.chkConvertToTabsKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  doOnConvertToTabsCheckBoxStateChange;
end;

procedure TFrmConfiguration.cmdSelectBinaryClick(Sender: TObject);
begin
  if FileExists(txtFSIBinary.Text) then
    dlgFSIBinarySelect.FileName := txtFSIBinary.Text;

  if (dlgFSIBinarySelect.Execute) then
    txtFSIBinary.Text := dlgFSIBinarySelect.FileName;
end;

procedure TFrmConfiguration.cmdSaveClick(Sender: TObject);
begin
  saveConfiguration;
  Close;
end;

procedure TFrmConfiguration.cmdCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmConfiguration.initialize;
begin
  _config := TConfiguration.Create;
  chkUseDotnetFsi.Checked := _config.UseDotnet;
  txtFSIBinary.Text := _config.FSIPath;
  txtFSIBinaryArgs.Text := _config.FSIArgs;
  chkConvertToTabs.Checked := _config.ConvertTabsToSpacesInFSIEditor;
  txtTabLength.Text := IntToStr(_config.TabLength);
  chkEchoText.Checked := _config.EchoNPPTextInEditor;
  with TLexerProperties do
  begin
    chkFoldCompact.Checked := FoldCompact;
    chkFoldComments.Checked := FoldComments;
    chkFoldMultiLineComments.Checked := FoldMultiLineComments;
    chkFoldOpenStatements.Checked := FoldOpenStatements;
    chkFoldPreprocessor.Checked := FoldPreprocessor;
    chkFolding.Checked := Fold;
  end;

  toggleFoldOptions;
end;

procedure TFrmConfiguration.doOnConvertToTabsCheckBoxStateChange;
begin
  txtTabLength.Enabled := chkConvertToTabs.Checked;
  updnTabLength.Enabled := chkConvertToTabs.Checked;
end;

procedure TFrmConfiguration.saveConfiguration;
begin
  _config.UseDotnet := chkUseDotnetFsi.Checked;
  _config.FSIPath := txtFSIBinary.Text;
  _config.FSIArgs := txtFSIBinaryArgs.Text;
  _config.ConvertTabsToSpacesInFSIEditor := chkConvertToTabs.Checked;
  if (chkConvertToTabs.Checked) then
    _config.TabLength := StrToInt(txtTabLength.Text)
  else
    _config.TabLength := DEFAULT_TAB_LENGTH;
  _config.EchoNPPTextInEditor := chkEchoText.Checked;
  with TLexerProperties do
  begin
    Fold := chkFolding.Checked;
    FoldCompact := chkFoldCompact.Checked;
    FoldComments := chkFoldComments.Checked;
    FoldMultiLineComments := chkFoldMultiLineComments.Checked;
    FoldOpenStatements := chkFoldOpenStatements.Checked;
    FoldPreprocessor := chkFoldPreprocessor.Checked;
  end;

  _config.SaveToConfigFile;
end;

procedure TFrmConfiguration.toggleFoldOptions;
var
  i: integer;
begin
  for i := 0 to pnlFoldOptions.ControlCount - 1 do
  begin
    pnlFoldOptions.Controls[i].Enabled := chkFolding.Checked;
  end;
end;

procedure TFrmConfiguration.lblDotnetSdkSiteClick(Sender: TObject);
var
  url: String;
begin
  url := {$IFDEF FPC}UTF8Decode{$ENDIF}(lblDotnetSdkSite.Caption);
  ShellAPI.ShellExecute(0, 'Open', PChar(url), Nil, Nil, SW_SHOWNORMAL);
  cmdSaveClick(Sender);
end;

procedure TFrmConfiguration.lblDotnetSdkSiteMouseEnter(Sender: TObject);
begin
  lblDotnetSdkSite.Cursor := crHandPoint;
end;

procedure TFrmConfiguration.lblDotnetSdkSiteMouseLeave(Sender: TObject);
begin
  lblDotnetSdkSite.Cursor := crDefault;
end;

procedure TFrmConfiguration.updateFoldingOption(Sender: TObject);
var
  i, nOptions, nDisabled: integer;
begin
  nOptions := pnlFoldOptions.ControlCount;
  nDisabled := 0;
  for i := 0 to nOptions - 1 do
  begin
    if (not TCheckBox(pnlFoldOptions.Controls[i]).Checked) then
      Inc(nDisabled);
  end;
  chkFolding.Checked := (nOptions > nDisabled);
end;

procedure TFrmConfiguration.chkFoldingChange(Sender: TObject);
begin
  toggleFoldOptions;
end;

procedure TFrmConfiguration.{$IFNDEF FPC}DestroyWindowHandle{$ELSE}DestroyWnd{$ENDIF};
begin
  if Assigned(_config) then
    FreeAndNil(_config);

  inherited;
end;

end.
