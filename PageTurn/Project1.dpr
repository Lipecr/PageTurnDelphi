program Project1;

uses
  System.StartUpCopy,
  FMX.Forms,
  UnitPage in 'UnitPage.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
