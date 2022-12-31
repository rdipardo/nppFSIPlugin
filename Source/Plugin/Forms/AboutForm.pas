unit AboutForm;

// =============================================================================
// Unit: AboutForm
// Description: Source for the About dialog
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

type
  TFrmAbout = object
    class procedure ShowModal; static;
  private
    class function getBuildNumber: String;
  end;

implementation

uses
  // standard units
  Windows, SysUtils, ShellAPI, Controls, Dialogs,
  // plugin units
  Constants
  ;

class procedure TFrmAbout.ShowModal;
const
  arch = {$IFDEF CPUx64}64{$ELSE}32{$ENDIF};
  lblFmt = '%-12s';
var
  msgText: String;
  dlgResult: Integer;
begin
  msgText := Format(lblFmt+'%s (%d-bit)'#13#10, ['Version:', GetBuildNumber, arch]);
  msgText := Concat(msgText, Format(lblFmt+'%s'#13#10, ['Web:', FSI_PLUGIN_URL]));
  msgText := Concat(msgText, 'License:'#13#10);
  msgText := Concat(msgText, Format(lblFmt+'%s', ['', #$2022' MIT (plugin source code)'#13#10]));
  msgText := Concat(msgText, Format(lblFmt+'%s', ['', #$2022' MPL 2.0 (LexFSharp, Utf8IniFiles units)'#13#10]));
  msgText := Concat(msgText, Format(lblFmt+'%s', ['', #$2022' GPL 3.0 (Notepad++ API)'#13#10]));
  msgText := Concat(msgText, Format(lblFmt+'%s', ['', #$2022' LGPL 3.0 (Scintilla API)'#13#10#13#10]));
  msgText := Concat(msgText, Format(#$00A9' 2010 %s (v0.1.0.0 - v0.1.1.0)'#13#10, [FSI_PLUGIN_AUTHOR]));
  msgText := Concat(msgText, Format(#$00A9' 2022 %s (v0.2.0.0)'#13#10#13#10, [FSI_PLUGIN_MAINTAINER]));
  msgText := Concat(msgText, 'Using the Lazarus Component Library (LCL)'#13#10);
  msgText := Concat(msgText, 'Licensed under the FPC modified LGPL Version 2'#13#10#13#10);
  msgText := Concat(msgText, UTF8Encode('Also using RichMemo, '#$00A9' Dmitry Boyarintsev'#13#10));
  msgText := Concat(msgText, 'Same license as the LCL'#13#10);
  dlgResult := (MessageDlg('About FSI Plugin For Notepad++', msgText, mtInformation, [mbOk, mbHelp], 0));
  if not (dlgResult in [mrOk, mrCancel]) then
    ShellAPI.ShellExecute(0, 'Open', PChar(FSI_PLUGIN_URL), Nil, Nil, SW_SHOWNORMAL);
end;

{$WARN SYMBOL_PLATFORM OFF}

class function TFrmAbout.getBuildNumber: String;
var
  fileVersionInfoSize, dummy: Cardinal;
  buffer: PByte;
  fileInfo: PVSFixedFileInfo;
  vsVersionInfoStart: PByte;
begin
  fileVersionInfoSize := GetFileVersionInfoSize(PChar(FSI_PLUGIN_MODULE_FILENAME), dummy);

  if (fileVersionInfoSize > 0) then
  begin
    buffer := AllocMem(fileVersionInfoSize);
    try
      if (Win32Check(GetFileVersionInfo(PChar(FSI_PLUGIN_MODULE_FILENAME), 0, fileVersionInfoSize, buffer))) then
      begin
        // the next step should be a call to VerQueryValue to get the file version; but calling
        // this function will cause an access violation in Win 7 systems; so this is a workaround
        // until a better solution can be found:
        // calculations are based on the VS_VERSIONINFO Structure
        // 36 = SizeOf(wLength) + SizeOf(wValueLength) + SizeOf(wType) + (SizeOf(Char) * Length('VS_VERSION_INFO'))
        // (4 - (DWORD(vsVersionInfoStart) mod 4)) = the padding length
        vsVersionInfoStart := buffer;
        fileInfo := PVSFixedFileInfo(vsVersionInfoStart + 36 + (4 - (DWORD(vsVersionInfoStart) mod 4)));

        with fileInfo^ do
        begin
          Result := IntToStr(dwFileVersionMS shr 16);
          Result := Result + '.' + IntToStr(dwFileVersionMS and $FFFF);
          Result := Result + '.' + IntToStr(dwFileVersionLS shr 16);
          Result := Result + '.' + IntToStr(dwFileVersionLS and $FFFF);
        end;
      end;
    finally
      FreeMem(buffer);
    end;
  end;
end;

{$WARN SYMBOL_PLATFORM ON}

end.
