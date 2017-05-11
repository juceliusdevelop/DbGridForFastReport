(*
  Jucelio Moura - juceliusdevelop@gmail.com
  https://www.youtube.com/channel/UCMDXBe5-lrP-T-molp2cSBg/videos
*)
unit DbGridForFastReport.Core;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes,
  frxDBSet, frxClass, Data.DB, System.UITypes, Vcl.Graphics, Vcl.DBGrids,
  frxExportPDF;

Type
  TDBGridHelper = class helper for TDBGrid
    procedure ShowInReport;
  end;

  TDbGridForFastReportCore = class(TComponent)
  strict private
  private
    class var _DbGridForFastReportCore: TDbGridForFastReportCore;
    function CreateFrxDBDataset(ADataSet: TDataSet;
      const AMethod: TProc<TfrxDBDataset> = nil): TfrxDBDataset;
    function CreateFrxReport(AFrxDBDataset: TfrxDBDataset;
      const AMethod: TProc<TfrxReport> = nil): TfrxReport;
    function CreateFrxReportPage(AFrxReport: TfrxReport;
      const AMethod: TProc<TfrxReportPage> = nil): TfrxReportPage;
    function CreateFrxPageHeader(ATFrxReportPage: TfrxReportPage;
      const AMethod: TProc<TfrxPageHeader> = nil): TfrxPageHeader;
    function CreateFrxMemoView(AOwner: TComponent; const AText: string = '';
      const AFrxAlign: TfrxAlign = TfrxAlign.baWidth;
      const AMethod: TProc<TfrxMemoView> = nil): TfrxMemoView;
    function CreateFrxMasterData(ATFrxReportPage: TfrxReportPage;
      AFrxDBDataset: TfrxDBDataset; const AMethod: TProc<TfrxMasterData> = nil)
      : TfrxMasterData;
    function CreateFrxGroupFooter(AOwner: TComponent; AParent: TfrxComponent;
      const AMethod: TProc<TfrxGroupFooter> = nil): TfrxGroupFooter;
    function CreateFrxGroupHeader(AOwner: TComponent; AParent: TfrxComponent;
      const AMethod: TProc<TfrxGroupHeader> = nil): TfrxGroupHeader;
  public
    class function Instance: TDbGridForFastReportCore;
    procedure ShowReport(AGrid: TDBGrid);
  end;

implementation

uses System.Threading;

function TDbGridForFastReportCore.CreateFrxDBDataset(ADataSet: TDataSet;
  const AMethod: TProc<TfrxDBDataset> = nil): TfrxDBDataset;
begin
  Result := TfrxDBDataset.Create(Self);
  with Result do
  begin
    DataSet := ADataSet;
    UserName := 'ReportDataSet';
  end;
  if Assigned(AMethod) then
    AMethod(Result);
end;

function TDbGridForFastReportCore.CreateFrxGroupFooter(AOwner: TComponent;
  AParent: TfrxComponent; const AMethod: TProc<TfrxGroupFooter> = nil)
  : TfrxGroupFooter;
begin
  Result := TfrxGroupFooter.Create(AOwner);
  with Result do
  begin
    CreateUniqueName;
    Parent := AParent;
  end;
  if Assigned(AMethod) then
    AMethod(Result);
end;

function TDbGridForFastReportCore.CreateFrxGroupHeader(AOwner: TComponent;
  AParent: TfrxComponent; const AMethod: TProc<TfrxGroupHeader> = nil)
  : TfrxGroupHeader;
begin
  Result := TfrxGroupHeader.Create(AOwner);
  with Result do
  begin
    CreateUniqueName;
    Parent := AParent;
  end;
  if Assigned(AMethod) then
    AMethod(Result);
end;

function TDbGridForFastReportCore.CreateFrxMasterData(ATFrxReportPage
  : TfrxReportPage; AFrxDBDataset: TfrxDBDataset;
  const AMethod: TProc<TfrxMasterData> = nil): TfrxMasterData;
begin
  Result := TfrxMasterData.Create(ATFrxReportPage);
  with Result do
  begin
    CreateUniqueName;
    PrintIfDetailEmpty := True;
    DataSet := AFrxDBDataset;
    Height := 20;
    Top := 0;
  end;
  if Assigned(AMethod) then
    AMethod(Result);
end;

function TDbGridForFastReportCore.CreateFrxMemoView(AOwner: TComponent;
  const AText: string = ''; const AFrxAlign: TfrxAlign = TfrxAlign.baWidth;
  const AMethod: TProc<TfrxMemoView> = nil): TfrxMemoView;
