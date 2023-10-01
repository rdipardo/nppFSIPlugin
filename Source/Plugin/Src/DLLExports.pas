unit DLLExports;

// =============================================================================
// Unit: DLLExports
// Description: Implementation of the Notepad++ plugin protocol
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

uses
  Windows, SysUtils, NppPlugin, FSIPlugin;

procedure setInfo(data: TNppData); cdecl;
procedure beNotified(msg: PSciNotification); cdecl;
function getName: NppPChar; cdecl;
function messageProc({%H-}msg: UINT; {%H-}wParam: WPARAM; {%H-}lParam: LPARAM): LRESULT; cdecl;
function getFuncsArray(var funcCount: Integer): Pointer; cdecl;
function isUnicode: BOOL; cdecl;
procedure DLLEntry(dwReason: DWORD);

implementation

function isUnicode: BOOL; cdecl;
begin
  Result := True;
end;

procedure setInfo(data: TNppData); cdecl;
begin
  Npp.SetInfo(data);
end;

function getName: NppPChar; cdecl;
begin
  Result := Npp.GetName;
end;

function messageProc({%H-}msg: UINT; {%H-}wParam: WPARAM; {%H-}lParam: LPARAM): LRESULT; cdecl;
begin
  Result := 0;
end;

procedure beNotified(msg: PSciNotification); cdecl;
begin
  Npp.BeNotified(msg);
end;

function getFuncsArray(var funcCount: Integer): Pointer; cdecl;
begin
  Result := Npp.GetFuncsArray(funcCount);
end;

procedure DLLEntry(dwReason: DWORD);
begin
  case dwReason of
    DLL_PROCESS_ATTACH:
      Npp := TFSIplugin.Create;
    DLL_PROCESS_DETACH:
      if (Assigned(Npp)) then
        FreeAndNil(Npp);
  end;
end;

end.
