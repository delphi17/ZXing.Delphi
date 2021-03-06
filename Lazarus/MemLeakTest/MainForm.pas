unit MainForm;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ZXing.ScanManager,
  ZXing.ResultMetaDataType,
  ZXing.BarcodeFormat,
  ZXing.ReadResult,
  ZXing.ResultPoint;

type
  TForm2 = class(TForm)
    btnCode128: TButton;
    btnCode93: TButton;
    btnEAN13: TButton;
    btnITF: TButton;
    btnQRCode: TButton;
    btnDataMatrix: TButton;
    btnDummy: TButton;
    imgResult: TImage;
    edResult: TEdit;
    btnEAN8: TButton;
    btnUPC_a: TButton;
    btnUPCE: TButton;
    btnCode39: TButton;
    procedure btnCode128Click(Sender: TObject);
    procedure btnQRCodeClick(Sender: TObject);
    procedure btnDataMatrixClick(Sender: TObject);
    procedure btnITFClick(Sender: TObject);
    procedure btnCode93Click(Sender: TObject);
    procedure btnDummyClick(Sender: TObject);
    procedure btnEAN13Click(Sender: TObject);
    procedure btnEAN8Click(Sender: TObject);
    procedure btnUPC_aClick(Sender: TObject);
    procedure btnUPCEClick(Sender: TObject);
    procedure btnCode39Click(Sender: TObject);
  private
    procedure OnScanManagerResultPoint(const point: IResultPoint);
    function GetImage(Filename: string): TBitmap;
    function decode(const Filename: String;
      const CodeFormat: TBarcodeFormat): TReadResult;
  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

{ TForm2 }

function TForm2.decode(const Filename: String;
  const CodeFormat: TBarcodeFormat): TReadResult;
var
  bmp: TBitmap;
  ScanManager: TScanManager;
  rs: TReadResult;
  obj : IMetaData;
  strMetadata: IStringMetaData;
  ResultPoint: IResultPoint;
const
  iSize = 5;
begin
  bmp := GetImage(Filename);
  try
    ScanManager := TScanManager.Create(CodeFormat, nil);
    //ScanManager.OnResultPoint := Self.OnScanManagerResultPoint;

    rs := ScanManager.Scan(bmp);
    if (rs <> nil) then
    begin
      edResult.Text := rs.Text;
      if (rs.ResultMetaData <> nil) and
          rs.ResultMetaData.ContainsKey(TResultMetaDataType.ERROR_CORRECTION_LEVEL) then
      begin
        obj := rs.ResultMetaData.Items[TResultMetaDataType.ERROR_CORRECTION_LEVEL];
        if Supports(obj,IStringMetaData,strMetadata)
        then
           edResult.Text := edResult.Text + ' (ECLevel: ' + strMetadata.Value + ')';
      end;
      //bmp.BeginUpdate();
      try
        bmp.Canvas.Brush.Color := clRed;
        bmp.Canvas.Brush.Style := bsSolid;
        bmp.Canvas.Pen.Width   := 1;
        bmp.Canvas.Pen.Color   := clLime;
        for ResultPoint in rs.ResultPoints do
          bmp.Canvas.Ellipse(TRect.Create(Round(ResultPoint.x - iSize),
                                          Round(ResultPoint.y - iSize),
                                          Round(ResultPoint.x + iSize),
                                          Round(ResultPoint.y + iSize)));
      finally
        //bmp.EndUpdate();
      end;

      imgResult.Picture.Bitmap.Assign(bmp);
    end;
  finally
    FreeAndNil(bmp);
    FreeAndNil(ScanManager);
    FreeAndNil(rs);
  end;

  Result := nil;
end;

procedure TForm2.OnScanManagerResultPoint(const point: IResultPoint);
begin
  if Assigned(point)
  then
     ShowMessage(point.ToString);
end;

function TForm2.GetImage(Filename: string): TBitmap;
var
  img: TImage;
  //fpimg:TFPMemoryImage;
  fs: string;
begin
  result:=nil;
  img := TImage.Create(nil);
  //fpimg:=TFPMemoryImage.create(0,0);
  //fpimg.UsePalette:=false;
  try
    {$ifdef Windows}
    fs := ExtractFileDir(ParamStr(0)) + '\..\..\..\UnitTest\Images\' + Filename;
    {$else}
    fs := ExtractFileDir(ParamStr(0)) + '/../../../UnitTest/Images/' + Filename;
    {$endif}
    if NOT FileExists(fs) then
    begin
      {$ifdef Windows}
      fs := ExtractFileDir(ParamStr(0)) + '\Images\' + Filename;
      {$else}
      fs := ExtractFileDir(ParamStr(0)) + '/Images/' + Filename;
      {$endif}
    end;
    if FileExists(fs) then
    begin
      try
        //fpimg.LoadFromFile(fs);
        img.Picture.LoadFromFile(fs);
        result := TBitmap.Create;
        //result.PixelFormat := pf32bit;
        result.Assign(img.Picture.Bitmap);
      except
        //on E:FPImageException do
        begin
          {$ifndef GUI}
          writeln('Please note: FPC could not handle/load file '+ExtractFileName(fs)+'.');
          writeln('Tests with this file will be skipped.');
          FreeAndNil(result);
          {$endif}
        end;
      end;
    end;
  finally
    img.Free;
    //fpimg.Free;
  end;
end;

procedure TForm2.btnCode128Click(Sender: TObject);
begin
  Decode('Code128.png', TBarcodeFormat.CODE_128);
end;

procedure TForm2.btnCode39Click(Sender: TObject);
begin
  Decode('Code39.png', TBarcodeFormat.CODE_39);
end;

procedure TForm2.btnCode93Click(Sender: TObject);
begin
  Decode('Code93-1.png', TBarcodeFormat.CODE_93);
end;

procedure TForm2.btnDummyClick(Sender: TObject);
begin
  Decode('Dummy.png', TBarcodeFormat.Auto);
end;

procedure TForm2.btnEAN13Click(Sender: TObject);
begin
  Decode('EAN13.gif', TBarcodeFormat.EAN_13);
end;

procedure TForm2.btnEAN8Click(Sender: TObject);
begin
  Decode('EAN8.png', TBarcodeFormat.EAN_8);
end;

procedure TForm2.btnITFClick(Sender: TObject);
begin
  Decode('ITF-1.png', TBarcodeFormat.ITF);
end;

procedure TForm2.btnQRCodeClick(Sender: TObject);
begin
  Decode('QRCode.png', TBarcodeFormat.QR_CODE);
end;

procedure TForm2.btnUPCEClick(Sender: TObject);
begin
  Decode('upce.png', TBarcodeFormat.UPC_E);
end;

procedure TForm2.btnUPC_aClick(Sender: TObject);
begin
  Decode('upca.png', TBarcodeFormat.UPC_A);
end;

procedure TForm2.btnDataMatrixClick(Sender: TObject);
begin
  Decode('dmc1.png', TBarcodeFormat.DATA_MATRIX);
end;

end.
