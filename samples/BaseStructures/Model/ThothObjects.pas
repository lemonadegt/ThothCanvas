unit ThothObjects;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Objects, System.Math,
  ThothTypes;

type
  TThShape = class;
  TThShapeClass = class of TThShape;

///////////////////////////////////////////////////////
// Shape
  TThShape = class(TShape, IThShape)
  private
    FGapSize: Integer;
    FThCanvas: IThCanvas;

    FHideSelection: Boolean;
    FMinSize: Integer;

    FRatio: Single;
    FMove, FLeftTop, FLeftBottom, FRightTop, FRightBottom: Boolean;
    FLeftTopHot, FLeftBottomHot, FRightTopHot, FRightBottomHot: Boolean;
    FDownPos, FMovePos: TPointF;
    FGripSize: Single;

    function LocalToParent(P: TPointF): TPointF;
    procedure SetGripSize(const Value: Single);
  protected
//    procedure Paint; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    property GripSize: Single read FGripSize write SetGripSize;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
  end;

  TThLine = class(TThShape)
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TThRectangle = class(TThShape)
  private
    FSides: TSides;
    procedure SetSides(const Value: TSides); virtual;
    function IsSidesStored: Boolean;
  private
    FCornerType: TCornerType;
    FCorners: TCorners;
    FXRadius: Single;
    FYRadius: Single;
    function IsCornersStored: Boolean;
    procedure SetCorners(const Value: TCorners);
    procedure SetCornerType(const Value: TCornerType);
    procedure SetXRadius(const Value: Single);
    procedure SetYRadius(const Value: Single);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;

    property Fill;
    property Stroke;
    property StrokeCap;
    property StrokeDash;
    property StrokeJoin;
    property StrokeThickness;
    property XRadius: Single read FXRadius write SetXRadius;
    property YRadius: Single read FYRadius write SetYRadius;
    property Corners: TCorners read FCorners write SetCorners
      stored IsCornersStored;
    property CornerType: TCornerType read FCornerType write SetCornerType
      default TCornerType.ctRound;
    property Sides: TSides read FSides write SetSides stored IsSidesStored;
  end;

  TThCircle = class(TThShape)
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  end;


implementation

uses
  ThothCanvas;

{ TThShape }

constructor TThShape.Create(AOwner: TComponent);
begin
  inherited;

  FThCanvas := TThCanvas(AOwner);
  FGapSize := 3;
end;

function TThShape.LocalToParent(P: TPointF): TPointF;
begin
//  FOrm1.Memo1.Lines.Add(Format('LocalToParent', []));

  Result.X := Position.X + P.X;
  Result.Y := Position.Y + P.Y;
end;

procedure TThShape.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Single);
var
  P: TPointF;
  R: TRectF;
begin
  inherited;

  if TThCanvas(FThCanvas).DrawMode = dmDraw then
  begin
    P := LocalToParent(PointF(X, Y));
    FThCanvas.MouseDown(Button, Shift, P.X, P.Y);
  end;
{
  FDownPos := PointF(X, Y);
  if Button = TMouseButton.mbLeft then
  begin
    FRatio := Width / Height;
    R := LocalRect;
    R := RectF(R.Left - (GripSize), R.Top - (GripSize), R.Left + (GripSize),
      R.Top + (GripSize));
    if PointInRect(FDownPos, R) then
    begin
      FLeftTop := True;
      Exit;
    end;
    R := LocalRect;
    R := RectF(R.Right - (GripSize), R.Top - (GripSize), R.Right + (GripSize),
      R.Top + (GripSize));
    if PointInRect(FDownPos, R) then
    begin
      FRightTop := True;
      Exit;
    end;
    R := LocalRect;
    R := RectF(R.Right - (GripSize), R.Bottom - (GripSize), R.Right + (GripSize),
      R.Bottom + (GripSize));
    if PointInRect(FDownPos, R) then
    begin
      FRightBottom := True;
      Exit;
    end;
    R := LocalRect;
    R := RectF(R.Left - (GripSize), R.Bottom - (GripSize), R.Left + (GripSize),
      R.Bottom + (GripSize));
    if PointInRect(FDownPos, R) then
    begin
      FLeftBottom := True;
      Exit;
    end;
    Repaint;
    FMove := True;
  end;
}
end;

procedure TThShape.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Single);
begin
  inherited;

end;

