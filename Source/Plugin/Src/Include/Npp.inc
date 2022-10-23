{$IFNDEF NPP_INC}
{$DEFINE NPP_INC}
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
{$MINENUMSIZE 4}

const
  NPPMSG = (WM_USER + 1000);
  NPPM_GETCURRENTSCINTILLA = (NPPMSG + 4);
  NPPM_GETCURRENTLANGTYPE = (NPPMSG + 5);
  NPPM_SETCURRENTLANGTYPE = (NPPMSG + 6);
  NPPM_GETNBOPENFILES = (NPPMSG + 7);
  ALL_OPEN_FILES = 0;
  PRIMARY_VIEW = 1;
  SECOND_VIEW = 2;
  NPPM_GETOPENFILENAMES = (NPPMSG + 8);
  NPPM_MODELESSDIALOG = (NPPMSG + 12);
  MODELESSDIALOGADD = 0;
  MODELESSDIALOGREMOVE = 1;
  NPPM_GETNBSESSIONFILES = (NPPMSG + 13);
  NPPM_GETSESSIONFILES = (NPPMSG + 14);
  NPPM_SAVESESSION = (NPPMSG + 15);
  NPPM_SAVECURRENTSESSION = (NPPMSG + 16);
  NPPM_GETOPENFILENAMESPRIMARY = (NPPMSG + 17);
  NPPM_GETOPENFILENAMESSECOND = (NPPMSG + 18);
  NPPM_CREATESCINTILLAHANDLE = (NPPMSG + 20);
  NPPM_DESTROYSCINTILLAHANDLE = (NPPMSG + 21);
  NPPM_GETNBUSERLANG = (NPPMSG + 22);
  NPPM_GETCURRENTDOCINDEX = (NPPMSG + 23);
  MAIN_VIEW = 0;
  SUB_VIEW = 1;
  NPPM_SETSTATUSBAR = (NPPMSG + 24);
  STATUSBAR_DOC_TYPE = 0;
  STATUSBAR_DOC_SIZE = 1;
  STATUSBAR_CUR_POS = 2;
  STATUSBAR_EOF_FORMAT = 3;
  STATUSBAR_UNICODE_TYPE = 4;
  STATUSBAR_TYPING_MODE = 5;
  NPPM_GETMENUHANDLE = (NPPMSG + 25);
  NPPPLUGINMENU = 0;
  NPPMAINMENU = 1;
  // INT NPPM_GETMENUHANDLE(INT menuChoice, 0);
  // Return: menu handle = (HMENU); of choice = (plugin menu handle or Notepad++ main menu handle);
  NPPM_ENCODESCI = (NPPMSG + 26);
  //ascii file to unicode
  //int NPPM_ENCODESCI(MAIN_VIEW/SUB_VIEW, 0);
  //return new unicodeMode
  NPPM_DECODESCI = (NPPMSG + 27);
  //unicode file to ascii
  //int NPPM_DECODESCI(MAIN_VIEW/SUB_VIEW, 0);
  //return old unicodeMode
  NPPM_ACTIVATEDOC = (NPPMSG + 28);
  //void NPPM_ACTIVATEDOC(int view, int index2Activate);
  NPPM_LAUNCHFINDINFILESDLG = (NPPMSG + 29);
  //void NPPM_LAUNCHFINDINFILESDLG(TCHAR * dir2Search, TCHAR * filtre);
  NPPM_DMMSHOW = (NPPMSG + 30);
  //void NPPM_DMMSHOW(0, tTbData->hClient);
  NPPM_DMMHIDE = (NPPMSG + 31);
  //void NPPM_DMMHIDE(0, tTbData->hClient);
  NPPM_DMMUPDATEDISPINFO = (NPPMSG + 32);
  //void NPPM_DMMUPDATEDISPINFO(0, tTbData->hClient);
  NPPM_DMMREGASDCKDLG = (NPPMSG + 33);
  //void NPPM_DMMREGASDCKDLG(0, &tTbData);
  NPPM_LOADSESSION = (NPPMSG + 34);
  //void NPPM_LOADSESSION(0, const TCHAR* file name);
  NPPM_DMMVIEWOTHERTAB = (NPPMSG + 35);
  //void WM_DMM_VIEWOTHERTAB(0, tTbData->pszName);
  NPPM_RELOADFILE = (NPPMSG + 36);
  //BOOL NPPM_RELOADFILE(BOOL withAlert, TCHAR *filePathName2Reload);
  NPPM_SWITCHTOFILE = (NPPMSG + 37);
  //BOOL NPPM_SWITCHTOFILE(0, TCHAR *filePathName2switch);
  NPPM_SAVECURRENTFILE = (NPPMSG + 38);
  //BOOL NPPM_SAVECURRENTFILE(0, 0);
  NPPM_SAVEALLFILES = (NPPMSG + 39);
  //BOOL NPPM_SAVEALLFILES(0, 0);
  NPPM_SETMENUITEMCHECK = (NPPMSG + 40);
  //void WM_PIMENU_CHECK(UINT funcItem[X]._cmdID, TRUE/FALSE);
  /// Keep NPPM_ADDTOOLBARICON for backward compatibility
  /// https://github.com/npp-plugins/plugindemo/commit/010955a292c3fefe20f1f7e451e092099d1ad62b#diff-8caed57078c9a60fae5e35986885a3b5e605d8983fe72b5458a23ec65f528346
  NPPM_ADDTOOLBARICON = (NPPMSG + 41); { added }
  NPPM_ADDTOOLBARICON_DEPRECATED = NPPM_ADDTOOLBARICON;
  //void NPPM_ADDTOOLBARICON(UINT funcItem[X]._cmdID, toolbarIcons iconHandles) -- DEPRECATED : use NPPM_ADDTOOLBARICON_FORDARKMODE instead
  NPPM_GETWINDOWSVERSION = (NPPMSG + 42);
  //winVer NPPM_GETWINDOWSVERSION(0, 0);
  NPPM_DMMGETPLUGINHWNDBYNAME = (NPPMSG + 43);
  //HWND WM_DMM_GETPLUGINHWNDBYNAME(const TCHAR *windowName, const TCHAR *moduleName);
  // if moduleName is NULL, then return value is NULL
  // if windowName is NULL, then the first found window handle which matches with the moduleName will be returned
  NPPM_MAKECURRENTBUFFERDIRTY = (NPPMSG + 44);
  //BOOL NPPM_MAKECURRENTBUFFERDIRTY(0, 0);
  NPPM_GETENABLETHEMETEXTUREFUNC = (NPPMSG + 45);
  //BOOL NPPM_GETENABLETHEMETEXTUREFUNC(0, 0);
  NPPM_GETPLUGINSCONFIGDIR = (NPPMSG + 46);
  //INT NPPM_GETPLUGINSCONFIGDIR(int strLen, TCHAR *str);
  // Get user's plugin config directory path. It's useful if plugins want to save/load parameters for the current user
  // Returns the number of TCHAR copied/to copy.
  // Users should call it with "str" be NULL to get the required number of TCHAR = (not including the terminating nul character);,
  // allocate "str" buffer with the return value + 1, then call it again to get the path.
  NPPM_MSGTOPLUGIN = (NPPMSG + 47);
  //BOOL NPPM_MSGTOPLUGIN(TCHAR *destModuleName, CommunicationInfo *info);
  // return value is TRUE when the message arrive to the destination plugins.
  // if destModule or info is NULL, then return value is FALSE
  NPPM_MENUCOMMAND = (NPPMSG + 48);
  //void NPPM_MENUCOMMAND(0, int cmdID);
  // uncomment //#include "menuCmdID.h"
  // in the beginning of this file then use the command symbols defined in "menuCmdID.h" file
  // to access all the Notepad++ menu command items
  NPPM_TRIGGERTABBARCONTEXTMENU = (NPPMSG + 49);
  //void NPPM_TRIGGERTABBARCONTEXTMENU(int view, int index2Activate);
  NPPM_GETNPPVERSION = (NPPMSG + 50);
  // int NPPM_GETNPPVERSION(BOOL ADD_ZERO_PADDING, 0)
  // Get Notepad++ version
  // HIWORD(returned_value) is major part of version: the 1st number
  // LOWORD(returned_value) is minor part of version: the 3 last numbers
  //
  // ADD_ZERO_PADDING == TRUE
  //
  // version  | HIWORD | LOWORD
  //------------------------------
  // 8.9.6.4  | 8      | 964
  // 9        | 9      | 0
  // 6.9      | 6      | 900
  // 6.6.6    | 6      | 660
  // 13.6.6.6 | 13     | 666
  //
  //
  // ADD_ZERO_PADDING == FALSE
  //
  // version  | HIWORD | LOWORD
  //------------------------------
  // 8.9.6.4  | 8      | 964
  // 9        | 9      | 0
  // 6.9      | 6      | 9
  // 6.6.6    | 6      | 66
  // 13.6.6.6 | 13     | 666
  //
  // changed in 8.4.1
  // https://github.com/notepad-plus-plus/notepad-plus-plus/commit/ef609c896f209ecffd8130c3e3327ca8a8157e72
  NPPM_HIDETABBAR = (NPPMSG + 51);
  // BOOL NPPM_HIDETABBAR(0, BOOL hideOrNot);
  // if hideOrNot is set as TRUE then tab bar will be hidden
  // otherwise it'll be shown.
  // return value : the old status value
  NPPM_ISTABBARHIDDEN = (NPPMSG + 52);
  // BOOL NPPM_ISTABBARHIDDEN(0, 0);
  // returned value : TRUE if tab bar is hidden, otherwise FALSE
  NPPM_GETPOSFROMBUFFERID = (NPPMSG + 57);
  // INT NPPM_GETPOSFROMBUFFERID(UINT_PTR bufferID, INT priorityView);
  // Return VIEW|INDEX from a buffer ID. -1 if the bufferID non existing
  // if priorityView set to SUB_VIEW, then SUB_VIEW will be search firstly
  //
  // VIEW takes 2 highest bits and INDEX = (0 based); takes the rest = (30 bits);
  // Here's the values for the view :
  //  MAIN_VIEW 0
  //  SUB_VIEW  1
  NPPM_GETFULLPATHFROMBUFFERID = (NPPMSG + 58);
  // INT NPPM_GETFULLPATHFROMBUFFERID(UINT_PTR bufferID, TCHAR *fullFilePath);
  // Get full path file name from a bufferID.
  // Return -1 if the bufferID non existing, otherwise the number of TCHAR copied/to copy
  // User should call it with fullFilePath be NULL to get the number of TCHAR = (not including the nul character);,
  // allocate fullFilePath with the return values + 1, then call it again to get full path file name
  NPPM_GETBUFFERIDFROMPOS = (NPPMSG + 59);
  // LRESULT NPPM_GETBUFFERIDFROMPOS(INT index, INT iView);
  // wParam: Position of document
  // lParam: View to use, 0 = Main, 1 = Secondary
  // Returns 0 if invalid
  NPPM_GETCURRENTBUFFERID = (NPPMSG + 60);
  // LRESULT NPPM_GETCURRENTBUFFERID(0, 0);
  // Returns active Buffer
  NPPM_RELOADBUFFERID = (NPPMSG + 61);
  // VOID NPPM_RELOADBUFFERID(UINT_PTR bufferID, BOOL alert);
  // Reloads Buffer
  // wParam: Buffer to reload
  // lParam: 0 if no alert, else alert
  NPPM_GETBUFFERLANGTYPE = (NPPMSG + 64);
  // INT NPPM_GETBUFFERLANGTYPE(UINT_PTR bufferID, 0);
  // wParam: BufferID to get LangType from
  // lParam: 0
  // Returns as int, see LangType. -1 on error
  NPPM_SETBUFFERLANGTYPE = (NPPMSG + 65);
  // BOOL NPPM_SETBUFFERLANGTYPE(UINT_PTR bufferID, INT langType);
  // wParam: BufferID to set LangType of
  // lParam: LangType
  // Returns TRUE on success, FALSE otherwise
  // use int, see LangType for possible values
  // L_USER and L_EXTERNAL are not supported
  NPPM_GETBUFFERENCODING = (NPPMSG + 66);
  // INT NPPM_GETBUFFERENCODING(UINT_PTR bufferID, 0);
  // wParam: BufferID to get encoding from
  // lParam: 0
  // returns as int, see UniMode. -1 on error
  NPPM_SETBUFFERENCODING = (NPPMSG + 67);
  // BOOL NPPM_SETBUFFERENCODING(UINT_PTR bufferID, INT encoding);
  // wParam: BufferID to set encoding of
  // lParam: encoding
  // Returns TRUE on success, FALSE otherwise
  // use int, see UniMode
  // Can only be done on new, unedited files
  NPPM_GETBUFFERFORMAT = (NPPMSG + 68);
  // INT NPPM_GETBUFFERFORMAT(UINT_PTR bufferID, 0);
  // wParam: BufferID to get EolType format from
  // lParam: 0
  // returns as int, see EolType format. -1 on error
  NPPM_SETBUFFERFORMAT = (NPPMSG + 69);
  // BOOL NPPM_SETBUFFERFORMAT(UINT_PTR bufferID, INT format);
  // wParam: BufferID to set EolType format of
  // lParam: format
  // Returns TRUE on success, FALSE otherwise
  // use int, see EolType format
  NPPM_HIDETOOLBAR = (NPPMSG + 70);
  // BOOL NPPM_HIDETOOLBAR(0, BOOL hideOrNot);
  // if hideOrNot is set as TRUE then tool bar will be hidden
  // otherwise it'll be shown.
  // return value : the old status value
  NPPM_ISTOOLBARHIDDEN = (NPPMSG + 71);
  // BOOL NPPM_ISTOOLBARHIDDEN(0, 0);
  // returned value : TRUE if tool bar is hidden, otherwise FALSE
  NPPM_HIDEMENU = (NPPMSG + 72);
  // BOOL NPPM_HIDEMENU(0, BOOL hideOrNot);
  // if hideOrNot is set as TRUE then menu will be hidden
  // otherwise it'll be shown.
  // return value : the old status value
  NPPM_ISMENUHIDDEN = (NPPMSG + 73);
  // BOOL NPPM_ISMENUHIDDEN(0, 0);
  // returned value : TRUE if menu is hidden, otherwise FALSE
  NPPM_HIDESTATUSBAR = (NPPMSG + 74);
  // BOOL NPPM_HIDESTATUSBAR(0, BOOL hideOrNot);
  // if hideOrNot is set as TRUE then STATUSBAR will be hidden
  // otherwise it'll be shown.
  // return value : the old status value
  NPPM_ISSTATUSBARHIDDEN = (NPPMSG + 75);
  // BOOL NPPM_ISSTATUSBARHIDDEN(0, 0);
  // returned value : TRUE if STATUSBAR is hidden, otherwise FALSE
  NPPM_GETSHORTCUTBYCMDID = (NPPMSG + 76);
  // BOOL NPPM_GETSHORTCUTBYCMDID(int cmdID, ShortcutKey *sk);
  // get your plugin command current mapped shortcut into sk via cmdID
  // You may need it after getting NPPN_READY notification
  // returned value : TRUE if this function call is successful and shortcut is enable, otherwise FALSE
  NPPM_DOOPEN = (NPPMSG + 77);
  // BOOL NPPM_DOOPEN(0, const TCHAR *fullPathName2Open);
  // fullPathName2Open indicates the full file path name to be opened.
  // The return value is TRUE = (1); if the operation is successful, otherwise FALSE = (0);.
  NPPM_SAVECURRENTFILEAS = (NPPMSG + 78);
  // BOOL NPPM_SAVECURRENTFILEAS = (BOOL asCopy, const TCHAR* filename);
  NPPM_GETCURRENTNATIVELANGENCODING = (NPPMSG + 79);
  // INT NPPM_GETCURRENTNATIVELANGENCODING(0, 0);
  // returned value : the current native language encoding
  NPPM_ALLOCATESUPPORTED = (NPPMSG + 80);
    // returns TRUE if NPPM_ALLOCATECMDID is supported
    // Use to identify if subclassing is necessary
  NPPM_ALLOCATECMDID = (NPPMSG + 81);
    // BOOL NPPM_ALLOCATECMDID(int numberRequested, int* startNumber);
    // sets startNumber to the initial command ID if successful
    // Returns: TRUE if successful, FALSE otherwise. startNumber will also be set to 0 if unsuccessful
  NPPM_ALLOCATEMARKER = (NPPMSG + 82);
    // BOOL NPPM_ALLOCATEMARKER(int numberRequested, int* startNumber);
    // sets startNumber to the initial command ID if successful
    // Allocates a marker number to a plugin: if a plugin need to add a marker on Notepad++'s Scintilla marker margin,
  // it has to use this message to get marker number, in order to prevent from the conflict with the other plugins.
    // Returns: TRUE if successful, FALSE otherwise. startNumber will also be set to 0 if unsuccessful
  NPPM_GETLANGUAGENAME = (NPPMSG + 83);
  // INT NPPM_GETLANGUAGENAME(int langType, TCHAR *langName);
  // Get programming language name from the given language type = (LangType);
  // Return value is the number of copied character / number of character to copy = (\0 is not included);
  // You should call this function 2 times - the first time you pass langName as NULL to get the number of characters to copy.
    // You allocate a buffer of the length of = (the number of characters + 1); then call NPPM_GETLANGUAGENAME function the 2nd time
  // by passing allocated buffer as argument langName
  NPPM_GETLANGUAGEDESC = (NPPMSG + 84);
  // INT NPPM_GETLANGUAGEDESC(int langType, TCHAR *langDesc);
  // Get programming language short description from the given language type = (LangType);
  // Return value is the number of copied character / number of character to copy = (\0 is not included);
  // You should call this function 2 times - the first time you pass langDesc as NULL to get the number of characters to copy.
    // You allocate a buffer of the length of = (the number of characters + 1); then call NPPM_GETLANGUAGEDESC function the 2nd time
  // by passing allocated buffer as argument langDesc
  NPPM_SHOWDOCLIST = (NPPMSG + 85);
  // VOID NPPM_SHOWDOCLIST(0, BOOL toShowOrNot);
  // Send this message to show or hide Document List.
  // if toShowOrNot is TRUE then show Document List, otherwise hide it.
  NPPM_ISDOCLISTSHOWN = (NPPMSG + 86);
  // BOOL NPPM_ISDOCLISTSHOWN(0, 0);
  // Check to see if Document List is shown.
  NPPM_GETAPPDATAPLUGINSALLOWED = (NPPMSG + 87);
  // BOOL NPPM_GETAPPDATAPLUGINSALLOWED(0, 0);
  // Check to see if loading plugins from "%APPDATA%\..\Local\Notepad++\plugins" is allowed.
  NPPM_GETCURRENTVIEW = (NPPMSG + 88);
  // INT NPPM_GETCURRENTVIEW(0, 0);
  // Return: current edit view of Notepad++. Only 2 possible values: 0 = Main, 1 = Secondary
  NPPM_DOCLISTDISABLEEXTCOLUMN = (NPPMSG + 89);
  // VOID NPPM_DOCLISTDISABLEEXTCOLUMN(0, BOOL disableOrNot);
  // Disable or enable extension column of Document List
  NPPM_DOCLISTDISABLEPATHCOLUMN = (NPPMSG + 102);
  // VOID NPPM_DOCLISTDISABLEPATHCOLUMN(0, BOOL disableOrNot);
  // Disable or enable path column of Document List
  NPPM_GETEDITORDEFAULTFOREGROUNDCOLOR = (NPPMSG + 90);
  // INT NPPM_GETEDITORDEFAULTFOREGROUNDCOLOR(0, 0);
  // Return: current editor default foreground color. You should convert the returned value in COLORREF
  NPPM_GETEDITORDEFAULTBACKGROUNDCOLOR = (NPPMSG + 91);
  // INT NPPM_GETEDITORDEFAULTBACKGROUNDCOLOR(0, 0);
  // Return: current editor default background color. You should convert the returned value in COLORREF
  NPPM_SETSMOOTHFONT = (NPPMSG + 92);
  // VOID NPPM_SETSMOOTHFONT(0, BOOL setSmoothFontOrNot);
  NPPM_SETEDITORBORDEREDGE = (NPPMSG + 93);
  // VOID NPPM_SETEDITORBORDEREDGE(0, BOOL withEditorBorderEdgeOrNot);
  NPPM_SAVEFILE = (NPPMSG + 94);
  // VOID NPPM_SAVEFILE(0, const TCHAR *fileNameToSave);
  NPPM_DISABLEAUTOUPDATE = (NPPMSG + 95); // 2119 in decimal
  // VOID NPPM_DISABLEAUTOUPDATE(0, 0);
  NPPM_REMOVESHORTCUTBYCMDID = (NPPMSG + 96); // 2120 in decimal
  // BOOL NPPM_REMOVESHORTCUTASSIGNMENT(int cmdID);
  // removes the assigned shortcut mapped to cmdID
  // returned value : TRUE if function call is successful, otherwise FALSE
  NPPM_GETPLUGINHOMEPATH = (NPPMSG + 97);
  // INT NPPM_GETPLUGINHOMEPATH(size_t strLen, TCHAR *pluginRootPath);
  // Get plugin home root path. It's useful if plugins want to get its own path
  // by appending <pluginFolderName> which is the name of plugin without extension part.
  // Returns the number of TCHAR copied/to copy.
  // Users should call it with pluginRootPath be NULL to get the required number of TCHAR = (not including the terminating nul character);,
  // allocate pluginRootPath buffer with the return value + 1, then call it again to get the path.
  NPPM_GETSETTINGSONCLOUDPATH = (NPPMSG + 98);
  // INT NPPM_GETSETTINGSCLOUDPATH(size_t strLen, TCHAR *settingsOnCloudPath);
  // Get settings on cloud path. It's useful if plugins want to store its settings on Cloud, if this path is set.
  // Returns the number of TCHAR copied/to copy. If the return value is 0, then this path is not set, or the "strLen" is not enough to copy the path.
  // Users should call it with settingsCloudPath be NULL to get the required number of TCHAR = (not including the terminating nul character);,
  // allocate settingsCloudPath buffer with the return value + 1, then call it again to get the path.
  NPPM_SETLINENUMBERWIDTHMODE = (NPPMSG + 99);
  LINENUMWIDTH_DYNAMIC     = 0;
  LINENUMWIDTH_CONSTANT    = 1;
  // BOOL NPPM_SETLINENUMBERWIDTHMODE(0, INT widthMode);
  // Set line number margin width in dynamic width mode = (LINENUMWIDTH_DYNAMIC); or constant width mode = (LINENUMWIDTH_CONSTANT);
  // It may help some plugins to disable non-dynamic line number margins width to have a smoothly visual effect while vertical scrolling the content in Notepad++
  // If calling is successful return TRUE, otherwise return FALSE.
  NPPM_GETLINENUMBERWIDTHMODE = (NPPMSG + 100);
  // INT NPPM_GETLINENUMBERWIDTHMODE(0, 0);
  // Get line number margin width in dynamic width mode = (LINENUMWIDTH_DYNAMIC); or constant width mode = (LINENUMWIDTH_CONSTANT);
  NPPM_ADDTOOLBARICON_FORDARKMODE = (NPPMSG + 101);
  // VOID NPPM_ADDTOOLBARICON_FORDARKMODE(UINT funcItem[X]._cmdID, toolbarIconsWithDarkMode iconHandles);
  // Use NPPM_ADDTOOLBARICON_FORDARKMODE instead obsolete NPPM_ADDTOOLBARICON which doesn't support the dark mode
  // since 8.0
  // https://community.notepad-plus-plus.org/topic/21652/add-new-api-nppm_addtoolbaricon_fordarkmode-for-dark-mode
  NPPM_GETEXTERNALLEXERAUTOINDENTMODE = (NPPMSG + 103);
  // BOOL NPPM_GETEXTERNALLEXERAUTOINDENTMODE(const TCHAR *languageName, ExternalLexerAutoIndentMode &autoIndentMode);
  // Get ExternalLexerAutoIndentMode for an installed external programming language.
  // - Standard means Notepad++ will keep the same TAB indentation between lines;
  // - C_Like means Notepad++ will perform a C-Language style indentation for the selected external language;
  // - Custom means a Plugin will be controlling auto-indentation for the current language.
  // returned values: TRUE for successful searches, otherwise FALSE.
  NPPM_SETEXTERNALLEXERAUTOINDENTMODE = (NPPMSG + 104);
  // BOOL NPPM_SETEXTERNALLEXERAUTOINDENTMODE(const TCHAR *languageName, ExternalLexerAutoIndentMode autoIndentMode);
  // Set ExternalLexerAutoIndentMode for an installed external programming language.
  // - Standard means Notepad++ will keep the same TAB indentation between lines;
  // - C_Like means Notepad++ will perform a C-Language style indentation for the selected external language;
  // - Custom means a Plugin will be controlling auto-indentation for the current language.
  // returned value: TRUE if function call was successful, otherwise FALSE.
  NPPM_ISAUTOINDENTON = (NPPMSG + 105);
  // BOOL NPPM_ISAUTOINDENTON(0, 0);
  // Returns the current Use Auto-Indentation setting in Notepad++ Preferences.
  NPPM_GETCURRENTMACROSTATUS = (NPPMSG + 106);
  // MacroStatus NPPM_GETCURRENTMACROSTATUS(0, 0);
  // Gets current enum class MacroStatus { Idle - means macro is not in use and it's empty, RecordInProgress, RecordingStopped, PlayingBack }
  NPPM_ISDARKMODEENABLED = (NPPMSG + 107);
  // bool NPPM_ISDARKMODEENABLED(0, 0)
  // Returns true when Notepad++ Dark Mode is enable, false when it is not.
  // since 8.4.1
  // https://github.com/notepad-plus-plus/notepad-plus-plus/commit/1eb5b10e41d7ab92b60aa32b28d4fe7739d15b53
  NPPM_GETDARKMODECOLORS = (NPPMSG + 108);
  // bool NPPM_GETDARKMODECOLORS (size_t cbSize, NppDarkMode::Colors* returnColors)
  // - cbSize must be filled with sizeof(NppDarkMode::Colors).
  // - returnColors must be a pre-allocated NppDarkMode::Colors struct.
  // Returns true when successful, false otherwise.
  // You need to uncomment the following code to use NppDarkMode::Colors structure:
  //
  // namespace NppDarkMode
  // {
  //  struct Colors
  //  {
  //    COLORREF background = 0;
  //    COLORREF softerBackground = 0;
  //    COLORREF hotBackground = 0;
  //    COLORREF pureBackground = 0;
  //    COLORREF errorBackground = 0;
  //    COLORREF text = 0;
  //    COLORREF darkerText = 0;
  //    COLORREF disabledText = 0;
  //    COLORREF linkText = 0;
  //    COLORREF edge = 0;
  //    COLORREF hotEdge = 0;
  //    COLORREF disabledEdge = 0;
  //  };
  // }
  //
  // Note: in the case of calling failure ("false" is returned), you may need to change NppDarkMode::Colors structure to:
  // https://github.com/notepad-plus-plus/notepad-plus-plus/blob/master/PowerEditor/src/NppDarkMode.h#L32
  // since 8.4.1
  // https://github.com/notepad-plus-plus/notepad-plus-plus/commit/1eb5b10e41d7ab92b60aa32b28d4fe7739d15b53
  NPPM_GETCURRENTCMDLINE = (NPPMSG + 109);
  // INT NPPM_GETCURRENTCMDLINE(size_t strLen, TCHAR *commandLineStr)
  // Get the Current Command Line string.
  // Returns the number of TCHAR copied/to copy.
  // Users should call it with commandLineStr as NULL to get the required number of TCHAR (not including the terminating nul character),
  // allocate commandLineStr buffer with the return value + 1, then call it again to get the current command line string.
  // since 8.4.2
  // https://github.com/notepad-plus-plus/notepad-plus-plus/commit/0f8d5724afb0a540e8b4024252945ab60bc88c71
  NPPM_CREATELEXER = (NPPMSG + 110);
  // void* NPPN_CREATELEXER(0, const TCHAR *lexer_name)
  // Returns the ILexer pointer created by Lexilla
  // since 8.4.3
  // https://github.com/notepad-plus-plus/notepad-plus-plus/commit/f1ed4de78dbe8f5d85f4d199bae2970148cca8ed

  VAR_NOT_RECOGNIZED = 0;
  FULL_CURRENT_PATH = 1;
  CURRENT_DIRECTORY = 2;
  FILE_NAME = 3;
  NAME_PART = 4;
  EXT_PART = 5;
  CURRENT_WORD = 6;
  NPP_DIRECTORY = 7;
  CURRENT_LINE = 8;
  CURRENT_COLUMN = 9;
  NPP_FULL_FILE_PATH = 10;
  GETFILENAMEATCURSOR = 11;
  CURRENT_LINESTR = 12;
  RUNCOMMAND_USER = (WM_USER + 3000);
  NPPM_GETFULLCURRENTPATH = (RUNCOMMAND_USER + FULL_CURRENT_PATH);
  NPPM_GETCURRENTDIRECTORY = (RUNCOMMAND_USER + CURRENT_DIRECTORY);
  NPPM_GETFILENAME = (RUNCOMMAND_USER + FILE_NAME);
  NPPM_GETNAMEPART = (RUNCOMMAND_USER + NAME_PART);
  NPPM_GETEXTPART = (RUNCOMMAND_USER + EXT_PART);
  NPPM_GETCURRENTWORD = (RUNCOMMAND_USER + CURRENT_WORD);
  NPPM_GETNPPDIRECTORY = (RUNCOMMAND_USER + NPP_DIRECTORY);
  NPPM_GETFILENAMEATCURSOR = (RUNCOMMAND_USER + GETFILENAMEATCURSOR);
  NPPM_GETCURRENTLINESTR = (RUNCOMMAND_USER + CURRENT_LINESTR);
  // BOOL NPPM_GETXXXXXXXXXXXXXXXX(size_t strLen, TCHAR *str);
  // where str is the allocated TCHAR array,
  //       strLen is the allocated array size
  // The return value is TRUE when get generic_string operation success
  // Otherwise = (allocated array size is too small); FALSE
  NPPM_GETCURRENTLINE = (RUNCOMMAND_USER + CURRENT_LINE);
  // INT NPPM_GETCURRENTLINE(0, 0);
  // return the caret current position line
  NPPM_GETCURRENTCOLUMN = (RUNCOMMAND_USER + CURRENT_COLUMN);
  // INT NPPM_GETCURRENTCOLUMN(0, 0);
  // return the caret current position column
  NPPM_GETNPPFULLFILEPATH = (RUNCOMMAND_USER + NPP_FULL_FILE_PATH);



