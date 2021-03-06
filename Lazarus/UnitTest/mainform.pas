unit MainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  fpcunit, Test;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Image1: TImage;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    aTest:TZXingLazarusTest;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

uses testutils;

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
  aTestResult:TTestResult;
  ml:TStringList;
  i:integer;
begin
  Edit1.Text:='';
  Edit2.Text:='';
  Edit3.Text:='';
  if NOT Assigned(aTest) then
    aTest:=TZXingLazarusTest.Create(Image1,Memo1);
  if Assigned(aTest) then
  begin
    aTestResult:=TTestResult.Create;
    try
      ml := TStringList.Create;
      try
        GetMethodList(TZXingLazarusTest, ml);
        for i := 0 to ml.Count -1 do
        begin
          aTest.TestName:=ml[i];
          Memo1.Lines.Append('');
          Memo1.Lines.Append('*******************');
          Memo1.Lines.Append('Current test: '+aTest.TestName);
          aTest.Run(aTestResult);
        end;
      finally
        ml.Free;
      end;
      Edit1.Text:='Number of tests: '+InttoStr(aTestResult.RunTests);
      Edit2.Text:='Number of failures: '+InttoStr(aTestResult.NumberOfFailures);
      Edit3.Text:='Number of errors: '+InttoStr(aTestResult.NumberOfErrors);
    finally
      aTestResult.Free;
    end;
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if Assigned(aTest) then
    aTest.Free;
end;

end.

