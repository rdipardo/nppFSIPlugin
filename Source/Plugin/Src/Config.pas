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

uses Utf8IniFiles;

type

  TPropertyInt = Boolean;

  /// <summary>
  /// Stores, retrieves and manages configuration for the plugin.
  /// </summary>
  TConfiguration = class
  private
    _configFile: WideString;
    _useDotnet: TPropertyInt;
    _fsiPath: String;
    _fsiArgs: String;
    _convertTabsToSpacesInFSIEditor: TPropertyInt;
    _tabLength: Integer;
    _echoNPPTextInEditor: TPropertyInt;
    _initialFoldState: TPropertyInt;
  private
    procedure initializeConfiguration;
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure LoadFromConfigFile;
    procedure SaveToConfigFile;
  public
    property ConfigFile: WideString read _configFile;
    property UseDotnet: Boolean read _useDotnet write _useDotnet;
    property FSIPath: String read _fsiPath write _fsiPath;
    property FSIArgs: String read _fsiArgs write _fsiArgs;
    property ConvertTabsToSpacesInFSIEditor: Boolean read _convertTabsToSpacesInFSIEditor write _convertTabsToSpacesInFSIEditor;
    property TabLength: Integer read _tabLength write _tabLength;
    property EchoNPPTextInEditor: Boolean read _echoNPPTextInEditor write _echoNPPTextInEditor;
  end;

  TLexerProperties = class
  private
    class function GetXMLConfig: WideString; static;
    class function GetXMLSourcePath: WideString; static;
    class function GetINIConfig: WideString; static;
    class function GetProperty(const config: TUtf8IniFile; const Key: string;
      DefVal: TPropertyInt = True): TPropertyInt;
    class procedure SetProperty(const Key: string; Value: TPropertyInt);
  public
    Fold: TPropertyInt; static;
    FoldCompact: TPropertyInt; static;
    FoldComments: TPropertyInt; static;
    FoldMultiLineComments: TPropertyInt; static;
    FoldOpenStatements: TPropertyInt; static;
    FoldPreprocessor: TPropertyInt; static;
    class procedure CreateStyler; static;
    class procedure SetLexer; static;
    class procedure LoadProperties;
    class procedure SaveProperties(const config: TUtf8IniFile);
    class property INIConfig: WideString read GetINIConfig;
    class property XMLConfig: WideString read GetXMLConfig;
  end;

procedure CopyFile(const SrcPath, DestPath: WideString);

implementation

uses
  // standard units
  SysUtils, Windows,
  // plugin units
  Constants, ModulePath, NppPlugin, FSIPlugin;

{ TConfiguration }

{$REGION 'Constructor & Destructor'}

constructor TConfiguration.Create;
begin
  initializeConfiguration;
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
  if FileExists(_configFile) then
  begin
    configINI := TUtf8IniFile.Create(_configFile);
    try
      _useDotnet := configINI.ReadBool(CONFIG_FSI_SECTION_NAME, CONFIG_FSI_SECTION_USE_DOTNET_FSI, True);
      _fsiPath := configINI.ReadString(CONFIG_FSI_SECTION_NAME, CONFIG_FSI_SECTION_BINARY_KEY_NAME, EmptyStr);
      _fsiArgs := configINI.ReadString(CONFIG_FSI_SECTION_NAME, CONFIG_FSI_SECTION_BINARYARGS_KEY_NAME, EmptyStr);
      _convertTabsToSpacesInFSIEditor := configINI.ReadBool(CONFIG_FSIEDITOR_SECTION_NAME, CONFIG_FSIEDITOR_SECTION_TABTOSPACES_KEY_NAME, True);
      _tabLength := configINI.ReadInteger(CONFIG_FSIEDITOR_SECTION_NAME, CONFIG_FSIEDITOR_SECTION_TABLENGTH_KEY_NAME, DEFAULT_TAB_LENGTH);
      _echoNPPTextInEditor := configINI.ReadBool(CONFIG_FSIEDITOR_SECTION_NAME, CONFIG_FSIEDITOR_ECHO_NPP_TEXT_KEY_NAME, True);
    finally
      configINI.Free;
    end;
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
    configINI.WriteString(CONFIG_FSI_SECTION_NAME, CONFIG_FSI_SECTION_BINARY_KEY_NAME, _fsiPath);
    configINI.WriteString(CONFIG_FSI_SECTION_NAME, CONFIG_FSI_SECTION_BINARYARGS_KEY_NAME, _fsiArgs);
    configINI.WriteBool(CONFIG_FSIEDITOR_SECTION_NAME, CONFIG_FSIEDITOR_SECTION_TABTOSPACES_KEY_NAME, _convertTabsToSpacesInFSIEditor);
    configINI.WriteInteger(CONFIG_FSIEDITOR_SECTION_NAME, CONFIG_FSIEDITOR_SECTION_TABLENGTH_KEY_NAME, _tabLength);
    configINI.WriteBool(CONFIG_FSIEDITOR_SECTION_NAME, CONFIG_FSIEDITOR_ECHO_NPP_TEXT_KEY_NAME, _echoNPPTextInEditor);
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

