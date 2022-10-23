{$IFNDEF DOCKING_INC}
{$DEFINE DOCKING_INC}
// This file is part of Notepad++ project
// Copyright (C)2021 Don HO <don.h@free.fr>

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
// styles for containers
  CAPTION_TOP     = TRUE;
  CAPTION_BOTTOM  = FALSE;

//   defines for docking manager
  CONT_LEFT    = 0;
  CONT_RIGHT   = 1;
  CONT_TOP     = 2;
  CONT_BOTTOM  = 3;
  DOCKCONT_MAX = 4;

// mask params for plugins of internal dialogs
  DWS_ICONTAB     = $00000001;     // Icon for tabs are available
  DWS_ICONBAR     = $00000002;     // Icon for icon bar are available (currently not supported);
  DWS_ADDINFO     = $00000004;     // Additional information are in use
  DWS_PARAMSALL   = (DWS_ICONTAB or DWS_ICONBAR or DWS_ADDINFO);

// default docking values for first call of plugin
  DWS_DF_CONT_LEFT   = (CONT_LEFT  shl 28);  // default docking on left
  DWS_DF_CONT_RIGHT  = (CONT_RIGHT shl 28);  // default docking on right
  DWS_DF_CONT_TOP    = (CONT_TOP shl 28);  // default docking on top
  DWS_DF_CONT_BOTTOM = (CONT_BOTTOM shl 28); // default docking on bottom
  DWS_DF_FLOATING    = $80000000;     // default state is floating



  HIT_TEST_THICKNESS  = 20;
  SPLITTER_WIDTH      = 4;

type
  TDockMgr = record
    DockMgrHandle: HWND;  // the docking manager window
    RcRegion: array [0..DOCKCONT_MAX-1] of TRect; // position of docked dialogs
  end;

{$ENDIF ~DOCKING_INC}