// Notification code
  NPPN_FIRST = 1000;
  NPPN_READY = (NPPN_FIRST + 1); // To notify plugins that all the procedures of launchment of notepad++ are done.
  //scnNotification->nmhdr.code = NPPN_READY;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = 0;
  NPPN_TBMODIFICATION = (NPPN_FIRST + 2); // To notify plugins that toolbar icons can be registered
  //scnNotification->nmhdr.code = NPPN_TBMODIFICATION;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = 0;
  NPPN_FILEBEFORECLOSE = (NPPN_FIRST + 3); // To notify plugins that the current file is about to be closed
  //scnNotification->nmhdr.code = NPPN_FILEBEFORECLOSE;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = BufferID;
  NPPN_FILEOPENED = (NPPN_FIRST + 4); // To notify plugins that the current file is just opened
  //scnNotification->nmhdr.code = NPPN_FILEOPENED;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = BufferID;
  NPPN_FILECLOSED = (NPPN_FIRST + 5); // To notify plugins that the current file is just closed
  //scnNotification->nmhdr.code = NPPN_FILECLOSED;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = BufferID;
  NPPN_FILEBEFOREOPEN = (NPPN_FIRST + 6); // To notify plugins that the current file is about to be opened
  //scnNotification->nmhdr.code = NPPN_FILEBEFOREOPEN;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = BufferID;
  NPPN_FILEBEFORESAVE = (NPPN_FIRST + 7); // To notify plugins that the current file is about to be saved
  //scnNotification->nmhdr.code = NPPN_FILEBEFOREOPEN;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = BufferID;
  NPPN_FILESAVED = (NPPN_FIRST + 8); // To notify plugins that the current file is just saved
  //scnNotification->nmhdr.code = NPPN_FILESAVED;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = BufferID;
  NPPN_SHUTDOWN = (NPPN_FIRST + 9); // To notify plugins that Notepad++ is about to be shutdowned.
  //scnNotification->nmhdr.code = NPPN_SHUTDOWN;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = 0;
  NPPN_BUFFERACTIVATED = (NPPN_FIRST + 10); // To notify plugins that a buffer was activated = (put to foreground);.
  //scnNotification->nmhdr.code = NPPN_BUFFERACTIVATED;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = activatedBufferID;
  NPPN_LANGCHANGED = (NPPN_FIRST + 11); // To notify plugins that the language in the current doc is just changed.
  //scnNotification->nmhdr.code = NPPN_LANGCHANGED;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = currentBufferID;
  NPPN_WORDSTYLESUPDATED = (NPPN_FIRST + 12); // To notify plugins that user initiated a WordStyleDlg change.
  //scnNotification->nmhdr.code = NPPN_WORDSTYLESUPDATED;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = currentBufferID;
  NPPN_SHORTCUTREMAPPED = (NPPN_FIRST + 13); // To notify plugins that plugin command shortcut is remapped.
  //scnNotification->nmhdr.code = NPPN_SHORTCUTSREMAPPED;
  //scnNotification->nmhdr.hwndFrom = ShortcutKeyStructurePointer;
  //scnNotification->nmhdr.idFrom = cmdID;
    //where ShortcutKeyStructurePointer is pointer of struct ShortcutKey:
    //struct ShortcutKey {
    //  bool _isCtrl;
    //  bool _isAlt;
    //  bool _isShift;
    //  UCHAR _key;
    //};
  NPPN_FILEBEFORELOAD = (NPPN_FIRST + 14); // To notify plugins that the current file is about to be loaded
  //scnNotification->nmhdr.code = NPPN_FILEBEFOREOPEN;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = NULL;
  NPPN_FILELOADFAILED = (NPPN_FIRST + 15);  // To notify plugins that file open operation failed
  //scnNotification->nmhdr.code = NPPN_FILEOPENFAILED;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = BufferID;
  NPPN_READONLYCHANGED = (NPPN_FIRST + 16);  // To notify plugins that current document change the readonly status,
  //scnNotification->nmhdr.code = NPPN_READONLYCHANGED;
  //scnNotification->nmhdr.hwndFrom = bufferID;
  //scnNotification->nmhdr.idFrom = docStatus;
    // where bufferID is BufferID
    //       docStatus can be combined by DOCSTATUS_READONLY and DOCSTATUS_BUFFERDIRTY
  DOCSTATUS_READONLY = 1;
  DOCSTATUS_BUFFERDIRTY = 2;
  NPPN_DOCORDERCHANGED = (NPPN_FIRST + 17);  // To notify plugins that document order is changed
  //scnNotification->nmhdr.code = NPPN_DOCORDERCHANGED;
  //scnNotification->nmhdr.hwndFrom = newIndex;
  //scnNotification->nmhdr.idFrom = BufferID;
  NPPN_SNAPSHOTDIRTYFILELOADED = (NPPN_FIRST + 18);  // To notify plugins that a snapshot dirty file is loaded on startup
  //scnNotification->nmhdr.code = NPPN_SNAPSHOTDIRTYFILELOADED;
  //scnNotification->nmhdr.hwndFrom = NULL;
  //scnNotification->nmhdr.idFrom = BufferID;
  NPPN_BEFORESHUTDOWN = (NPPN_FIRST + 19);  // To notify plugins that Npp shutdown has been triggered, files have not been closed yet
  //scnNotification->nmhdr.code = NPPN_BEFORESHUTDOWN;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = 0;
  NPPN_CANCELSHUTDOWN = (NPPN_FIRST + 20);  // To notify plugins that Npp shutdown has been cancelled
  //scnNotification->nmhdr.code = NPPN_CANCELSHUTDOWN;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = 0;
  NPPN_FILEBEFORERENAME = (NPPN_FIRST + 21);  // To notify plugins that file is to be renamed
  //scnNotification->nmhdr.code = NPPN_FILEBEFORERENAME;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = BufferID;
  NPPN_FILERENAMECANCEL = (NPPN_FIRST + 22);  // To notify plugins that file rename has been cancelled
  //scnNotification->nmhdr.code = NPPN_FILERENAMECANCEL;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = BufferID;
  NPPN_FILERENAMED = (NPPN_FIRST + 23);  // To notify plugins that file has been renamed
  //scnNotification->nmhdr.code = NPPN_FILERENAMED;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = BufferID;
  NPPN_FILEBEFOREDELETE = (NPPN_FIRST + 24);  // To notify plugins that file is to be deleted
  //scnNotification->nmhdr.code = NPPN_FILEBEFOREDELETE;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = BufferID;
  NPPN_FILEDELETEFAILED = (NPPN_FIRST + 25);  // To notify plugins that file deletion has failed
  //scnNotification->nmhdr.code = NPPN_FILEDELETEFAILED;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = BufferID;
  NPPN_FILEDELETED = (NPPN_FIRST + 26);  // To notify plugins that file has been deleted
  //scnNotification->nmhdr.code = NPPN_FILEDELETED;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = BufferID;
  NPPN_DARKMODECHANGED = (NPPN_FIRST + 27); // To notify plugins that Dark Mode was enabled/disabled
  //scnNotification->nmhdr.code = NPPN_DARKMODECHANGED;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = 0;
  NPPN_CMDLINEPLUGINMSG = (NPPN_FIRST + 28);  // To notify plugins that the new argument for plugins (via '-pluginMessage="YOUR_PLUGIN_ARGUMENT"' in command line) is available
  //scnNotification->nmhdr.code = NPPN_CMDLINEPLUGINMSG;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = pluginMessage; //where pluginMessage is pointer of type wchar_t

  MACRO_USER                = (WM_USER + 4000);
  WM_ISCURRENTMACRORECORDED = (MACRO_USER + 01);
  WM_MACRODLGRUNMACRO       = (MACRO_USER + 02);

