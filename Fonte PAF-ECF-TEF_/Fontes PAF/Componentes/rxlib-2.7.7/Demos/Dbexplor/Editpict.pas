{*******************************************************}
{                                                       }
{     Delphi VCL Extensions (RX) demo program           }
{                                                       }
{     Copyright (c) 1996 AO ROSNO                       }
{     Copyright (c) 1997 Master-Bank                    }
{                                                       }
{*******************************************************}

unit EditPict;

{$I RX.INC}

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons, Dialogs,
  StdCtrls, ExtCtrls, Placemnt, DBCtrls, DB, Menus
  {$IFDEF RX_D3}, ExtDlgs, ComCtrls {$ENDIF};

type
  TPictEditDlg = class(TForm)
    OkBtn: TBitBtn;
    CancelBtn: TBitBtn;
    LoadBtn: TBitBtn;
    Bevel: TBevel;
    FormPlacement: TFormPlacement;
    SaveBtn: TBitBtn;
    DataSource: TDataSource;
    DBNavigator: TDBNavigator;
    DBImage: TDBImage;
    StretchBox: TCheckBox;
    PopupMenu: TPopupMenu;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    Clear1: TMenuItem;
    N1: TMenuItem;
    procedure FileOpen(Sender: TObject);
    procedure ImageKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SaveBtnClick(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
    procedure StretchBoxClick(Sender: TObject);
    procedure MenuClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
{$IFDEF RX_D3}
    OpenDialog: TOpenPictureDialog;
    SaveDialog: TSavePictureDialog;
{$ELSE}
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
{$ENDIF}
    procedure UpdatePictureField;
  end;

function PictureEdit(DataSet: TDataSet; const FieldName: string): Boolean;

implementation

{$R *.DFM}

uses Messages, SysUtils {$IFDEF USE_RX_GIF}, RxGIF {$ENDIF}
  {$IFDEF RX_D3}, Jpeg {$ENDIF};

function PictureEdit(DataSet: TDataSet; const FieldName: string): Boolean;
begin
  with TPictEditDlg.Create(Application) do
  try
    DataSource.DataSet := DataSet;
    DBImage.DataField := FieldName;
    ActiveControl := DBImage;
    Caption := Format('Field: %s', [FieldName]);
    Result := (ShowModal = mrOk);
  finally
    Free;
  end;
end;

{ TPictEditDlg }

procedure TPictEditDlg.UpdatePictureField;
var
  Tmp: TBitmap;
begin
  if (DBImage.Picture.Graphic <> nil) and
    not (DBImage.Picture.Graphic.Empty) then
  begin
    if not (DBImage.Picture.Graphic is TBitmap) then begin
      Tmp := TBitmap.Create;
      try
        Tmp.Assign(DBImage.Picture.Graphic);
        DBImage.Picture.Assign(Tmp);
      finally
        Tmp.Free;
      end;
    end;
  end;
end;

procedure TPictEditDlg.FileOpen(Sender: TObject);
begin
  with OpenDialog do begin
    DefaultExt := 'BMP';
    Filter := GraphicFilter(TGraphic);
    if Execute then begin
      if DataSource.AutoEdit then DataSource.Edit;
      DBImage.Picture.LoadFromFile(FileName);
      UpdatePictureField;
    end;
  end;
end;

procedure TPictEditDlg.ImageKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  {if Key = VK_ESCAPE then CancelBtn.Click;}
end;

procedure TPictEditDlg.SaveBtnClick(Sender: TObject);
begin
  with SaveDialog do begin
    if (DBImage.Picture.Graphic <> nil) and
      not (DBImage.Picture.Graphic.Empty) then
    begin
      DefaultExt := GraphicExtension(TGraphicClass(DBImage.Picture.Graphic.ClassType));
      Filter := GraphicFilter(TGraphicClass(DBImage.Picture.Graphic.ClassType));
    end
    else begin
      DefaultExt := 'BMP';
      Filter := GraphicFilter(TGraphic);
    end;
    if Execute then DBImage.Picture.SaveToFile(FileName);
  end;
end;

procedure TPictEditDlg.OkBtnClick(Sender: TObject);
begin
  UpdatePictureField;
  ModalResult := mrOk;
end;

procedure TPictEditDlg.StretchBoxClick(Sender: TObject);
begin
  DBImage.Stretch := StretchBox.Checked;
end;

procedure TPictEditDlg.MenuClick(Sender: TObject);
begin
  case Integer(TMenuItem(Sender).Tag) of
    1: DBImage.Perform(WM_CUT, 0, 0);
    2: DBImage.Perform(WM_COPY, 0, 0);
    3: DBImage.Perform(WM_PASTE, 0, 0);
    4: begin
         if DataSource.AutoEdit then DataSource.Edit;
         DBImage.Picture.Graphic := nil;
         UpdatePictureField;
       end;
  end;
end;

procedure TPictEditDlg.FormCreate(Sender: TObject);
begin
{$IFDEF RX_D3}
  OpenDialog := TOpenPictureDialog.Create(Self);
  SaveDialog := TSavePictureDialog.Create(Self);
{$ELSE}
  OpenDialog := TOpenDialog.Create(Self);
  SaveDialog := TSaveDialog.Create(Self);
{$ENDIF}
  with OpenDialog do begin
    Title := 'Load picture';
    Options := [ofHideReadOnly, ofFileMustExist, ofShowHelp];
  end;
  with SaveDialog do begin
    Title := 'Save picture as';
    Options := [ofHideReadOnly, ofFileMustExist, ofShowHelp,
      ofOverwritePrompt];
  end;
end;

end.
