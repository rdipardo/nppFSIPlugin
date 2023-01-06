unit LexFSharp;

(*
  Copyright (c) 2022 Robert Di Pardo <dipardo.r@gmail.com>

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this file,
  You can obtain one at https://mozilla.org/MPL/2.0/.
*)

{$IFDEF FPC}{$mode delphi}{$ENDIF}

interface

uses Utf8IniFiles;

const
  { lexilla/include/SciLexer.h }
  SCLEX_FSHARP = 132;

  { PowerEditor/src/ScintillaComponent/ScintillaEditView.cpp }
  _SC_MARGE_FOLDER = 3;

function StrToRGB(const HexStr: string; const defaultColor: cardinal = 0): cardinal;

type
  TLexFSharp = class
  private
    class function GetConfig: WideString; static;
    class function GetProperty(const config: TUtf8IniFile; const Key: string): string;
    class procedure SetProperty(const Key: string; const Value: string = '1');
    class procedure SetKeywords(const config: TUtf8IniFile; SetId: LongInt;
      const SetName: string = 'KEYWORDS');
    class procedure StyleSetFore(const config: TUtf8IniFile; StyleId: LongInt;
      const Name: string; Bold: boolean = False; Italic: boolean = False;
      Underline: boolean = False);
  public
    class procedure Lex; static;
    class procedure Init; static;
    class function CurrentFileIsFSharp: boolean; static;
    class property LexerConfig: WideString read GetConfig;
  end;

implementation

uses Classes, SysUtils, Windows, Constants, Npp;

class procedure TLexFSharp.Lex;
const
  statusBarText: WideString = 'F# Source File';
  foldMarginWidth = 18;
var
  lexerIniFile: TUtf8IniFile;
begin
  if (not Npp.SupportsILexer) or (not CurrentFileIsFSharp) or (not FileExists(LexerConfig)) then
    Exit;

  SetILexer('fsharp');
  if SendMessageW(GetActiveEditorHandle, SCI_GETLEXER, 0, 0) <> SCLEX_FSHARP then
    Exit;

  SendMessageW(NppData._nppHandle, NPPM_SETSTATUSBAR, STATUSBAR_DOC_TYPE,
    LPARAM(PWChar(statusBarText)));

  try
    lexerIniFile := TUtf8IniFile.Create(LexerConfig);

    // set keyword lists
    SetKeywords(lexerIniFile, 1);
    SetKeywords(lexerIniFile, 2);
    SetKeywords(lexerIniFile, 3);
    SetKeywords(lexerIniFile, 4);
    SetKeywords(lexerIniFile, 5);

    // set lexical styles
    // StyleSetFore(lexerIniFile, 0, 'DEFAULT'); { never set so that style adapts to current theme }
    StyleSetFore(lexerIniFile, 1, 'KEYWORDS_1', True);
    StyleSetFore(lexerIniFile, 2, 'KEYWORDS_2', True);
    StyleSetFore(lexerIniFile, 3, 'KEYWORDS_3', True);
    StyleSetFore(lexerIniFile, 4, 'KEYWORDS_4', True);
    StyleSetFore(lexerIniFile, 5, 'KEYWORDS_5', True);
    // StyleSetFore(lexerIniFile, 6, 'IDENTIFIER'); { as above }
    StyleSetFore(lexerIniFile, 7, 'QUOTED_IDENTIFIER');
    StyleSetFore(lexerIniFile, 8, 'COMMENT', False, True);
    StyleSetFore(lexerIniFile, 9, 'COMMENT_LINE', False, True);
    StyleSetFore(lexerIniFile, 10, 'PREPROCESSOR', True, True);
    StyleSetFore(lexerIniFile, 11, 'LINE_NUMBER', True, True);
    StyleSetFore(lexerIniFile, 12, 'OPERATOR', True);
    StyleSetFore(lexerIniFile, 13, 'NUMBER', True);
    StyleSetFore(lexerIniFile, 14, 'CHARACTER');
    StyleSetFore(lexerIniFile, 15, 'STRING');
    StyleSetFore(lexerIniFile, 16, 'VERBATIM_STRING');
    StyleSetFore(lexerIniFile, 17, 'QUOTATION');
    StyleSetFore(lexerIniFile, 18, 'ATTRIBUTE');
    StyleSetFore(lexerIniFile, 19, 'PRINTF_FORMAT_SPECIFIER');

    // set properties
    // SetProperty('fold'); { should be unnecessary }
    SetProperty('fold.compact', '0');
    SetProperty('fold.fsharp.comment.stream', GetProperty(lexerIniFile,
      'FOLD_COMMENTS'));
    SetProperty('fold.fsharp.comment.multiline', GetProperty(lexerIniFile,
      'FOLD_LINE_COMMENTS'));
    SetProperty('fold.fsharp.imports', GetProperty(lexerIniFile, 'FOLD_IMPORTS'));
    SetProperty('fold.fsharp.preprocessor', GetProperty(lexerIniFile,
      'FOLD_PREPROCESSOR'));

    // lex document
    SendMessageW(GetActiveEditorHandle, SCI_COLOURISE, 0, -1);

    // show fold margin
    SendMessageW(GetActiveEditorHandle, SCI_SETMARGINWIDTHN, _SC_MARGE_FOLDER,
      foldMarginWidth);
  finally
    FreeAndNil(lexerIniFile);
  end;