{
procedure TThShape.Paint;
var
  R: TRectF;
begin
  inherited;

  if FHideSelection then
    Exit;
  R := LocalRect;
  InflateRect(R, -0.5, -0.5);
  Canvas.Fill.Kind := TBrushKind.bkSolid;
  Canvas.Fill.Color := $FFFFFFFF;
  Canvas.StrokeThickness := 1;
  Canvas.Stroke.Kind := TBrushKind.bkSolid;
  Canvas.Stroke.Color := $FF1072C5;
  Canvas.StrokeDash := TStrokeDash.sdDash;
  Canvas.DrawRect(R, 0, 0, AllCorners, AbsoluteOpacity);
  Canvas.StrokeDash := TStrokeDash.sdSolid;

  R := LocalRect;
  InflateRect(R, -0.5, -0.5);
  if FLeftTopHot then
    Canvas.Fill.Color := $FFFF0000
  else
    Canvas.Fill.Color := $FFFFFFFF;
  Canvas.FillEllipse(RectF(R.Left - (GripSize), R.Top - (GripSize),
    R.Left + (GripSize), R.Top + (GripSize)), AbsoluteOpacity);
  Canvas.DrawEllipse(RectF(R.Left - (GripSize), R.Top - (GripSize),
    R.Left + (GripSize), R.Top + (GripSize)), AbsoluteOpacity);
  R := LocalRect;
  if FRightTopHot then
    Canvas.Fill.Color := $FFFF0000
  else
    Canvas.Fill.Color := $FFFFFFFF;
  Canvas.FillEllipse(RectF(R.Right - (GripSize), R.Top - (GripSize),
    R.Right + (GripSize), R.Top + (GripSize)), AbsoluteOpacity);
  Canvas.DrawEllipse(RectF(R.Right - (GripSize), R.Top - (GripSize),
    R.Right + (GripSize), R.Top + (GripSize)), AbsoluteOpacity);
  R := LocalRect;
  if FLeftBottomHot then
    Canvas.Fill.Color := $FFFF0000
  else
    Canvas.Fill.Color := $FFFFFFFF;
  Canvas.FillEllipse(RectF(R.Left - (GripSize), R.Bottom - (GripSize),
    R.Left + (GripSize), R.Bottom + (GripSize)), AbsoluteOpacity);
  Canvas.DrawEllipse(RectF(R.Left - (GripSize), R.Bottom - (GripSize),
    R.Left + (GripSize), R.Bottom + (GripSize)), AbsoluteOpacity);
  R := LocalRect;
  if FRightBottomHot then
    Canvas.Fill.Color := $FFFF0000
  else
    Canvas.Fill.Color := $FFFFFFFF;
  Canvas.FillEllipse(RectF(R.Right - (GripSize), R.Bottom - (GripSize),
    R.Right + (GripSize), R.Bottom + (GripSize)), AbsoluteOpacity);
  Canvas.DrawEllipse(RectF(R.Right - (GripSize), R.Bottom - (GripSize),
    R.Right + (GripSize), R.Bottom + (GripSize)), AbsoluteOpacity);
end;
}
procedure TThShape.SetGripSize(const Value: Single);
begin
  if FGripSize <> Value then
  begin
    FGripSize := Value;
    if FGripSize > 20 then
      FGripSize := 20;
    if FGripSize < 1 then
      FGripSize := 1;
    Repaint;
  end;
end;

{ TThLine }

constructor TThLine.Create(AOwner: TComponent);
begin
  inherited;
end;

procedure TThLine.Paint;
begin
  Canvas.DrawLine(GetShapeRect.TopLeft, GetShapeRect.BottomRight,
    AbsoluteOpacity);
end;

{ TThRectangle }

constructor TThRectangle.Create(AOwner: TComponent);
begin
  inherited;

  FCorners := AllCorners;
  FXRadius := 0;
  FYRadius := 0;
  FSides := AllSides;

  Fill.Kind := TBrushKind.bkNone;
end;

function TThRectangle.IsCornersStored: Boolean;
begin
  Result := FCorners <> AllCorners;
end;

function TThRectangle.IsSidesStored: Boolean;
begin
  Result := FSides * AllSides <> AllSides
end;

procedure TThRectangle.Paint;
var
  R: TRectF;
  Off: Single;
begin
  inherited;

  R := GetShapeRect;
  if Sides <> AllSides then
  begin
    Off := R.Left;
    if not(TSide.sdTop in FSides) then
      R.Top := R.Top - Off;
    if not(TSide.sdLeft in FSides) then
      R.Left := R.Left - Off;
    if not(TSide.sdBottom in FSides) then
      R.Bottom := R.Bottom + Off;
    if not(TSide.sdRight in FSides) then
      R.Right := R.Right + Off;
    Canvas.FillRect(R, XRadius, YRadius, FCorners, AbsoluteOpacity, CornerType);
    Canvas.DrawRectSides(GetShapeRect, XRadius, YRadius, FCorners,
      AbsoluteOpacity, Sides, CornerType);
  end
  else
  begin
    Canvas.FillRect(R, XRadius, YRadius, FCorners, AbsoluteOpacity, CornerType);
    Canvas.DrawRect(R, XRadius, YRadius, FCorners, AbsoluteOpacity, CornerType);
  end;
end;

procedure TThRectangle.SetCorners(const Value: TCorners);
begin
  if FCorners <> Value then
  begin
    FCorners := Value;
    Repaint;
  end;
end;

procedure TThRectangle.SetCornerType(const Value: TCornerType);
begin
  if FCornerType <> Value then
  begin
    FCornerType := Value;
    Repaint;
  end;
end;

procedure TThRectangle.SetSides(const Value: TSides);
begin
  if FSides <> Value then
  begin
    FSides := Value;
    Repaint;
  end;
end;

procedure TThRectangle.SetXRadius(const Value: Single);
begin
  if FXRadius <> Value then
  begin
    FXRadius := Value;
    Repaint;
  end;
end;

procedure TThRectangle.SetYRadius(const Value: Single);
begin
  if FYRadius <> Value then
  begin
    FYRadius := Value;
    Repaint;
  end;
end;

{ TTHCircle }

constructor TThCircle.Create(AOwner: TComponent);
begin
  inherited;

  Fill.Kind := TBrushKind.bkNone;
end;

procedure TThCircle.Paint;
var
  R: TRectF;
begin
  R := RectF(0, 0, Max(Width, Height), Max(Width, Height));
  FitRect(R, GetShapeRect);
  Canvas.FillEllipse(R, AbsoluteOpacity);
  Canvas.DrawEllipse(R, AbsoluteOpacity);
end;

end.