unit ILexerExports;

// =============================================================================
// Unit: ILexerExports
// Description: Basic implementation of Lexilla's ILexer5 protocol
//              https://www.scintilla.org/LexillaDoc.html
// Copyright 2023 Robert Di Pardo, MIT License
// =============================================================================

interface

/// Since Npp v8.4, the addresses of these functions are required by PluginsManager::loadPluginFromPath()
function GetLexerCount: Integer; stdcall;
function CreateLexer(const Name: PAnsiChar): NativeInt; stdcall;
procedure GetLexerName({%H-}LexerIndex: Cardinal; Name: PAnsiChar; BufLength: Integer); stdcall;

/// Unused since Npp v8.4, but needed to prevent a load exception in older versions
procedure GetLexerStatusText({%H-}LexerIndex: Cardinal; Name: PWideChar; BufLength: Integer); stdcall;

implementation

uses SysUtils, Npp;

function GetLexerCount: Integer; stdcall;
begin
  Result := 1;
end;

function CreateLexer(const Name: PAnsiChar): NativeInt; stdcall;
begin
  Result := 0;
  if SameText(Name, 'fsharp') then
    Result := GetILexerPtr('fsharp');
end;

procedure GetLexerName({%H-}LexerIndex: Cardinal; Name: PAnsiChar; BufLength: Integer); stdcall;
const
  lexerName: AnsiString = 'fsharp';
begin
  StrLCopy(Name, PAnsiChar(lexerName), BufLength);
end;

procedure GetLexerStatusText({%H-}LexerIndex: Cardinal; Name: PWideChar; BufLength: Integer); stdcall;
const
  lexerName: WideString = 'F# source file';
begin
  StrLCopy(Name, PWideChar(lexerName), BufLength);
end;

end.
