unit UnitPage;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Effects, FMX.Objects,
  FMX.Filter.Effects, System.Skia, FMX.Skia, FMX.Ani, System.Math;

type
  TForm1 = class(TForm)
    SkPaintBox1: TSkPaintBox;
    swipe: TSwipeTransitionEffect;
    SwipePoint: TSelectionPoint;
    SwipePathAnimation: TPathAnimation;
    procedure SkPaintBox1Draw(ASender: TObject; const ACanvas: ISkCanvas; const ADest: TRectF;
      const AOpacity: Single);
    procedure SkPaintBox1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SwipePathAnimationProcess(Sender: TObject);
    procedure SwipePathAnimationFinish(Sender: TObject);
    procedure SkPaintBox1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
      Y: Single);
  private
    { Private declarations }
    bFinish : Boolean;
  public
    { Public declarations }
    function  CalcCircPageCent(Width, Scale : Single; Swipe : TSwipeTransitionEffect): TPointF;
    procedure swipeImage(Width, Height, Scale : Single;
                        var spa : TPathAnimation;
                        var Swipe : TSwipeTransitionEffect;
                        var sePoint : TSelectionPoint);
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.FormCreate(Sender: TObject);
begin
  SwipePathAnimation.Enabled := False;
  swipe.Enabled              := False;
  SwipePoint.Enabled         := False;
  bFinish                    := True;

end;

procedure TForm1.swipeImage(Width, Height, Scale : Single;
                        var spa : TPathAnimation;
                        var Swipe : TSwipeTransitionEffect;
                        var sePoint : TSelectionPoint);
var
  MidPoint: Single;
begin
  if not Swipe.Enabled or not bFinish then exit;
  if spa.Enabled then exit;

  bFinish := False;
  MidPoint := width / 2;

  spa.Path.Clear;
  sePoint.Position.Point := PointF(0, 0);
  spa.Path.MoveTo(Swipe.MousePoint);

  if Swipe.CornerPoint.X >= MidPoint then
    spa.Path.LineTo(PointF(-width, height/3)*scale)  // anima para a esquerda
  else
    spa.Path.LineTo(PointF(Width*2, Height/3)*Scale);  // anima para a direita

  spa.Start;

end;

function TForm1.CalcCircPageCent(Width, Scale : Single; Swipe : TSwipeTransitionEffect): TPointF;
var
  CenterPoint, MousePoint : TPointF;
  Radius: Single;
  Distance: Single;
begin
  if Swipe.CornerPoint.X > Width / 2 then
      CenterPoint := PointF(0, 0) // Esquerda
    else
      CenterPoint := PointF(Width, 0)*Scale; // Direita

  Radius := Width - 30;

  // Calcule a distância entre o mouse e o centro superior
  MousePoint := Swipe.MousePoint/Scale;
  Distance := Sqrt(Sqr(MousePoint.X - CenterPoint.X) + Sqr(MousePoint.Y - CenterPoint.Y));

  // Se a distância for maior que o raio, ajuste o MousePoint para o ponto limite
  if Distance > Radius then
  begin
    // Calcule o ângulo para o ponto limite
    var Angle := ArcTan2(MousePoint.Y - CenterPoint.Y, MousePoint.X - CenterPoint.X);

    // Restrinja o MousePoint ao raio
    MousePoint.X := CenterPoint.X + Radius * Cos(Angle);
    MousePoint.Y := CenterPoint.Y + Radius * Sin(Angle);
  end;

  Result := MousePoint;
end;

procedure TForm1.SkPaintBox1Click(Sender: TObject);
begin
 // SwipePathAnimation.Enabled  := True;



end;

procedure TForm1.SkPaintBox1Draw(ASender: TObject; const ACanvas: ISkCanvas; const ADest: TRectF;
  const AOpacity: Single);
var
  Image: ISkImage;
begin
  Image := TSkImage.MakeFromEncodedFile('C:\Users\fcr25\OneDrive\Imagens\1.png');
  ACanvas.DrawImageRect(Image, ADest);

end;

procedure TForm1.SkPaintBox1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
  Y: Single);
begin

  if bFinish then
  begin
    swipe.Enabled := True;

    Swipe.MousePoint := PointF(X, Y)*Self.Canvas.Scale;
    Swipe.MousePoint := CalcCircPageCent(SkPaintBox1.Width,
                                         Self.Canvas.Scale,
                                         Swipe)*Self.Canvas.Scale;

    if X <= SkPaintBox1.Width / 2 then
      Swipe.CornerPoint := PointF(0, 0) // Esquerda
    else
      Swipe.CornerPoint := PointF(SkPaintBox1.Width, 0)*Self.Canvas.Scale; // Direita

    swipeImage(SkPaintBox1.Width,
               SkPaintBox1.Height,
               SkPaintBox1.Canvas.Scale,
               SwipePathAnimation,
               swipe,
               SwipePoint);
  end;
end;

procedure TForm1.SwipePathAnimationFinish(Sender: TObject);
begin
  SwipePathAnimation.Enabled := False;
  Swipe.Enabled              := False;
  bFinish                    := True;
end;

procedure TForm1.SwipePathAnimationProcess(Sender: TObject);
begin
  Swipe.MousePoint := SwipePoint.Position.Point;
end;

end.