type
  TNppLang = (L_TEXT = 0, L_PHP , L_C, L_CPP, L_CS, L_OBJC, L_JAVA, L_RC,
              L_HTML, L_XML, L_MAKEFILE, L_PASCAL, L_BATCH, L_INI, L_ASCII, L_USER,
              L_ASP, L_SQL, L_VB, L_JS, L_CSS, L_PERL, L_PYTHON, L_LUA,
              L_TEX, L_FORTRAN, L_BASH, L_FLASH, L_NSIS, L_TCL, L_LISP, L_SCHEME,
              L_ASM, L_DIFF, L_PROPS, L_PS, L_RUBY, L_SMALLTALK, L_VHDL, L_KIX, L_AU3,
              L_CAML, L_ADA, L_VERILOG, L_MATLAB, L_HASKELL, L_INNO, L_SEARCHRESULT,
              L_CMAKE, L_YAML, L_COBOL, L_GUI4CLI, L_D, L_POWERSHELL, L_R, L_JSP,
              L_COFFEESCRIPT, L_JSON, L_JAVASCRIPT, L_FORTRAN_77, L_BAANC, L_SREC,
              L_IHEX, L_TEHEX, L_SWIFT,
              L_ASN1, L_AVS, L_BLITZBASIC, L_PUREBASIC, L_FREEBASIC,
              L_CSOUND, L_ERLANG, L_ESCRIPT, L_FORTH, L_LATEX,
              L_MMIXAL, L_NIM, L_NNCRONTAB, L_OSCRIPT, L_REBOL,
              L_REGISTRY, L_RUST, L_SPICE, L_TXT2TAGS, L_VISUALPROLOG, L_TYPESCRIPT,
              // Don't use L_JS, use L_JAVASCRIPT instead
              // The end of enumerated language type, so it should be always at the end
              L_EXTERNAL);

