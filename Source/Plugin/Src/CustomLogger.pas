unit CustomLogger;

// =============================================================================
// This file is part of the F# Interactive plugin for Notepad++
//
// Copyright 2024 Robert Di Pardo
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

uses Classes;

type
  TScrollDirection = ( sdBack, sdForward );
  { Extends TStringList with simple bidirectional searching. }
  TCustomLogger = class(TStringList)
  private
    FStringsFilePath: WideString;
    FCursor: integer;
    function GetStr(const Index: Integer): String;
    procedure FromFile(const FilePath: WideString);
  public
    constructor Create; overload;
    constructor Create(const FilePath: WideString); overload;
    function Add(const Item: String): integer; override;
    function Scroll(Direction: TScrollDirection): String;
    procedure ToFile;
    property Log[Index: integer]: String read GetStr; default;
  end;

implementation

uses SysUtils, Math;

constructor TCustomLogger.Create;
begin
  inherited;
  CaseSensitive := True;
  FStringsFilePath := EmptyWideStr;
  FCursor := 0;
end;

constructor TCustomLogger.Create(const FilePath: WideString);
begin
  Create;
  FromFile(FilePath);
  FStringsFilePath := FilePath;
  FCursor := Max(0, Self.Count-1);
end;

function TCustomLogger.Add(const Item: String): integer;
begin
  if Self.IndexOf(Item) < 0 then
    FCursor := inherited Add(Item);
  Result := FCursor;
end;

function TCustomLogger.Scroll(Direction: TScrollDirection): String;
begin
  Result := Self[FCursor];
  case Direction of
    sdBack: begin
      Dec(FCursor);
      if FCursor < 0 then FCursor := Self.Count-1;
    end;
    sdForward: begin
      Inc(FCursor);
      if FCursor = Self.Count then FCursor := 0;
    end;
  end;
end;

function TCustomLogger.GetStr(const Index: Integer): String;
begin
  Result := EmptyStr;
  if (Index > -1) and (Index < Self.Count) then
    Result := Self.Strings[Index];
end;

procedure TCustomLogger.ToFile;
var
  hFStream: THandleStream;
  hDest: THandle;
begin
  try
    hDest := FileOpen(FStringsFilePath, fmOpenReadWrite or fmShareExclusive);
    if hDest = THandle(-1) then
      hDest := FileCreate(FStringsFilePath);
    try
      hFStream := THandleStream.Create(hDest);
      inherited SaveToStream(hFStream, False);
    finally
      FileClose(hFStream.Handle);
      hFStream.Free;
    end;
  except
    on E: Exception do
    begin
      if (not Assigned(hFStream)) and (hDest <> THandle(-1)) then
        FileClose(hDest);
    end;
  end;
end;

procedure TCustomLogger.FromFile(const FilePath: WideString);
var
  hFStream: THandleStream;
  hSrc: THandle;
begin
  try
    hSrc := FileOpen(FilePath, fmOpenRead or fmShareDenyWrite);
    if hSrc <> THandle(-1) then begin
      try
        hFStream := THandleStream.Create(hSrc);
        inherited LoadFromStream(hFStream, False);
      finally
        FileClose(hFStream.Handle);
        hFStream.Free;
      end;
    end;
  except
    on E: Exception do
    begin
      if (not Assigned(hFStream)) and (hSrc <> THandle(-1)) then
        FileClose(hSrc);
    end;
  end;
end;

end.
