unit Config;

// =============================================================================
// Unit: Config
// Description: Plugin config management.
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
// Copyright 2023 Robert Di Pardo (TLexerProperties)
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
  Graphics,
  Utf8IniFiles;

const
  DEFAULT_TAB_SETTING = -1;

type

  TPropertyInt = Boolean;

  /// <summary>
  /// Stores, retrieves and manages configuration for the plugin.
  /// </summary>
  TConfiguration = class
  private
    _configFile: WideString;
    _useDotnet: TPropertyInt;
    _passArgsToDotnetFsi: TPropertyInt;
    _fsiPath: String;
    _fsiArgs: String;
    _clStdOut, _clStdOutDark, _clStdErr, _clStdErrDark: TColor;
    _convertTabsToSpacesInFSIEditor: TPropertyInt;
    _tabLength: Integer;
    _echoNPPTextInEditor: TPropertyInt;
    _initialFoldState: TPropertyInt;
    procedure SetTabPreference(TabPref: TPropertyInt);
    procedure SetTabLength(TabLength: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromConfigFile;
    procedure SaveToConfigFile;
    property ConfigFile: WideString read _configFile;
    property UseDotnet: TPropertyInt read _useDotnet write _useDotnet;
    property UseArgs: TPropertyInt read _passArgsToDotnetFsi write _passArgsToDotnetFsi;
    property FSIPath: String read _fsiPath write _fsiPath;
    property FSIArgs: String read _fsiArgs write _fsiArgs;
    property EditorTextColor: TColor read _clStdOut write _clStdOut;
    property EditorTextColorDark: TColor read _clStdOutDark write _clStdOutDark;
    property EditorErrorColor: TColor read _clStdErr write _clStdErr;
    property EditorErrorColorDark: TColor read _clStdErrDark write _clStdErrDark;
    property ConvertTabsToSpacesInFSIEditor: TPropertyInt read _convertTabsToSpacesInFSIEditor write SetTabPreference;
    property TabLength: Integer read _tabLength write SetTabLength;
    property EchoNPPTextInEditor: TPropertyInt read _echoNPPTextInEditor write _echoNPPTextInEditor;
  end;

  TLexerProperties = class
  private
    class function GetXMLConfig: WideString; static;
    class function GetXMLSourcePath: WideString; static;
    class function GetINIConfig: WideString; static;
    class function StylerNeedsUpdate: boolean;
    class function GetProperty(const config: TUtf8IniFile; const Key: string;
      DefVal: TPropertyInt = True): TPropertyInt;
  public
    Fold: TPropertyInt; static;
    FoldCompact: TPropertyInt; static;
    FoldComments: TPropertyInt; static;
    FoldMultiLineComments: TPropertyInt; static;
    FoldOpenStatements: TPropertyInt; static;
    FoldPreprocessor: TPropertyInt; static;
    IndentWithSpaces: TPropertyInt; static;
    IndentWidth: SmallInt; static;
    class procedure CreateStyler; static;
    class procedure SetLexer; static;
    class procedure LoadProperties;
    class procedure SaveProperties(const config: TUtf8IniFile);
    class property INIConfig: WideString read GetINIConfig;
    class property XMLConfig: WideString read GetXMLConfig;
  end;

function TryParseTabSettings(var Value: LongInt): Boolean;
procedure CopyFile(const SrcPath, DestPath: WideString);

implementation

uses
  // standard units
  Classes, SysUtils, Windows, Dom, XmlRead,
  // plugin units
  Constants, ModulePath, NppPlugin, FSIPlugin;

var
  TabPrefValue: LongInt = DEFAULT_TAB_SETTING;

{ TConfiguration }

{$REGION 'Constructor & Destructor'}

constructor TConfiguration.Create;
begin
  _configFile := TLexerProperties.INIConfig;
  loadFromConfigFile;
end;

destructor TConfiguration.Destroy;
begin
  inherited;
end;

{$ENDREGION}

{$REGION 'Public Methods'}

procedure TConfiguration.LoadFromConfigFile;
var
  configINI: TUtf8IniFile;
begin
    configINI := TUtf8IniFile.Create(_configFile);
    try
      _useDotnet := configINI.ReadBool(CONFIG_FSI_SECTION_NAME, CONFIG_FSI_SECTION_USE_DOTNET_FSI, True);
      _passArgsToDotnetFsi := configINI.ReadBool(CONFIG_FSI_SECTION_NAME, CONFIG_FSI_SECTION_PASS_ARGS_TO_DOTNET_FSI, False);
      _fsiPath := configINI.ReadString(CONFIG_FSI_SECTION_NAME, CONFIG_FSI_SECTION_BINARY_KEY_NAME, EmptyStr);
      _fsiArgs := configINI.ReadString(CONFIG_FSI_SECTION_NAME, CONFIG_FSI_SECTION_BINARYARGS_KEY_NAME, EmptyStr);
      SetTabPreference(configINI.ReadBool(CONFIG_FSIEDITOR_SECTION_NAME, CONFIG_FSIEDITOR_SECTION_TABTOSPACES_KEY_NAME, True));
      SetTabLength(configINI.ReadInteger(CONFIG_FSIEDITOR_SECTION_NAME, CONFIG_FSIEDITOR_SECTION_TABLENGTH_KEY_NAME, DEFAULT_TAB_LENGTH));
      _echoNPPTextInEditor := configINI.ReadBool(CONFIG_FSIEDITOR_SECTION_NAME, CONFIG_FSIEDITOR_ECHO_NPP_TEXT_KEY_NAME, True);
      _clStdOut := TColor(configINI.ReadInteger(CONFIG_FSIEDITOR_SECTION_NAME, 'TEXT_COLOR', clBlack));
      _clStdErr := TColor(configINI.ReadInteger(CONFIG_FSIEDITOR_SECTION_NAME, 'ERROR_TEXT_COLOR', clRed));
      _clStdOutDark := TColor(configINI.ReadInteger(CONFIG_FSIEDITOR_SECTION_NAME, 'DARK_MODE_TEXT_COLOR', clWhite));
      _clStdErrDark := TColor(configINI.ReadInteger(CONFIG_FSIEDITOR_SECTION_NAME, 'DARK_MODE_ERROR_TEXT_COLOR', DMF_COLOR_ERROR_TEXT));
    finally
      configINI.Free;
    end;
  TLexerProperties.LoadProperties;
  _initialFoldState := TLexerProperties.Fold;
end;

procedure TConfiguration.SaveToConfigFile;
var
  configINI: TUtf8IniFile;
begin
  configINI := TUtf8IniFile.Create(_configFile);
  try
    configINI.WriteBool(CONFIG_FSI_SECTION_NAME, CONFIG_FSI_SECTION_USE_DOTNET_FSI, _useDotnet);
    configINI.WriteBool(CONFIG_FSI_SECTION_NAME, CONFIG_FSI_SECTION_PASS_ARGS_TO_DOTNET_FSI, _passArgsToDotnetFsi);
    configINI.WriteString(CONFIG_FSI_SECTION_NAME, CONFIG_FSI_SECTION_BINARY_KEY_NAME, _fsiPath);
    configINI.WriteString(CONFIG_FSI_SECTION_NAME, CONFIG_FSI_SECTION_BINARYARGS_KEY_NAME, _fsiArgs);
    if not TryParseTabSettings(TabPrefValue) then
    begin
      configINI.WriteBool(CONFIG_FSIEDITOR_SECTION_NAME, CONFIG_FSIEDITOR_SECTION_TABTOSPACES_KEY_NAME, _convertTabsToSpacesInFSIEditor);
      configINI.WriteInteger(CONFIG_FSIEDITOR_SECTION_NAME, CONFIG_FSIEDITOR_SECTION_TABLENGTH_KEY_NAME, _tabLength);
    end;
    configINI.WriteBool(CONFIG_FSIEDITOR_SECTION_NAME, CONFIG_FSIEDITOR_ECHO_NPP_TEXT_KEY_NAME, _echoNPPTextInEditor);
    configINI.WriteInteger(CONFIG_FSIEDITOR_SECTION_NAME, 'TEXT_COLOR', ColorToRGB(_clStdOut));
    configINI.WriteInteger(CONFIG_FSIEDITOR_SECTION_NAME, 'ERROR_TEXT_COLOR', ColorToRGB(_clStdErr));
    configINI.WriteInteger(CONFIG_FSIEDITOR_SECTION_NAME, 'DARK_MODE_TEXT_COLOR', ColorToRGB(_clStdOutDark));
    configINI.WriteInteger(CONFIG_FSIEDITOR_SECTION_NAME, 'DARK_MODE_ERROR_TEXT_COLOR', ColorToRGB(_clStdErrDark));
    TLexerProperties.SaveProperties(configINI);
  finally
    configINI.Free;
  end;
  TLexerProperties.SetLexer;
  if (_initialFoldState = True) and (not TLexerProperties.Fold) then
    MessageBoxW(Npp.NppData.nppHandle, PWchar('Reload F# files to apply changes.'),
      PWchar('File Reload Required'), MB_ICONINFORMATION);
end;
{$ENDREGION}

{%Region 'Private Methods'}
procedure TConfiguration.SetTabPreference(TabPref: TPropertyInt);
begin
  _convertTabsToSpacesInFSIEditor := TabPref;
  if TryParseTabSettings(TabPrefValue) then
    _convertTabsToSpacesInFSIEditor := TPropertyInt(TabPrefValue shr 7);
end;

procedure TConfiguration.SetTabLength(TabLength: Integer);
begin
  _tabLength := TabLength;
  if TryParseTabSettings(TabPrefValue) then
    _tabLength := TabPrefValue and $7f;
end;
{%EndRegion}

{ TLexerProperties }

class procedure TLexerProperties.CreateStyler;
begin
  if (not FileExists(XMLConfig)) then
    CopyFile(GetXMLSourcePath, XMLConfig)
  else if Npp.SupportsILexer and StylerNeedsUpdate then
  begin
    CopyFile(XMLConfig, XMLConfig + '.bak');
    CopyFile(GetXMLSourcePath, XMLConfig);
  end;
end;

class procedure TLexerProperties.SetLexer;
const
  SCLEX_FSHARP = 132; { lexilla/include/SciLexer.h }
var
  DirectProc: SciFnDirect;
  HSciWnd, PSciDirect: HWND;
  statusBarText, ext: WideString;

  procedure SetProperty(const Key: string; Value: TPropertyInt);
  begin
    DirectProc(PSciDirect, SCI_SETPROPERTY, WPARAM(PChar(Key)),
      LPARAM(PChar(BoolToStr(Value, '1', '0'))));
  end;
begin
  HSciWnd := Npp.CurrentScintilla;
  if SendMessageW(HSciWnd, SCI_GETLEXER, 0, 0) <> SCLEX_FSHARP then
    Exit;

  ext := Npp.GetCurrentFileExt;
  if WideSameText(ext, '.fsx') or WideSameText(ext, '.fsscript') then
    statusBarText := 'F# script file'
  else if WideSameText(ext, '.fsi') then
    statusBarText := 'F# signature file'
  else
    statusBarText := 'F# source file';

  SendMessageW(Npp.NppData.nppHandle, NppPlugin.NPPM_SETSTATUSBAR, NppPlugin.STATUSBAR_DOC_TYPE,
    LPARAM(PWChar(statusBarText)));

  DirectProc := SciFnDirect(SendMessageW(HSciWnd, SCI_GETDIRECTFUNCTION, 0, 0));
  PSciDirect := SendMessageW(HSciWnd, SCI_GETDIRECTPOINTER, 0, 0);

  LoadProperties;
  SetProperty('fold', Fold);
  SetProperty('fold.compact', FoldCompact);
  SetProperty('fold.fsharp.comment.stream', FoldComments);
  SetProperty('fold.fsharp.comment.multiline', FoldMultiLineComments);
  SetProperty('fold.fsharp.imports', FoldOpenStatements);
  SetProperty('fold.fsharp.preprocessor', FoldPreprocessor);
  DirectProc(PSciDirect, SCI_SETUSETABS, (not IndentWithSpaces).ToInteger(), 0);
  DirectProc(PSciDirect, SCI_SETTABWIDTH, IndentWidth, 0);
end;

class procedure TLexerProperties.LoadProperties;
var
  configINI: TUtf8IniFile;
begin
  try
    configINI := TUtf8IniFile.Create(INIConfig);

    Fold := GetProperty(configINI, 'CODE_FOLDING');
    FoldCompact := GetProperty(configINI, 'FOLD_EMPTY_LINES', False);
    FoldComments := GetProperty(configINI, 'FOLD_COMMENTS');
    FoldMultiLineComments := GetProperty(configINI, 'FOLD_MULTILINE_COMMENTS');
    FoldOpenStatements := GetProperty(configINI, 'FOLD_OPEN_STATEMENTS');
    FoldPreprocessor := GetProperty(configINI, 'FOLD_PREPROCESSOR');
    if TryParseTabSettings(TabPrefValue) then
    begin
      IndentWithSpaces := TPropertyInt(TabPrefValue shr 7);
      IndentWidth := TabPrefValue and $7f;
    end else begin
      IndentWithSpaces := configINI.ReadBool(CONFIG_FSIEDITOR_SECTION_NAME, CONFIG_FSIEDITOR_SECTION_TABTOSPACES_KEY_NAME, True);
      IndentWidth := configINI.ReadInteger(CONFIG_FSIEDITOR_SECTION_NAME, CONFIG_FSIEDITOR_SECTION_TABLENGTH_KEY_NAME, DEFAULT_TAB_LENGTH);
    end;
  finally
    FreeAndNil(configINI);
  end;
end;

class procedure TLexerProperties.SaveProperties(const config: TUtf8IniFile);
begin
  config.WriteBool('LEXER_PROPERTIES', 'CODE_FOLDING', Fold);
  config.WriteBool('LEXER_PROPERTIES', 'FOLD_EMPTY_LINES', FoldCompact);
  config.WriteBool('LEXER_PROPERTIES', 'FOLD_COMMENTS', FoldComments);
  config.WriteBool('LEXER_PROPERTIES', 'FOLD_MULTILINE_COMMENTS', FoldMultiLineComments);
  config.WriteBool('LEXER_PROPERTIES', 'FOLD_OPEN_STATEMENTS', FoldOpenStatements);
  config.WriteBool('LEXER_PROPERTIES', 'FOLD_PREPROCESSOR', FoldPreprocessor);
end;

class function TLexerProperties.GetXMLConfig: WideString; static;
begin
  Result := ChangeFilePath(nppString(ChangeFileExt(FSI_PLUGIN_MODULE_FILENAME, '.xml')), Npp.GetUserConfigDirectory);
end;

class function TLexerProperties.GetXMLSourcePath: WideString; static;
begin
  Result := ChangeFilePath(nppString(ChangeFileExt(FSI_PLUGIN_MODULE_FILENAME, '.xml')), TModulePath.DLL + 'Config');
end;

class function TLexerProperties.GetINIConfig: WideString;
begin
  Result := ChangeFilePath('options.ini', Npp.GetPluginConfigDirectory);
end;

class function TLexerProperties.GetProperty(const config: TUtf8IniFile;
  const Key: string; DefVal: TPropertyInt): TPropertyInt;
begin
  Result := config.ReadBool('LEXER_PROPERTIES', Key, DefVal);
end;

class function TLexerProperties.StylerNeedsUpdate: boolean;
var
  Doc: TXMLDocument;
  Root, LangNode: TDOMNode;
  hXMLFile: THandle;
  fStream: TStream;
begin
  Doc := nil;
  fStream := nil;
  Result := False;
  try
    hXMLFile := FileOpen(XMLConfig, fmOpenRead);
    if hXMLFile <> THandle(-1) then
    begin
      fStream := THandleStream.Create(hXMLFile);
      try
        ReadXMLFile(Doc, fStream);
      except
        on E: Exception do
        begin
          MessageBoxW(0,
            PWideChar(WideFormat('Cannot read %s.%sPlease remove the file and restart Notepad++',
            [XMLConfig, #13#10#13#10])),
            PWideChar(FSI_PLUGIN_NAME), MB_ICONERROR);
        end;
      end;
      if Assigned(Doc) then
      begin
        Root := Doc.DocumentElement.FirstChild;
        while Assigned(Root) do
        begin
          if UnicodeSameText(Root.NodeName, 'language') then
          begin
            if Assigned(Root.Attributes) then
            begin
              LangNode := Root.Attributes.GetNamedItem('name');
              if Assigned(LangNode) then
              begin
                Result := not UnicodeSameText(LangNode.NodeValue, 'F#');
                Break;
              end;
            end;
          end;
          Root := Root.FirstChild;
        end;
      end;
    end;
  finally
    FileClose(hXMLFile);
    if Assigned(Doc) then
      FreeAndNil(Doc);
    if Assigned(fStream) then
      FreeAndNil(fStream);
  end;
end;

{ ------------------------------------------------------------------------------------------------ }
procedure CopyFile(const SrcPath, DestPath: WideString);
var
  hSrc, hDest: THandle;
  Text: TBytes;
  bytesWritten: LongInt;
  DestDir: WideString;
begin
  bytesWritten := -1;
  try
    try
      hSrc := FileOpen(SrcPath, fmOpenRead or fmShareDenyWrite);
      if hSrc <> THandle(-1) then
      begin
        DestDir := ExtractFileDir(DestPath);
        if (not DirectoryExists(DestDir)) and (not CreateDir(DestDir)) then
            raise Exception.Create(Format('Directory "%s" is not writable', [UTF8Encode(DestDir)]));
        Text := GetFileContents(hSrc);
        hDest := FileCreate(DestPath);
        if (hDest <> THandle(-1)) and (Length(Text) > 0) then
          bytesWritten := FileWrite(hDest, RawByteString(Text)[1], Length(Text));
      end;
      if (bytesWritten = -1) then
        MessageBoxW(0, PWideChar(WideFormat('Could not copy "%s" to "%s"',
          [SrcPath, DestPath])),
          PWideChar('File System Error'), MB_ICONERROR);
    finally
      FileClose(hSrc);
      FileClose(hDest);
    end;
  except
    on E: Exception do
    begin
      MessageBoxW(0, PWideChar(UTF8Decode(E.Message)), PWideChar('Error'), MB_ICONERROR);
    end;
  end;
end;

{ ------------------------------------------------------------------------------------------------ }
function TryParseTabSettings(var Value: LongInt): Boolean;
var
  Doc: TXMLDocument;
  Root, TabSettingsNode: TDOMNode;
  hXMLFile: THandle;
  fStream: TStream;
  ParseResult: Word;
begin
  Doc := nil;
  fStream := nil;
  Result := False;
  try
    hXMLFile := FileOpen(TLexerProperties.XMLConfig, fmOpenRead);
    if hXMLFile <> THandle(-1) then
    begin
      fStream := THandleStream.Create(hXMLFile);
      try
        ReadXMLFile(Doc, fStream);
      except
        on E: Exception do
        begin
        end;
      end;
      if Assigned(Doc) then
      begin
        Root := Doc.DocumentElement.FirstChild;
        while Assigned(Root) do
        begin
          if UnicodeSameText(Root.NodeName, 'language') then
          begin
            if Assigned(Root.Attributes) then
            begin
              TabSettingsNode := Root.Attributes.GetNamedItem('tabSettings');
              if Assigned(TabSettingsNode) then
              begin
                Val (TabSettingsNode.NodeValue, Value, ParseResult);
                Result := (ParseResult = 0) and (Value > 0);
                Break;
              end;
            end;
          end;
          Root := Root.FirstChild;
        end;
      end;
    end;
  finally
    FileClose(hXMLFile);
    if Assigned(Doc) then
      FreeAndNil(Doc);
    if Assigned(fStream) then
      FreeAndNil(fStream);
  end;
end;

end.