{$REGION 'Delphi plugin definitions'}
const
  L_TXT = TNppLang.L_TEXT; // https://github.com/notepad-plus-plus/notepad-plus-plus/commit/689d434a9f17cd7eb195fcdb7860d41631e44a6a
  FuncItemNameLen = 64;

type
  nppString = WideString;
  nppChar = WChar;
  nppPChar = PWChar;
{$ENDREGION}

type
  /// since 8.3.3
  /// https://github.com/notepad-plus-plus/notepad-plus-plus/commit/9cbd03c301cd22b3a96edbf85f3b2f90c2168a2c
  TExternalLexerAutoIndentMode = ( Standard, C_Like, Custom );
  TMacroStatus = ( Idle, RecordInProgress, RecordingStopped, PlayingBack );

  /// since 7.3.2
  /// https://github.com/notepad-plus-plus/notepad-plus-plus/commit/3dfe526019a66be4cac540affbf17dc833bf51b6
  TPlatform = ( PF_UNKNOWN, PF_X86, PF_X64, PF_IA64, PF_ARM64 );

  TWinVer = ( WV_UNKNOWN, WV_WIN32S, WV_95, WV_98, WV_ME, WV_NT, WV_W2K, WV_XP, WV_S2003, WV_XPX64, WV_VISTA, WV_WIN7, WV_WIN8, WV_WIN81, WV_WIN10 );

  TSessionInfo = record
    SessionFilePathName: nppPChar;
    NumFiles: Integer;
    Files: array of nppPChar;
  end;

  //2 formats of icon are needed: .ico & .bmp
  //Both handles below should be set so the icon will be displayed correctly if toolbar icon sets are changed by users
  TTbIcons = record
    hToolbarBmp: HBITMAP;
    hToolbarIcon: HICON;
  end;

  // 2 formats / 3 icons are needed:  1 * BMP + 2 * ICO
  // All 3 handles below should be set so the icon will be displayed correctly if toolbar icon sets are changed by users, also in dark mode
  TTbIconsDarkMode = record
    hToolbarBmp: HBITMAP;
    hToolbarIcon: HICON;
    hToolbarIconDarkMode: HICON;
  end;

  TCommunicationInfo = record
    internalMsg: NativeUInt;
    srcModuleName: nppPChar;
    info: Pointer;
  end;

  TNppData = packed record
    _nppHandle: HWND;
    _scintillaMainHandle: HWND;
    _scintillaSecondHandle: HWND;
  end;
  PNPPData = ^TNppData;

  TShortcutKey = packed record
    _isCtrl: Boolean;
    _isAlt: Boolean;
    _isShift: Boolean;
    _key: UCHAR;
  end;
  PShortcutKey = ^TShortcutKey;

  TPluginProc = procedure; cdecl;

  TFuncItem = packed record
    _itemName: array[0..FuncItemNameLen-1] of nppChar;
    _pFunc: TPluginProc;
    _cmdID: Integer;
    _init2Check: LongBool;
    _PShKey: PShortcutKey;
  end;
  PFuncItem = ^TFuncItem;

  TTbData = record
    hClient: HWND; // client Window Handle
    pszName: nppPChar; // name of plugin (shown in window)
    DlgId: Integer;  // a funcItem provides the function pointer to start a dialog. Please parse here these ID
    uMask: Cardinal; // see Docking.inc
    hIconTab: HICON; // icon for tabs
    pszAddInfo: nppPChar;
    rcFloat: TRect;  // internal data, do not use !!!
    iPrevCont: Cardinal; // internal data, do not use !!!
    pszModuleName: nppPChar; // name of module GetModuleFileName(0...)
  end;
  PTbData = ^TTbData;

{$ENDIF ~NPP_INC}