end;

class procedure TLexFSharp.SetKeywords(const config: TUtf8IniFile;
  SetId: LongInt; const SetName: string);
var
  keywordList: string;
begin
  keywordList := config.ReadString('LEXER_KEYWORDS', SetName + '_' + IntToStr(SetId), '');
  SendMessageW(GetActiveEditorHandle, SCI_SETKEYWORDS, SetId - 1, LPARAM(PChar(keywordList)));
end;

class procedure TLexFSharp.StyleSetFore(const config: TUtf8IniFile;
  StyleId: LongInt; const Name: string; Bold: boolean; Italic: boolean;
  Underline: boolean);
var
  Color: cardinal;
begin
  Color := StrToRGB(config.ReadString('LEXER_STYLES', Name, '0'));
  SendMessageW(GetActiveEditorHandle, SCI_STYLESETFORE, StyleId, Color);
  if Bold then SendMessageW(GetActiveEditorHandle, SCI_STYLESETBOLD, StyleId, 1);
  if Italic then SendMessageW(GetActiveEditorHandle, SCI_STYLESETITALIC, StyleId, 1);
  if Underline then SendMessageW(GetActiveEditorHandle, SCI_STYLESETUNDERLINE, StyleId, 1);
end;

class function TLexFSharp.GetProperty(const config: TUtf8IniFile; const Key: string): string;
begin
  Result := IntToStr(config.ReadInteger('LEXER_PROPERTIES', Key, 1));
end;

class procedure TLexFSharp.SetProperty(const Key, Value: string);
begin
  SendMessageW(GetActiveEditorHandle, SCI_SETPROPERTY, WPARAM(PChar(Key)),
    LPARAM(PChar(Value)));
end;

class function TLexFSharp.CurrentFileIsFSharp: boolean;
const
  extLen = 16;
var
  extBuffer: array [0..extLen] of widechar;
  ext: WideString;
begin
  SendMessageW(NppData._nppHandle, NPPM_GETEXTPART, extLen, LPARAM(@extBuffer[0]));
  SetString(ext, PWChar(@extBuffer[0]), StrLen(PWChar(@extBuffer[0])));
  Result := WideSameText(ext, '.fs') or WideSameText(ext, '.fsx') or
    WideSameText(ext, '.fsi') or WideSameText(ext, '.fsscript');
end;

class function TLexFSharp.GetConfig: WideString;
begin
  Result := WideFormat('%s%s%s', [GetPluginConfigDirectory, PathDelim, 'LexFSharp.ini']);
