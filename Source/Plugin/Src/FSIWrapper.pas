unit FSIWrapper;

// =============================================================================
// Unit: FSIWrapper
// Description: FSI wrapper class source.
//
// Ported to Free Pascal by Robert Di Pardo, Copyright 2022, 2023
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
//
// This software incorporates work covered by the following copyright and permission notice:
//
// Copyright 2010 Prapin Peethambaran
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// =============================================================================

interface

uses
  // standard units
  Classes, ComCtrls, Controls, Types, Graphics, Messages, Menus,
  {$IFDEF FPC}RichMemo, RichMemoHelpers,{$ENDIF}
  // windows pipes wrapper
  FpcPipes,
  // configuration manager
  Config;

type
{$IFDEF FPC}
  TRichEdit = TRichMemo;
{$ENDIF}

  /// Implements a wrapper for the F-Sharp Interactive(FSI) so that it can be hosted inside an
  /// external application.
  ///
  TFSIViewer = class
  private
    _config: TConfiguration;
    _editor: TRichEdit;
    _pipedConsole: TPipeConsole;
    _editableAreaStartCoord: TPoint;
    _editableAreaStartPos: Integer;
    _defEditorWndProc: TWndMethod;
    _onSendText: TNotifyEvent;
    _onResultOutput: TNotifyEvent;
    _onErrorOutput: TNotifyEvent;
  private

    /// <summary>
    /// Create an instance of FSI and also the pipes needed to interact with it.
    /// </summary>
    procedure createFSI;

    /// <summary>
    /// Create a richedit control instance that will be used to interface with FSI.
    /// </summary>
    procedure createEditor;

    /// <summary>
    /// Create menu for controlling some editor functions.
    /// </summary>
    procedure createContextMenu;

    /// <summary>
    /// Based on the editor's caret position determine if the user is allowed to make changes
    /// directly to the editor.
    /// </summary>
    function isEditorCaretInAValidPos: Boolean;

    /// <summary>
    /// Modify richedit's windowproc to handle tab key presses.
    /// </summary>
    procedure editorWndProc(var Message: TMessage);
  private

    /// <summary>
    /// When there is output available from FSI, redirect it to the editor control.
    /// </summary>
    procedure doOnPipeOutput(sender: TObject; stream: TStream);

    /// <summary>
    /// When there is error output available from FSI, redirect it to the editor control.
    /// </summary>
    procedure doOnPipeError(sender: TObject; stream: TStream);

    /// <summary>
    /// Handle key down and
    /// 1. Control the area in the editor where typing is allowed.
    /// 2. When Return key is pressed: send text to FSI
    /// 3. Conver tabs to spaces, if necessary.
    /// </summary>
    procedure doOnEditorKeyDown(sender: TObject; var Key: Word; Shift: TShiftState);
    procedure doOnEditorChange(sender: TObject);

    /// <summary>
    /// Delete contenst of editor.
    /// </summary>
    procedure doOnEditorClearContextMenuClick(sender: TObject);

    /// <summary>
    /// Cut/copy/paste text to the clipboard
    /// </summary>
    procedure doOnEditorCutContextMenuClick(sender: TObject);
    procedure doOnEditorCopyContextMenuClick(sender: TObject);
    procedure doOnEditorPasteContextMenuClick(sender: TObject);

    /// <summary>
    /// Check for non-empty text selection and enable "Copy" menu item if true
    /// </summary>
    procedure doOnContextMenuPopup(sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;
    procedure updateEditableAreaStart(ScrollTo: Boolean = False);
    function IsConsoleRunning(echo: Boolean = True): Boolean;
  public

    /// <summary>
    /// Start FSI.
    /// </summary>
    function Start: Boolean;

    /// <summary>
    /// Stop FSI.
    /// </summary>
    procedure Stop;

    /// <summary>
    /// Send text to FSI.
    /// </summary>
    procedure SendText(const selText: WideString; addDelimiter, appendEditor: Boolean; echoErr: Boolean = True);

    /// <summary>
    /// Add text to editor.
    /// </summary>
    procedure AddToEditor(const text: String; const clDefault: TColor = clBlack;
      const clDarkMode: TColor = clWhite);
  public
    /// <summary>
    /// Gets a readonly instance of the config manager.
    /// </summary>
    property Config: TConfiguration read _config;

    /// <summary>
    /// Get the instance of the editor that interfaces with FSI.
    /// </summary>
    property Editor: TRichEdit read _editor;

    /// <summary>
    /// Event raised when text is sent to FSI.
    /// </summary>
    property OnSendText: TNotifyEvent read _onSendText write _onSendText;

    /// <summary>
    /// Event reaised when there is output availabe from FSI.
    /// </summary>
    property OnResultOutput: TNotifyEvent read _onResultOutput write _onResultOutput;

    /// <summary>
    /// Event raised when an error message is generated by FSI.
    /// </summary>
    property OnErrorOutput: TNotifyEvent read _onErrorOutput write _onErrorOutput;
  end;

implementation

uses
  // standard units
  Windows, StrUtils, StdCtrls, SysUtils, Forms,
  // plugin units
  Constants, FSIPlugin;

{$REGION 'Constructor & Destructor' }

constructor TFSIViewer.Create;
begin
  createEditor;
  createContextMenu;
  createFSI;
end;

destructor TFSIViewer.Destroy;
begin
  _pipedConsole.OnError := Nil;
  _pipedConsole.OnOutput := Nil;
  Stop;

  if Assigned(_pipedConsole) then
    FreeAndNil(_pipedConsole);
  if Assigned(_editor) then
    FreeAndNil(_editor);
  if Assigned(_config) then
    FreeAndNil(_config);

  inherited;
end;

{$ENDREGION}

{$REGION 'Public methods'}

function TFSIViewer.Start: Boolean;
var
  cmd, args: String;
begin
  _config.LoadFromConfigFile;
  if _config.UseDotnet then begin
    cmd := 'C:\Windows\System32\cmd.exe';
    args := '/c dotnet fsi';
    if _config.UseArgs then
      args := Concat(args, ' ' + _config.FSIArgs);
  end else begin
    cmd := _config.FSIPath;
    args := _config.FSIArgs;
  end;
  _editor.Enabled := _pipedConsole.Start(cmd, args);
  Result := _editor.Enabled;
end;

procedure TFSIViewer.Stop;
begin
  if (_pipedConsole.Running) then
    _pipedConsole.Stop(0);
end;

procedure TFSIViewer.SendText(const selText: WideString; addDelimiter, appendEditor, echoErr: Boolean);
var
  finalText, lastChars, text: String;
begin
  if (not isConsoleRunning(echoErr)) then
    Exit;

  text := {$IFDEF FPC}UTF8Encode{$ENDIF}(selText);
  if ((Length(text) > 0) and (_pipedConsole.Running)) then
  begin
    if (addDelimiter) then
    begin
      // the delimiter is assumed to be ";;"

      lastChars := RightStr(text, 2);

      if (lastChars = ';;') then
        finalText := text
      else if ((Length(lastChars) > 1) and (lastChars[2] = ';')) then
        finalText := text + ';'
      else
        finalText := text + ' ;;';

      finalText := finalText + #13#10;
    end
    else
    begin
      finalText := text;
    end;

    if (_config.ConvertTabsToSpacesInFSIEditor) then
    begin
      finalText := StringReplace(finalText, #9, DupeString(' ', _config.TabLength), [rfReplaceAll]);
    end;

    if (Length(Trim(finalText)) > 0) then
    begin
      if (appendEditor) then
        AddToEditor(finalText);
      _pipedConsole.Write(finalText[1], SizeOf(Char) * Length(finalText));
    end;

    if Assigned(_onSendText) then
    begin
      _onSendText(self);
    end;
  end;
end;

procedure TFSIViewer.AddToEditor(const text: String; const clDefault: TColor = clBlack;
  const clDarkMode: TColor = clWhite);
begin
  _editor.SelStart := _editor.GetTextLen;
{$IFDEF FPC}
  _editor.SelText := text;
{$ENDIF}
  if Npp.IsDarkModeEnabled then
    _editor.SelAttributes.Color := clDarkMode
  else
    _editor.SelAttributes.Color := clDefault;
{$IFNDEF FPC}
  _editor.SelText := text;
{$ELSE}
  // a TRichMemo's selected text is automatically highlighted
  _editor.SelLength := 0;
{$ENDIF}
end;

{$ENDREGION}

{$REGION 'Private methods'}

procedure TFSIViewer.createEditor;
begin
  _config := TConfiguration.Create;
  _editor := TRichEdit.Create(Nil);
  _editor.OnKeyDown := doOnEditorKeyDown;
  _editor.OnChange := doOnEditorChange;
  _defEditorWndProc := _editor.WindowProc;
  _editor.WindowProc := editorWndProc;
end;

procedure TFSIViewer.createFSI;
begin
  _pipedConsole := TPipeConsole.Create(Nil);
  _pipedConsole.OnOutput := doOnPipeOutput;
  _pipedConsole.OnError := doOnPipeError;
end;

procedure TFSIViewer.createContextMenu;
var
  ctxMenu: TPopupMenu;
  menu: TMenuItem;
  menuCut, menuCopy, menuPaste: TMenuItem;
begin
  ctxMenu := TPopupMenu.Create(_editor);

  menu := TMenuItem.Create(ctxMenu);
  menu.Caption := FSI_PLUGIN_EDITOR_CLEAR_MENU;
  menu.OnClick := doOnEditorClearContextMenuClick;
  ctxMenu.Items.Add(menu);

  menuCut := TMenuItem.Create(ctxMenu);
  menuCut.Caption := 'Cut';
  menuCut.OnClick := doOnEditorCutContextMenuClick;
  ctxMenu.Items.Add(menuCut);

  menuCopy := TMenuItem.Create(ctxMenu);
  menuCopy.Caption := FSI_PLUGIN_EDITOR_COPY_MENU;
  menuCopy.OnClick := doOnEditorCopyContextMenuClick;
  ctxMenu.Items.Add(menuCopy);

  menuPaste := TMenuItem.Create(ctxMenu);
  menuPaste.Caption := 'Paste';
  menuPaste.OnClick := doOnEditorPasteContextMenuClick;
  ctxMenu.Items.Add(menuPaste);

  ctxMenu.OnPopup := doOnContextMenuPopup;
  _editor.PopupMenu := ctxMenu;
end;

procedure TFSIViewer.updateEditableAreaStart(ScrollTo: Boolean);
begin
  _editor.SelStart := _editor.GetTextLen;
  _editableAreaStartCoord := _editor.CaretPos;
  _editableAreaStartPos := _editor.SelStart;
  if ScrollTo then _editor.Perform(WM_VSCROLL, MakeWParam(SB_BOTTOM, 0), 0);
end;

function TFSIViewer.isEditorCaretInAValidPos: Boolean;
begin
  Result := (_editor.CaretPos.Y >= _editableAreaStartCoord.Y) and
    (((_editor.CaretPos.Y = _editableAreaStartCoord.Y) and (_editor.CaretPos.X >= _editableAreaStartCoord.X)) or
      (_editor.CaretPos.Y > _editableAreaStartCoord.Y));
end;

procedure TFSIViewer.editorWndProc(var Message: TMessage);
var
  doDefProc: Boolean;
begin
  doDefProc := true;

  if (Message.Msg = WM_GETDLGCODE) then
  begin
    Message.Result := Message.Result or DLGC_WANTTAB;
  end
  else if (Message.Msg = WM_KEYDOWN) then
  begin
    doDefProc := (TWMKey(Message).CharCode <> VK_TAB);
  end;

  if (doDefProc) then
    _defEditorWndProc(Message);
end;

function TFSIViewer.IsConsoleRunning(echo: Boolean): Boolean;
const
  MsgPrefix = 'Process terminated with code';
var
  DidMessage: Integer;
begin
  DidMessage := _editor.Search(MsgPrefix, _editor.GetTextLen, _editor.GetTextLen, [soBackward]);
  _editor.ReadOnly := (not _pipedConsole.Running);
  if (DidMessage = -1) and _editor.ReadOnly and echo then begin
    AddToEditor(Format(#13#10'%s %d'#13#10,
      [MsgPrefix, _pipedConsole.LastError]), clRed, TColor($4763FF));
    updateEditableAreaStart(True);
  end;
  Result := (not _editor.ReadOnly);
end;
{$ENDREGION}

{$REGION 'Event handlers'}

procedure TFSIViewer.doOnPipeOutput(sender: TObject; stream: TStream);
var
  strStream: TStringStream;
begin
  strStream := TStringStream.Create;
  try
    strStream.CopyFrom(stream, 0);
    if (Length(strStream.DataString) > 2) and SameText(Copy(strStream.DataString, 0, 2), '> ') then
      AddToEditor(Copy(strStream.DataString, 2))
    else
      AddToEditor(strStream.DataString);
    updateEditableAreaStart(True);

    if Assigned(_onResultOutput) then
      _onResultOutput(self);
  finally
    strStream.Free;
  end;
end;

procedure TFSIViewer.doOnPipeError(sender: TObject; stream: TStream);
var
  strStream: TStringStream;
begin
  strStream := TStringStream.Create;
  try
    strStream.CopyFrom(stream, 0);
    AddToEditor(strStream.DataString, clRed, TColor($4763FF));
    updateEditableAreaStart(True);

    if Assigned(_onErrorOutput) then
      _onErrorOutput(self);
  finally
    strStream.Free;
  end;
  AddToEditor('> ');
  updateEditableAreaStart;
end;

procedure TFSIViewer.doOnEditorKeyDown(sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  newText: WideString;
  IsCtrl, IsShift: Boolean;
begin
  if (not isConsoleRunning) then
    Exit;

  IsCtrl  := ([ssCtrl] = Shift);
  IsShift := ([ssShift] = Shift);

  if IsCtrl and (Key in [VK_C, VK_INSERT]) then
  begin
    doOnEditorCopyContextMenuClick(Self);
    Key := 0;
  end
  else if (isEditorCaretInAValidPos) then
  begin
    if (Key = VK_RETURN) then
    begin
      _editor.SelStart := _editableAreaStartPos;
      _editor.SelLength := _editor.GetTextLen - _editableAreaStartPos;
      newText := {$IFDEF FPC}UTF8Decode{$ENDIF}(_editor.SelText);
      updateEditableAreaStart;
      if WideSameText(Copy(newText, 0, 2), '> ') then
        newText := Copy(newText, 2);
      newText := newText + #13#10;
      SendText(newText, false, false);
    end
    else if (Key = VK_UP) then
    begin
      if (_editor.CaretPos.Y = _editableAreaStartCoord.Y) then
        Key := 0;
    end
    else if (Key = VK_LEFT) then
    begin
      if ((_editor.CaretPos.Y = _editableAreaStartCoord.Y) and
          (_editor.CaretPos.X <= _editableAreaStartCoord.X)) or
         ((_editor.CaretPos.X - _editor.SelLength - 1) < _editableAreaStartCoord.X) then
        Key := 0;
    end
    else if (Key = VK_BACK) or (Key = VK_DELETE) then
    begin
      if (_editor.CaretPos.X = _editableAreaStartCoord.X) then
        Key := 0;
    end
    else if (Key = VK_TAB) then
    begin
      if (_config.ConvertTabsToSpacesInFSIEditor) then
      begin
        _editor.SelStart := _editor.GetTextLen;
        _editor.SelText := DupeString(' ', _config.TabLength);
      end;
    end;
  end
  else
  begin
    // let "read-only" text be selected and copied by standard accelerators
    if IsCtrl then
    begin
      if (Key = VK_A) then
        _editor.SelectAll
      else if Key in [VK_V, VK_X, VK_Y, VK_Z] then
        MessageBeep(MB_ICONWARNING);
    end
    else if IsShift then
    begin
      if Key in [VK_INSERT, VK_DELETE] then
        MessageBeep(MB_ICONWARNING);
    end;
    Key := 0;
  end;
end;

procedure TFSIViewer.doOnEditorChange(Sender: TObject);
begin
  if _editor.CanUndo and (_editor.GetTextLen = 0) then doOnEditorClearContextMenuClick(Sender);
end;

procedure TFSIViewer.doOnEditorClearContextMenuClick(sender: TObject);
begin
    _editor.Clear;
    AddToEditor('> ');
    updateEditableAreaStart;
end;

procedure TFSIViewer.doOnEditorCutContextMenuClick(Sender: TObject);
begin
  _editor.CutToClipboard;
end;

procedure TFSIViewer.doOnEditorCopyContextMenuClick(sender: TObject);
begin
  _editor.CopyToClipboard;
  updateEditableAreaStart;
end;

procedure TFSIViewer.doOnEditorPasteContextMenuClick(Sender: TObject);
begin
  _editor.PasteFromClipboard;
end;

procedure TFSIViewer.doOnContextMenuPopup(sender: TObject);
var
  ctxMenu: TPopupMenu;
  menuCut, menuCopy, menuPaste: TMenuItem;
begin
  ctxMenu := _editor.PopupMenu;
  menuCut := ctxMenu.Items.Find('Cut');
  menuPaste := ctxMenu.Items.Find('Paste');
  menuCopy := ctxMenu.Items.Find(FSI_PLUGIN_EDITOR_COPY_MENU);
  if Assigned(menuCut) then
    menuCut.Enabled := (isEditorCaretInAValidPos and (_editor.SelLength > 0));
  if Assigned(menuPaste) then
    menuPaste.Enabled := (isEditorCaretInAValidPos and _editor.CanPaste);
  if Assigned(menuCopy) then
    menuCopy.Enabled := (_editor.SelLength > 0);
end;

{$ENDREGION}

end.
