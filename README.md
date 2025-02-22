# F# Interactive Plugin for Notepad++

![Built with Free Pascal][fpc] [![cci-badge][]][cci-status]

![NPPFSIPlugin-v0.2.2.0-x64](https://raw.githubusercontent.com/rdipardo/NPPFSIPlugin/media/rel/nppFSIPlugin-v0.2.2-x64.png)

## Usage

| Default shortcut                 | Command                                |
| :------------------------------- | :------------------------------------- |
| Alt + Shift + F12                | open/close the FSI console window      |
| Alt + Enter (with text selected) | evaluate the active selection in FSI   |
| *none*                           | pass the current file to FSI's `#load` directive [^1] |

[^1]: Also starts a new FSI session if one is not currently active.

> [!Note]
> Console output can be selected and copied to the clipboard by right-clicking in the console window.



## F# Syntax Highlighting
### Notepad++ 8.4.3 and later

Opening any file with the extension `*.fs`, `*.fsx`, `*.fsi` or `*.fsscript` will activate [Lexilla]'s F# lexer.

### Older Notepad++ versions

For dark themes, copy the [Obsidian theme F# UDL] into `%AppData%\Notepad++\userDefineLangs` (system-wide Notepad++ installation),
or the `userDefineLangs` folder of a portable Notepad++ installation.

For the default or a light theme, use the [default F# UDL].

> [!Note]
> Both UDLs have ["transparent" backgrounds] (i.e., `colorStyle="1"`).

## How to configure tab settings for F# source files
### *F# Interactive* v0.2.3.1 and later

- Open the plugin options dialog:

  <img src="https://i.ibb.co/26Gr440/fsi-v0-2-3-1-options-menu.png" alt="plugin-options-menus" border="0" width="375"/>

- To indent using spaces, check the box beside __*Convert tabs to spaces*__
- To indent using hard tabs, *un*&#x200C;check the box beside __*Convert tabs to spaces*__
- Set the number of spaces (or tab size) using the __*Tab length*__ edit control

  <img src="https://i.ibb.co/Tb95Tvt/fsi-v0-2-3-1-tab-settings-detail.png" alt="plugin-tab-settings-detail" border="0" width="375"/>

### Older plugin versions
#### Notepad++ preferences menu

With the plugin loaded, modify your [indentation preferences](https://npp-user-manual.org/docs/preferences/#indentation)
for F# (or "fsharp", if using version 0.2.2.0 and older).

> [!Important]
> Your choices will *not* be saved when you exit Notepad++

#### XML configuration file

To make 4 spaces the default tab setting for F# files when Notepad++ starts, do the following:

- Open `NPPFSIPlugin.xml` in `%AppData%\Notepad++\plugins\Config` or `$(PORTABLE_NPP_DIR)\plugins\Config`

- Add the attribute `tabSettings="132"` to the node `/NotepadPlus/Languages/Language[@name="F#"]`
  (or `/NotepadPlus/Languages/Language[@name="fsharp"]`, if using version 0.2.2.0 and older)

  For example:

  ```diff
  - <Language name="F#" ext="fs fsi fsx fsscript" commentLine="//" commentStart="(*" commentEnd="*)">
  + <Language name="F#" ext="fs fsi fsx fsscript" tabSettings="132" commentLine="//" commentStart="(*" commentEnd="*)">
  ```

  The "magic" number 132 is explained [here](https://github.com/notepad-plus-plus/notepad-plus-plus/issues/5506#issuecomment-483255006).

## Installation
### Plugins Admin

A builtin [plugin manager] is available in Notepad++ versions 7.6 and newer.

Find *Plugins* on the main menu bar and select *Plugins Admin*.
Check the box beside *F# Interactive* and click *Install*.

### Manual installation

- Download a [release archive]
- Extract the `NPPFSIPlugin.dll` module and subfolders (`Doc`, `Config`)
- Right-click on `NPPFSIPlugin.dll` and select *Properties*:

  <img src="https://i.ibb.co/HhCgcmT/NPPFSIPlugin-file-props.png" alt="plugin-file-props" border="0" width="375"/>

- If the *Unblock* option is shown, click the checkbox and click *Apply*, then *OK*:

  <img src="https://i.ibb.co/C77Wmfx/NPPFSIPlugin-MOTW.png" alt="plugin-remove-MOTW" border="0" width="425"/>

- __System-wide Notepad++ installation__
  + Create a folder named `NPPFSIPlugin` under `%ProgramFiles%\Notepad++\plugins` (64-bit),
    or `%ProgramFiles(x86)%\Notepad++\plugins` (32-bit)

- __Portable Notepad++__
  + Locate the `plugins` folder where `notepad++.exe` is installed
  + Create a folder named `NPPFSIPlugin`

- Move the `NPPFSIPlugin.dll` module and `Config` subfolder into the `NPPFSIPlugin` folder:

  <img src="https://i.ibb.co/WkbVK5G/NPPFSIPlugin-v021-installation.png" alt="plugin-install-dirs" border="0" width="375">

- Restart Notepad++ if it’s already running

## Acknowledgements

[Original source code] &copy; 2010 Prapin Peethambaran, MIT License

The [FpcPipes] unit is adapted from source code believed to be in the Public Domain: <https://github.com/marsupilami79/DelphiPipes#licensing>

The F# Software Foundation logo for F# is an asset of the F# Software Foundation: <https://foundation.fsharp.org/logo>

## License

Distributed under the terms of the GNU General Public License, Version 3 or later,
in addition to the rights of past contributors mentioned in [Copyright.txt].

[Original source code]: https://github.com/ppv/NPPFSIPlugin
[Copyright.txt]: https://raw.githubusercontent.com/rdipardo/nppFSIPlugin/master/Copyright.txt
[FpcPipes]: https://github.com/rdipardo/nppFSIPlugin/blob/master/Source/Plugin/Src/FpcPipes.pas
[Lexilla]: https://github.com/ScintillaOrg/lexilla
[Obsidian theme F# UDL]: https://gist.github.com/rdipardo/e500e0e9053e8556350802cf8ab06583
[default F# UDL]: https://gist.github.com/rdipardo/ede4aed93542286f36d21051b8b51238
[release archive]: https://github.com/rdipardo/nppFSIPlugin/releases
[plugin manager]: https://npp-user-manual.org/docs/plugins/#install-using-plugins-admin
["transparent" backgrounds]: https://github.com/notepad-plus-plus/notepad-plus-plus/issues/9649#issuecomment-832205177
[cci-status]: https://circleci.com/gh/rdipardo/nppFSIPlugin
[cci-badge]: https://circleci.com/gh/rdipardo/nppFSIPlugin.svg?style=svg
[fpc]: https://img.shields.io/github/languages/top/rdipardo/nppFSIPlugin?style=flat-square&color=lightblue&label=Free%20Pascal&logo=lazarus
