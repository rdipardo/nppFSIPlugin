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
  NppForms, Classes, Controls, ExtCtrls, StdCtrls, ComCtrls, Dialogs,
  // expose TConfiguration so we can manage the lifetime of a local instance,
  // preventing memory leaks
  Config;

type
  TFrmConfiguration = class(TNppForm)
  private
    _config: TConfiguration;
  published
    pnlBase: TPanel;
    pnlCustomFSI: TPanel;
    pnlTabSettings: TPanel;
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
    lblTabLength: TLabel;
    updnTabLength: TUpDown;
    txtTabLength: TEdit;
    dlgFSIBinarySelect: TOpenDialog;
    chkEchoText: TCheckBox;
    chkUseDotnetFsi: TCheckBox;
    chkPassArgsToDotnetFsi: TCheckBox;
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
    procedure DoCreate; override;
    procedure FormShow(Sender: TObject);
    procedure chkUseDotnetFsiClick(Sender: TObject);
    procedure chkUseArgsChanged(Sender: TObject);
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
    procedure ToggleDarkMode; override;
    procedure SubclassAndTheme(DmfMask: Cardinal); override;
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
  SysUtils, ShellApi, Windows, Graphics,
  // plugin units
  Constants, FSIPlugin;

{$IFDEF FPC}
{$R *.lfm}
{$ELSE}
{$R *.dfm}
{$ENDIF}


{ TFrmConfiguration }

procedure TFrmConfiguration.DoCreate;
begin
  inherited;
  RegisterForm;
end;

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
  chkPassArgsToDotnetFsi.Enabled := chkUseDotnetFsi.Checked;
  if chkPassArgsToDotnetFsi.Enabled then
    chkUseArgsChanged(chkPassArgsToDotnetFsi);
end;

procedure TFrmConfiguration.chkUseArgsChanged(Sender: TObject);
begin
  lblFSIBinaryArgs.Enabled := TCheckBox(Sender).Checked;
  txtFSIBinaryArgs.Enabled := TCheckBox(Sender).Checked;
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
  if not Assigned(_config) then
    _config := TConfiguration.Create;
  chkUseDotnetFsi.Checked := _config.UseDotnet;
  chkPassArgsToDotnetFsi.Checked := _config.UseArgs;
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
var
  i: integer;
begin
  for i := 0 to pnlTabSettings.ControlCount - 1 do
  begin
    pnlTabSettings.Controls[i].Enabled := chkConvertToTabs.Checked;
  end;
end;

procedure TFrmConfiguration.saveConfiguration;
begin
  _config.UseDotnet := chkUseDotnetFsi.Checked;
  _config.UseArgs := chkPassArgsToDotnetFsi.Checked;
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
  chkFolding.Enabled := True;
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
  TLabel(Sender).Font.Style := [fsUnderline];
  if Npp.IsDarkModeEnabled then
    TLabel(Sender).Font.Color := TColor(DMF_COLOR_URL_ACTIVE);
end;

procedure TFrmConfiguration.lblDotnetSdkSiteMouseLeave(Sender: TObject);
begin
  lblDotnetSdkSite.Cursor := crDefault;
  TLabel(Sender).Font.Style := [];
  if Npp.IsDarkModeEnabled then
    TLabel(Sender).Font.Color := TColor(DMF_COLOR_URL)
  else
    TLabel(Sender).Font.Color := clHighlight;
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

procedure TFrmConfiguration.ToggleDarkMode;
begin
  inherited;
  if (Self.Font.Color <> clWindowText) then begin
    txtFSIBinary.TextHint := '';
    txtFSIBinaryArgs.TextHint := '';
  end else begin
    txtFSIBinary.TextHint := txtFSIBinary.Hint;
    txtFSIBinaryArgs.TextHint := txtFSIBinaryArgs.Hint;
  end;
end;

procedure TFrmConfiguration.SubclassAndTheme(DmfMask: Cardinal);
var
  DarkModeColors: TDarkModeColors;
begin
  inherited SubclassAndTheme(DmfMask);
  SendMessage(Npp.NppData.NppHandle, NPPM_DARKMODESUBCLASSANDTHEME, DmfMask, Self.grpFSISettings.Handle);
  SendMessage(Npp.NppData.NppHandle, NPPM_DARKMODESUBCLASSANDTHEME, DmfMask, Self.grpEditorSettings.Handle);
  SendMessage(Npp.NppData.NppHandle, NPPM_DARKMODESUBCLASSANDTHEME, DmfMask, Self.grpLexerProps.Handle);
  SendMessage(Npp.NppData.NppHandle, NPPM_DARKMODESUBCLASSANDTHEME, DmfMask, Self.pnlCustomFSI.Handle);
  SendMessage(Npp.NppData.NppHandle, NPPM_DARKMODESUBCLASSANDTHEME, DmfMask, Self.pnlTabSettings.Handle);
  if Npp.IsDarkModeEnabled then begin
    DarkModeColors := Default(TDarkModeColors);
    Npp.GetDarkModeColors(@DarkModeColors);
    Color := TColor(DarkModeColors.PureBackground);
    Font.Color := TColor(DarkModeColors.Text);
    lblDotnetSdkSite.Font.Color := TColor(DMF_COLOR_URL);
  end else begin
    Color := clBtnFace;
    Font.Color := clWindowText;
    lblDotnetSdkSite.Font.Color := clHighlight;
  end;
end;

end.
