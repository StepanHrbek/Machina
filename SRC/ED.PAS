{Tato unita vznikla zkopirovanim Tutor05.pas z TurboVision.
Je to zdrojak toho co se objevi v editoru Masiny po stisku F4.
Chapu, ze kdo trochu TV rozumi, bude me chtit po shlednuti
procedury RawEd zabit.
Jestli nekdo umite lepsi editor a chcete ho mit v Masine,
poslete mi zdrojak, nejlepe jako unitu s procedurou RawEd.
Dement}

unit Ed;

interface
uses Objects;
procedure RawEd(TheFile:FNameStr;line:word);

implementation
uses Memory, Drivers,  Views, Menus, App, MsgBox, Editors, StdDlg;

const
  cmOrderNext = 255;
  cmOrderPrev = 250;
  cmClipShow = 260;
  cmOptionsVideo = 1502;
  cmOptionsSave = 1503;
  cmOptionsLoad = 1504;

type
  TTutorApp = object(TApplication)
    ClipboardWindow: PEditWindow;
    constructor Init;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure NewWindow(TheFile:FNameStr);
    procedure OpenWindow;
  end;

constructor TTutorApp.Init;
var
  R: TRect;
begin
  MaxHeapSize := 8192;
  EditorDialog := StdEditorDialog;
  inherited Init;
  Desktop^.GetExtent(R);
  ClipboardWindow := New(PEditWindow, Init(R, '', wnNoNumber));
  if ValidView(ClipboardWindow) <> nil then
  begin
    ClipboardWindow^.Hide;
    InsertWindow(ClipboardWindow);
    Clipboard := ClipboardWindow^.Editor;
    Clipboard^.CanUndo := False;
  end;
end;

procedure TTutorApp.HandleEvent(var Event: TEvent);
var
  R: TRect;
begin
  inherited HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmClipShow:
        with ClipboardWindow^ do
        begin
          Select;
          Show;
          ClearEvent(Event);
        end;
      cmNew:
        begin
          NewWindow('');
          ClearEvent(Event);
        end;
      cmOpen:
        begin
          OpenWindow;
          ClearEvent(Event);
        end;
    end;
  end;
end;

procedure TTutorApp.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~F~ile', hcNoContext, NewMenu(
      StdFileMenuItems(nil)),
    NewSubMenu('~E~dit', hcNoContext, NewMenu(
      StdEditMenuItems(
      NewLine(
      NewItem('~S~how clipboard', '', kbNoKey, cmClipShow, hcNoContext,
      nil)))),
    nil))
  )));
end;

procedure TTutorApp.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  New(StatusLine, Init(R,
    NewStatusDef(0, $EFFF,
      NewStatusKey('~F3~ Open', kbF3, cmOpen,
      NewStatusKey('~F4~ New', kbF4, cmNew,
      NewStatusKey('~Alt+F3~ Close', kbAltF3, cmClose,
      StdStatusKeys(nil)))),
    NewStatusDef($F000, $FFFF,
      NewStatusKey('~F6~ Next', kbF6, cmOrderNext,
      NewStatusKey('~Shift+F6~ Prev', kbShiftF6, cmOrderPrev,
      StdStatusKeys(nil))), nil))));
end;

procedure TTutorApp.NewWindow(TheFile:FNameStr);
var
  R: TRect;
  TheWindow: PEditWindow;
begin
  R.Assign(0, 0, 60, 20);
  TheWindow := New(PEditWindow, Init(R, TheFile, wnNoNumber));
  InsertWindow(TheWindow);
end;

procedure TTutorApp.OpenWindow;
var
  R: TRect;
  FileDialog: PFileDialog;
  TheFile: FNameStr;
const
  FDOptions: Word = fdOKButton or fdOpenButton;
begin
  TheFile := '*.*';
  New(FileDialog, Init(TheFile, 'Open file', '~F~ile name',
    FDOptions, 1));
  if ExecuteDialog(FileDialog, @TheFile) <> cmCancel then
  begin
    R.Assign(0, 0, 79, 24);
    InsertWindow(New(PEditWindow, Init(R, TheFile, wnNoNumber)));
  end;
end;

procedure RawEd(TheFile:FNameStr;line:word);
var
  TutorApp: TTutorApp;
  Event:    TEvent;
begin
  TutorApp.Init;
  TutorApp.NewWindow(TheFile);
  Event.What:=evKeyDown;
  Event.KeyCode:=kbF5;
  TutorApp.HandleEvent(Event);
  for line:=line downto 1 do begin
    Event.What:=evKeyDown;
    Event.KeyCode:=kbDown;
    TutorApp.HandleEvent(Event);
    end;
  TutorApp.Run;
  TutorApp.Done;
end;

end.