begin
  Result := TfrxMemoView.Create(AOwner);
  with Result do
  begin
    CreateUniqueName;
    Align := AFrxAlign;
    Text := AText;
    HAlign := haLeft;
    AllowHTMLTags := True;
    WordWrap := True;
  end;
  if Assigned(AMethod) then
    AMethod(Result);
end;

function TDbGridForFastReportCore.CreateFrxPageHeader(ATFrxReportPage
  : TfrxReportPage; const AMethod: TProc<TfrxPageHeader> = nil): TfrxPageHeader;
begin
  Result := TfrxPageHeader.Create(ATFrxReportPage);
  with Result do
  begin
    CreateUniqueName;
    Top := 0;
    Height := 20;
  end;
  if Assigned(AMethod) then
    AMethod(Result);
end;

function TDbGridForFastReportCore.CreateFrxReport(AFrxDBDataset: TfrxDBDataset;
  const AMethod: TProc<TfrxReport> = nil): TfrxReport;
begin
  Result := TfrxReport.Create(Self);
  Result.DataSets.Add(AFrxDBDataset);
  Result.PreviewOptions.ThumbnailVisible := True;
  if Assigned(AMethod) then
    AMethod(Result);
end;

function TDbGridForFastReportCore.CreateFrxReportPage(AFrxReport: TfrxReport;
  const AMethod: TProc<TfrxReportPage> = nil): TfrxReportPage;
begin
  Result := TfrxReportPage.Create(AFrxReport);
  with Result do
  begin
    CreateUniqueName;
    SetDefaults;
    Orientation := TPrinterOrientation.poPortrait;
  end;
  if Assigned(AMethod) then
    AMethod(Result);
end;

class function TDbGridForFastReportCore.Instance: TDbGridForFastReportCore;
begin
  if (_DbGridForFastReportCore = nil) then
    _DbGridForFastReportCore := TDbGridForFastReportCore.Create(nil);
  Result := _DbGridForFastReportCore;
end;

procedure TDbGridForFastReportCore.ShowReport(AGrid: TDBGrid);
var
  loTask: ITask;
begin
  loTask := TTask.Create(
    procedure()
    begin
      TThread.Synchronize(nil,
        procedure
        begin
          CreateFrxDBDataset(AGrid.DataSource.DataSet,
            procedure(FrxDBDataset: TfrxDBDataset)
            begin
              CreateFrxReport(FrxDBDataset,
                procedure(Report: TfrxReport)
                begin
                  Report.Font.Assign(AGrid.Font);
                  CreateFrxReportPage(Report,
                    procedure(Page: TfrxReportPage)
                    begin
                      CreateFrxPageHeader(Page,
                        procedure(PageHeader: TfrxPageHeader)
                        begin
                          with CreateFrxMemoView(PageHeader) do
                          begin
                            Top := 1.25 * fr1cm;
                            Left := 0;
                            Height := 0;
                            Frame.Typ := [ftBottom];
                            HAlign := haRight;
                            ParentFont := False;
                            VAlign := vaCenter;
                            CreateUniqueName;
                            Align := baWidth;
                          end;

                          CreateFrxMasterData(Page, FrxDBDataset,
                            procedure(MasterData: TfrxMasterData)
                            var
                              loI, loLeft: Integer;
                            begin
                              loLeft := 14;
                              for loI := 0 to Pred(AGrid.Columns.Count) do
                              begin
                                with CreateFrxMemoView(PageHeader,
                                  AGrid.Columns[loI].Title.Caption) do
                                  SetBounds(loLeft, 28,
                                    AGrid.Columns[loI].Width, 16);
                                with CreateFrxMemoView(MasterData) do
                                begin
                                  DataSet := FrxDBDataset;
                                  DataField := AGrid.Columns[loI]
                                    .Field.FieldName;
                                  SetBounds(loLeft, 28,
                                    AGrid.Columns[loI].Width, 16);
                                end;
                                loLeft := loLeft + AGrid.Columns[loI].Width + 2;
                              end;
                            end);
                        end);
                    end);
                  try
                    Report.ShowProgress := True;
                    Report.OldStyleProgress := True;
                    Report.PrepareReport(True);
                    Report.ShowPreparedReport;
                  finally
                    Report.Free;
                  end;
                end);
            end);
        end);
    end);
  loTask.Start;
end;

{ TDBGridHelper }

procedure TDBGridHelper.ShowInReport;
begin
  TDbGridForFastReportCore.Instance.ShowReport(Self);
end;

initialization

ReportMemoryLeaksOnShutdown := True;
TDbGridForFastReportCore._DbGridForFastReportCore := nil;

finalization

if (TDbGridForFastReportCore._DbGridForFastReportCore <> nil) then
  FreeAndNil(TDbGridForFastReportCore._DbGridForFastReportCore);

end.
