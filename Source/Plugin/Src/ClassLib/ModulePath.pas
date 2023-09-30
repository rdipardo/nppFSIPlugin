{
  Extracted and adapted for FPC from L_SpecialFolders.pas, part of HTMLTag <https://fossil.2of4.net/npp_htmltag>
  Original unit (c) 2012 MCO and DGMR raadgevende ingenieurs BV
  Revisions (c) 2022, 2023 Robert Di Pardo <dipardo.r@gmail.com>

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this file,
  You can obtain one at https://mozilla.org/MPL/2.0/.

  Alternatively, the contents of this file may be used under the terms
  of the GNU General Public License Version 3, as described below:

  This program is free software: you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation, either version
  3 of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY; without even the implied
  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
  PURPOSE. See the GNU General Public License for more details.

  You should have received a copy of the GNU General
  Public License along with this program. If not, see
  <https://www.gnu.org/licenses/>.
}

unit ModulePath;

{$IFDEF FPC}
{$mode delphiunicode}
{$typedAddress on}
{$ENDIF}

interface

type
  TModulePath = class
  private
    class function GetModulePathName: string;
    class function GetDll: string; static; inline;
    class function GetDllDir: string; static; inline;
    class function GetDllBaseName: string; static; inline;
  public
    class procedure CopyFile(const SrcPath, DestPath: string); static;
    class property DLL: string read GetDllDir;
    class property DLLFullName: string read GetDll;
    class property DLLBaseName: string read GetDllBaseName;
  end;

function ChangeFilePath(const FileName, Path: string): string;

////////////////////////////////////////////////////////////////////////////////////////////////////
implementation

uses
  Windows, SysUtils;

{ ------------------------------------------------------------------------------------------------ }
/// From SysUtils.pas, part of Delphi_MiniRTL, <https://github.com/paulocalaes/Delphi_MiniRTL>
/// Copyright (c) 1995-2010 Embarcadero Technologies, Inc.
function ChangeFilePath(const FileName, Path: string): string;
begin
  Result := IncludeTrailingPathDelimiter(Path) + ExtractFileName(FileName);
end;

{ ================================================================================================ }
{ TModulePath }

{ ------------------------------------------------------------------------------------------------ }
class function TModulePath.GetDll: string;
begin
  Result := GetModulePathName;
end {TModulePath.GetDll};

{ ------------------------------------------------------------------------------------------------ }
class function TModulePath.GetDllDir: string;
begin
  Result := ExtractFilePath(GetDll);
end {TModulePath.GetDllDir};

{ ------------------------------------------------------------------------------------------------ }
class function TModulePath.GetDllBaseName: string;
begin
  Result := ChangeFileExt(ExtractFileName(GetDll), '');
end {TModulePath.GetDllBaseName};

{ ------------------------------------------------------------------------------------------------ }
class function TModulePath.GetModulePathName: string;
var
  iSize, iResult, iError: integer;
begin
  repeat
    iSize := MAX_PATH;
    Result := '';
    SetLength(Result, iSize);
    SetLastError(0);
    iResult := GetModuleFileNameW(HInstance, PWideChar(Result), iSize);
    iError := GetLastError;
    if iResult = 0 then
    begin
      if iError in [ERROR_SUCCESS, ERROR_MOD_NOT_FOUND] then
      begin
        Result := '';
        Exit;
      end
      else
      begin
        RaiseLastOSError;
      end;
    end
    else if iResult >= iSize then
    begin
      iSize := iResult + 1;
    end
    else
    begin
      SetLength(Result, iResult);
      Break;
    end;
  until iResult < iSize;

  if (WideCompareText(Copy(Result, 1, 4), '\\?\') = 0) then
    Result := Copy(Result, 5);
end {TModulePath.GetModulePathName};

{ ------------------------------------------------------------------------------------------------ }
class procedure TModulePath.CopyFile(const SrcPath, DestPath: string);
var
  hSrc, hDest: THandle;
  Text: TBytes;
  bytesWritten: LongInt;
begin
  bytesWritten := -1;
  try
    try
      hSrc := FileOpen(SrcPath, fmOpenRead or fmShareDenyWrite);
      if hSrc <> THandle(-1) then
      begin
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
end {TModulePath.CopyFile};

end.
