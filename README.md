# F# Interactive Plugin for Notepad++

![Built with Free Pascal][fpc] [![cci-badge][]][cci-status]

![NPPFSIPlugin-v0.2.1.0-x64](https://raw.githubusercontent.com/rdipardo/NPPFSIPlugin/media/rel/NPPFSIPlugin-v0.2.1-x64.png)

## Usage

| Default shortcut                 | Command                                |
| :------------------------------- | :------------------------------------- |
| Alt + T                          | open the FSI console window            |
| Alt + Enter (with text selected) | evaluate the active selection in FSI   |

*Note*
Console output can be selected and copied to the clipboard using the context menu; right-click the console window to open it.

## F# Syntax Highlighting
### Notepad++ 8.4.3 and later

Opening any file with the extension `*.fs`, `*.fsx`, `*.fsi` or `*.fsscript` will activate [Lexilla]'s F# lexer.

### Older Notepad++ versions

For dark themes, copy the [Obsidian theme F# UDL] into `%AppData%\Notepad++\userDefineLangs` (system-wide Notepad++ installation),
or the `userDefineLangs` folder of a portable Notepad++ installation.

For the default or a light theme, use the [default F# UDL].

*Note*
Both UDLs have ["transparent" backgrounds] (i.e., `colorStyle="1"`).

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
[fpc]: https://img.shields.io/github/languages/top/rdipardo/nppFSIPlugin?style=flat-square&color=lightblue&label=Free%20Pascal