end;

class procedure TLexFSharp.Init;
var
  lexerIniFile: TUtf8IniFile;
begin
  if (not Npp.SupportsILexer) then
    Exit
  else if not FileExists(LexerConfig) then
  begin
    try
      lexerIniFile := TUtf8IniFile.Create(LexerConfig);

      // lexerIniFile.WriteString('LEXER_STYLES', 'DEFAULT', '#000000');
      lexerIniFile.WriteString('LEXER_STYLES', 'KEYWORDS_1', '#A082BD');
      lexerIniFile.WriteString('LEXER_STYLES', 'KEYWORDS_2', '#008080');
      lexerIniFile.WriteString('LEXER_STYLES', 'KEYWORDS_3', '#93CDBA');
      lexerIniFile.WriteString('LEXER_STYLES', 'KEYWORDS_4', '#378BBA');
      lexerIniFile.WriteString('LEXER_STYLES', 'KEYWORDS_5', '#BC8F8F');
      // lexerIniFile.WriteString('LEXER_STYLES', 'IDENTIFIER', '#000000');
      lexerIniFile.WriteString('LEXER_STYLES', 'QUOTED_IDENTIFIER', '#B72F14');
      lexerIniFile.WriteString('LEXER_STYLES', 'COMMENT', '#679D47');
      lexerIniFile.WriteString('LEXER_STYLES', 'COMMENT_LINE', '#679D47');
      lexerIniFile.WriteString('LEXER_STYLES', 'PREPROCESSOR', '#BC8F8F');
      lexerIniFile.WriteString('LEXER_STYLES', 'LINE_NUMBER', '#BC8F8F');
      lexerIniFile.WriteString('LEXER_STYLES', 'OPERATOR', '#AC93AC');
      lexerIniFile.WriteString('LEXER_STYLES', 'NUMBER', '#F08080');
      lexerIniFile.WriteString('LEXER_STYLES', 'CHARACTER', '#CD6000');
      lexerIniFile.WriteString('LEXER_STYLES', 'STRING', '#CD6000');
      lexerIniFile.WriteString('LEXER_STYLES', 'VERBATIM_STRING', '#B72F14');
      lexerIniFile.WriteString('LEXER_STYLES', 'QUOTATION', '#378BF0');
      lexerIniFile.WriteString('LEXER_STYLES', 'ATTRIBUTE', '#378BBA');
      lexerIniFile.WriteString('LEXER_STYLES', 'PRINTF_FORMAT_SPECIFIER', '#BF8CE1');
      lexerIniFile.WriteString('LEXER_KEYWORDS', 'KEYWORDS_1', FSHARP_KEYWORDS_1);
      lexerIniFile.WriteString('LEXER_KEYWORDS', 'KEYWORDS_2', FSHARP_KEYWORDS_2);
      lexerIniFile.WriteString('LEXER_KEYWORDS', 'KEYWORDS_3', FSHARP_KEYWORDS_3);
      lexerIniFile.WriteString('LEXER_KEYWORDS', 'KEYWORDS_4', FSHARP_KEYWORDS_4);
    finally
      FreeAndNil(lexerIniFile);
    end;
  end;
  if not FileExists(LexerConfig) then
    MessageBoxW(NppData._nppHandle,
      PWideChar(WideFormat('Could not write %s', [LexerConfig])),
      'File System Error', MB_ICONERROR);
end;

function StrToRGB(const HexStr: string; const defaultColor: cardinal = 0): cardinal;
var
  colorInt, r, g, b: cardinal;
begin
  colorInt := StrToIntDef(StringReplace(HexStr, '#', '$', []), defaultColor);
  r := (colorInt shr 16) and $FF;
  g := (colorInt shr 8) and $FF;
  b := colorInt and $FF;
  Result := (r or (g shl 8) or (b shl 16));
end;

end.
