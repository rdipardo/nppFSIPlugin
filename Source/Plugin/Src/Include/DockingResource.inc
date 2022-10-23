{$IFNDEF DOCKING_RES_INC}
{$DEFINE DOCKING_RES_INC}
// This file is part of Notepad++ project
// Copyright = (C);2006 Jens Lorenz <jens.plugin.npp@gmx.de>

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// at your option any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

const
  DM_NOFOCUSWHILECLICKINGCAPTION = 'NOFOCUSWHILECLICKINGCAPTION';
  IDD_PLUGIN_DLG                 = 103;
  IDC_EDIT1                      = 1000;
  IDB_CLOSE_DOWN                 = 137;
  IDB_CLOSE_UP                   = 138;
  IDD_CONTAINER_DLG              = 139;
  IDC_TAB_CONT                   = 1027;
  IDC_CLIENT_TAB                 = 1028;
  IDC_BTN_CAPTION                = 1050;
  DMM_MSG                        = $5000;
  DMM_CLOSE                      = (DMM_MSG + 1);
  DMM_DOCK                       = (DMM_MSG + 2);
  DMM_FLOAT                      = (DMM_MSG + 3);
  DMM_DOCKALL                    = (DMM_MSG + 4);
  DMM_FLOATALL                   = (DMM_MSG + 5);
  DMM_MOVE                       = (DMM_MSG + 6);
  DMM_UPDATEDISPINFO             = (DMM_MSG + 7);
  DMM_GETIMAGELIST               = (DMM_MSG + 8);
  DMM_GETICONPOS                 = (DMM_MSG + 9);
  DMM_DROPDATA                   = (DMM_MSG + 10);
  DMM_MOVE_SPLITTER              = (DMM_MSG + 11);
  DMM_CANCEL_MOVE                = (DMM_MSG + 12);
  DMM_LBUTTONUP                  = (DMM_MSG + 13);
  DMN_FIRST                      = 1050;
  DMN_CLOSE                      = (DMN_FIRST + 1);
  //nmhdr.code = DWORD= (DMN_CLOSE, 0););;
  //nmhdr.hwndFrom = hwndNpp;
  //nmhdr.idFrom = ctrlIdNpp;
  DMN_DOCK                       = (DMN_FIRST + 2);
  DMN_FLOAT                      = (DMN_FIRST + 3);
  //nmhdr.code = DWORD= (DMN_XXX, int newContainer);;
  //nmhdr.hwndFrom = hwndNpp;
  //nmhdr.idFrom = ctrlIdNpp;
  DMN_SWITCHIN                   = (DMN_FIRST + 4);
  DMN_SWITCHOFF                  = (DMN_FIRST + 5);
  DMN_FLOATDROPPED               = (DMN_FIRST + 6);
  //nmhdr.code = DWORD= (DMN_XXX, 0);;
  //nmhdr.hwndFrom = DockingCont::_hself;
  //nmhdr.idFrom = 0;
{$ENDIF ~DOCKING_RES_INC}