{$REGION 'Private methods'}

procedure TConfiguration.initializeConfiguration;
begin
  _configFile := TLexerProperties.INIConfig;
  _useDotnet := True;
  _fsiPath := EmptyStr;
  _fsiArgs := EmptyStr;
  _convertTabsToSpacesInFSIEditor := True;
  _tabLength := DEFAULT_TAB_LENGTH;
  _echoNPPTextInEditor := True;
  TLexerProperties.LoadProperties;
end;

{$ENDREGION}

{ TLexerProperties }

class procedure TLexerProperties.CreateStyler;
begin
  if (not FileExists(XMLConfig)) then
    CopyFile(GetXMLSourcePath, XMLConfig);
end;

class procedure TLexerProperties.SetLexer;
const
  SCLEX_FSHARP = 132; { lexilla/include/SciLexer.h }
var
  statusBarText, ext: WideString;
begin
  if SendMessageW(Npp.CurrentScintilla, NppPlugin.SCI_GETLEXER, 0, 0) <> SCLEX_FSHARP then
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

  LoadProperties;
  SetProperty('fold', Fold);
  SetProperty('fold.compact', FoldCompact);
  SetProperty('fold.fsharp.comment.stream', FoldComments);
  SetProperty('fold.fsharp.comment.multiline', FoldMultiLineComments);
  SetProperty('fold.fsharp.imports', FoldOpenStatements);
  SetProperty('fold.fsharp.preprocessor', FoldPreprocessor);
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
  Result := WideFormat('%s%s%s', [Npp.GetUserConfigDirectory, PathDelim,
    ChangeFileExt(FSI_PLUGIN_MODULE_FILENAME, '.xml')]);
end;

class function TLexerProperties.GetXMLSourcePath: WideString; static;
begin
  Result := WideFormat('%s%s%s%s', [TModulePath.DLL, 'Config', PathDelim,
    ChangeFileExt(FSI_PLUGIN_MODULE_FILENAME, '.xml')]);
end;

class function TLexerProperties.GetINIConfig: WideString;
begin
  Result := WideFormat('%s%s%s', [Npp.GetPluginConfigDirectory, PathDelim,
    ChangeFileExt(FSI_PLUGIN_MODULE_FILENAME, '.ini')]);
end;

class function TLexerProperties.GetProperty(const config: TUtf8IniFile;
  const Key: string; DefVal: TPropertyInt): TPropertyInt;
begin
  Result := config.ReadBool('LEXER_PROPERTIES', Key, DefVal);
end;

class procedure TLexerProperties.SetProperty(const Key: string; Value: TPropertyInt);
begin
  SendMessageW(Npp.CurrentScintilla, NppPlugin.SCI_SETPROPERTY, WPARAM(PChar(Key)),
    LPARAM(PChar(BoolToStr(Value, '1', '0'))));
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

end.
