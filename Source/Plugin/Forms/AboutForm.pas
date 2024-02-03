unit AboutForm;

// =============================================================================
// Unit: AboutForm
// Description: Source for the About dialog
//
// Ported to Free Pascal by Robert Di Pardo, Copyright 2022, 2023, 2024
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

interface

uses
  NppForms, Classes, StdCtrls, ExtCtrls;

type
  TFrmAbout = class(TNppForm)
    pnl: TPanel;
    btnOK: TButton;
    lblVersion, lblCopyright, lblGNU, lblRepo: TLabel;
    constructor Create(AOwner: TComponent); override;
    procedure SubclassAndTheme(DmfMask: Cardinal); override;
    procedure btnOKClick({%H-}Sender: TObject);
    procedure lblRepoClick(Sender: TObject);
    procedure lblRepoMouseEnter(Sender: TObject);
    procedure lblRepoMouseLeave(Sender: TObject);
  private
    class function getBuildNumber: String;
  end;

implementation

uses
  // standard units
  Windows, SysUtils, ShellAPI, Controls, Graphics,
  // plugin units
  ModulePath, VersionInfo, FSIPlugin,
  Constants
  ;

{$R *.lfm}

constructor TFrmAbout.Create(AOwner: TComponent);
var
  Build: string;
begin
  inherited Create(AOwner);
  Build := GetBuildNumber();
  lblRepo.Caption := FSI_PLUGIN_URL;
  lblVersion.Caption := Format(lblVersion.Caption, [Build, {$IFDEF CPUx64}64{$ELSE}32{$ENDIF}]);
  lblCopyright.Caption := Format(lblCopyright.Caption, [FSI_PLUGIN_AUTHOR, FSI_PLUGIN_MAINTAINER, Build]);
end;

procedure TFrmAbout.lblRepoClick(Sender: TObject);
begin
    ShellAPI.ShellExecute(0, 'Open', PChar(TLabel(Sender).Caption), Nil, Nil, SW_SHOWNORMAL);
    ModalResult := mrCancel;
end;

procedure TFrmAbout.btnOKClick({%H-}Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TFrmAbout.lblRepoMouseEnter(Sender: TObject);
begin
  TLabel(Sender).Cursor := crHandPoint;
  TLabel(Sender).Font.Style := [fsUnderline];
  if Npp.IsDarkModeEnabled then
    TLabel(Sender).Font.Color := TColor(DMF_COLOR_URL_ACTIVE);
end;

procedure TFrmAbout.lblRepoMouseLeave(Sender: TObject);
begin
  TLabel(Sender).Cursor := crDefault;
  TLabel(Sender).Font.Style := [];
  if Npp.IsDarkModeEnabled then
    TLabel(Sender).Font.Color := TColor(DMF_COLOR_URL)
  else
    TLabel(Sender).Font.Color := clHighlight;
end;

procedure TFrmAbout.SubclassAndTheme(DmfMask: Cardinal);
var
  DarkModeColors: TDarkModeColors;
begin
  inherited SubclassAndTheme(DmfMask);
  if Npp.IsDarkModeEnabled then begin
    DarkModeColors := Default(TDarkModeColors);
    Npp.GetDarkModeColors(@DarkModeColors);
    pnl.Font.Color := TColor(DarkModeColors.Text);
    lblRepo.Font.Color := TColor(DMF_COLOR_URL);
  end else begin
    pnl.Font.Color := clWindowText;
    lblRepo.Font.Color := clHighlight;
  end;
  lblVersion.Font.Color := pnl.Font.Color;
end;

class function TFrmAbout.getBuildNumber: string;
var
  FvInfo: TFileVersionInfo;
begin
  try
    FvInfo := TFileVersionInfo.Create(TModulePath.DLLFullName);
    Result := Format('%d.%d.%d.%d', [FvInfo.MajorVersion, FvInfo.MinorVersion,
      FvInfo.Revision, FvInfo.Build]);
  finally
    FreeAndNil(FvInfo);
  end;
end;

end.
