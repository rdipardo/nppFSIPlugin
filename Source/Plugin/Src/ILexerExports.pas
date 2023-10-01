unit ILexerExports;

// =============================================================================
// Unit: ILexerExports
// Description: Basic implementation of Lexilla's ILexer5 protocol
//              https://www.scintilla.org/LexillaDoc.html
//
// Copyright 2023 Robert Di Pardo
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
// =============================================================================

interface

/// Since Npp v8.4, the addresses of these functions are required by PluginsManager::loadPluginFromPath()
function GetLexerCount: Integer; stdcall;
function CreateLexer(const Name: PAnsiChar): NativeInt; stdcall;
procedure GetLexerName({%H-}LexerIndex: Cardinal; Name: PAnsiChar; BufLength: Integer); stdcall;

/// Unused since Npp v8.4, but needed to prevent a load exception in older versions
function GetLexerFactory({%H-}LexerIndex: Cardinal): NativeInt; stdcall;
procedure GetLexerStatusText({%H-}LexerIndex: Cardinal; Name: PWideChar; BufLength: Integer); stdcall;

implementation

uses SysUtils, FSIPlugin;

function GetLexerCount: Integer; stdcall;
begin
  Result := 1;
end;

function CreateLexer(const Name: PAnsiChar): NativeInt; stdcall;
begin
  Result := 0;
  if SameText(Name, 'fsharp') then
    Result := Npp.GetILexerPtr('fsharp');
end;

procedure GetLexerName({%H-}LexerIndex: Cardinal; Name: PAnsiChar; BufLength: Integer); stdcall;
const
  lexerName: AnsiString = 'fsharp';
begin
  StrLCopy(Name, PAnsiChar(lexerName), BufLength);
end;

function GetLexerFactory({%H-}LexerIndex: Cardinal): NativeInt; stdcall;
begin
  Result := 0;
end;

procedure GetLexerStatusText({%H-}LexerIndex: Cardinal; Name: PWideChar; BufLength: Integer); stdcall;
const
  lexerName: WideString = 'F# source file';
begin
  StrLCopy(Name, PWideChar(lexerName), BufLength);
end;

end.
