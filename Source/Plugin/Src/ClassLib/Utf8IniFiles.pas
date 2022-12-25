unit Utf8IniFiles;

(*
  Copyright (c) 2022 Robert Di Pardo <dipardo.r@gmail.com>

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this file,
  You can obtain one at https://mozilla.org/MPL/2.0/.
*)

{$IFDEF FPC}{$mode delphi}{$ENDIF}

interface

uses SysUtils, IniFiles;

type
  EUtf8IniFileException = class(Exception);
  TUtf8IniFile = class(TIniFile)
{$IFNDEF FPC}
    constructor Create(const FilePath: string); reintroduce;
{$ELSE}
    constructor Create(const FilePath: WideString;
      Opts: TIniFileOptions = [ifoEscapeLineFeeds, ifoStripQuotes]);
    destructor Destroy; override;
{$ENDIF}
  private
    procedure MakeIniDir(const iniFileDir: WideString);
  end;

implementation

{$IFDEF FPC}
uses Classes;
{$ENDIF}

{$IFNDEF FPC}
constructor TUtf8IniFile.Create(const FilePath: string);
begin
  MakeIniDir(ExtractFileDir(FilePath));
  inherited Create(FilePath);
end;

{$ELSE}
constructor TUtf8IniFile.Create(const FilePath: WideString; Opts: TIniFileOptions);
var
  hIniFile: THandle;
begin
  try
    MakeIniDir(ExtractFileDir(FilePath));
    hIniFile := FileOpen(FilePath, fmOpenReadWrite or fmShareExclusive);
    if hIniFile = THandle(-1) then
      hIniFile := FileCreate(FilePath);

    inherited Create(THandleStream.Create(hIniFile), TEncoding.Utf8, Opts);
  except
    on E: Exception do
    begin
      FileClose(hIniFile);
      raise EUtf8IniFileException.Create(E.message);
    end;
  end;
end;

destructor TUtf8IniFile.Destroy;
begin
  if Assigned(Self.Stream) then
  begin
    FileClose(THandleStream(Self.Stream).Handle);
    Self.Stream.Free;
  end;

  inherited;
end;
{$ENDIF ~FPC}

procedure TUtf8IniFile.MakeIniDir(const iniFileDir: WideString);
begin
  if (not DirectoryExists(iniFileDir)) and (not CreateDir(iniFileDir)) then
    raise EUtf8IniFileException.Create(Format('Directory "%s" is not writable',
      [UTF8Encode(iniFileDir)]));
end;

end.
