unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ExtCtrls,
  StdCtrls, LCLIntf, Math, FPReadPNG, FPReadJPEG;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnZoomOut: TButton;
    Button1: TButton;
    btnZoomIn: TButton;
    EditMagnitude: TEdit;
    EditDirecao: TEdit;
    Image1: TImage;
    Image2: TImage;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuAbrir: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem; // Nova Limiarização Manual
    MenuItem19: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    MenuSalvar: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    ScrollBox1: TScrollBox;
    ScrollBox2: TScrollBox;
    procedure btnZoomInClick(Sender: TObject);
    procedure btnZoomOutClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem13Click(Sender: TObject);
    procedure MenuItem14Click(Sender: TObject);
    procedure MenuItem15Click(Sender: TObject);
    procedure MenuItem16Click(Sender: TObject);
    procedure MenuItem17Click(Sender: TObject);
    procedure MenuItem18Click(Sender: TObject); // Clique Limiarização Manual
    procedure MenuItem20Click(Sender: TObject);
    procedure MenuItem21Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure MenuSalvarClick(Sender: TObject);
    procedure MenuAbrirClick(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

  // === VARIÁVEIS GLOBAIS DE PDI ===
  ImE: array[0..4000, 0..4000] of Integer; // Imagem de Entrada
  ImS: array[0..4000, 0..4000] of Integer; // Imagem de Saída
  ImgWidth, ImgHeight: Integer;            // Dimensões reais da imagem

  // === VARIÁVEIS EXIGIDAS PARA AULA 7 ===
  C: array[0..127, 0..127] of Double;     // Matriz de Coeficientes DCT
  f: array[0..127, 0..127] of Integer;    // Matriz Reconstruída IDCT

implementation

{$R *.lfm}

procedure swap(var a, b: Integer);
var
  temp: Integer;
begin
  temp := a;
  a := b;
  b := temp;
end;

{ TForm1 }

// === FILTRO PONTO MÉDIO (BOTÃO PROCESSAR) ===
procedure TForm1.Button1Click(Sender: TObject);
var
  i, j, vizinhoX, vizinhoY, k, aux: Integer;
  valoresVizinhos: array[0..8] of Integer;
  minVal, maxVal, pontoMedio: Integer;
begin
  if (ImgWidth = 0) or (ImgHeight = 0) then
  begin
    ShowMessage('Por favor, abra uma imagem primeiro!');
    Exit;
  end;

  for i := 1 to ImgWidth - 2 do
  begin
    for j := 1 to ImgHeight - 2 do
    begin
      k := 0;
      for vizinhoX := -1 to 1 do
      begin
        for vizinhoY := -1 to 1 do
        begin
          valoresVizinhos[k] := ImE[i + vizinhoX, j + vizinhoY];
          Inc(k);
        end;
      end;

      for k := 0 to 7 do
      begin
        for aux := k + 1 to 8 do
        begin
          if valoresVizinhos[k] > valoresVizinhos[aux] then
            swap(valoresVizinhos[k], valoresVizinhos[aux]);
        end;
      end;

      minVal := valoresVizinhos[0];
      maxVal := valoresVizinhos[8];
      pontoMedio := (minVal + maxVal) div 2;

      ImS[i, j] := pontoMedio;
    end;
  end;

  for i := 0 to ImgWidth - 1 do
  begin
    for j := 0 to ImgHeight - 1 do
    begin
      if (i = 0) or (i = ImgWidth - 1) or (j = 0) or (j = ImgHeight - 1) then
        ImS[i, j] := ImE[i, j];

      Image2.Picture.Bitmap.Canvas.Pixels[i, j] := RGBToColor(ImS[i, j], ImS[i, j], ImS[i, j]);
    end;
  end;

  Image2.Invalidate;
  ShowMessage('Filtro de Ponto Médio aplicado com sucesso!');
end;

procedure TForm1.btnZoomInClick(Sender: TObject);
begin
  Image1.Stretch := True;
  Image1.Proportional := True;
  Image2.Stretch := True;
  Image2.Proportional := True;

  Image1.Width  := Round(Image1.Width * 1.2);
  Image1.Height := Round(Image1.Height * 1.2);
  Image2.Width  := Round(Image2.Width * 1.2);
  Image2.Height := Round(Image2.Height * 1.2);
end;

procedure TForm1.btnZoomOutClick(Sender: TObject);
begin
  if (Image1.Width > 50) then
  begin
    Image1.Width  := Round(Image1.Width / 1.2);
    Image1.Height := Round(Image1.Height / 1.2);
    Image2.Width  := Round(Image2.Width / 1.2);
    Image2.Height := Round(Image2.Height / 1.2);
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
end;

// === AULA 9: DETECTOR DE BORDAS DE SOBEL ===
procedure TForm1.MenuItem10Click(Sender: TObject);
var
  i, j: Integer;
  gx, gy: Integer;
  magnitude: Double;
begin
  if (ImgWidth = 0) or (ImgHeight = 0) then begin ShowMessage('Abra uma imagem primeiro!'); Exit; end;

  for i := 1 to ImgWidth - 2 do
  begin
    for j := 1 to ImgHeight - 2 do
    begin
      gx := (-1 * ImE[i-1, j-1]) + (0 * ImE[i+1, j-1]) +
            (-2 * ImE[i-1, j])   + (2 * ImE[i+1, j]) +
            (-1 * ImE[i-1, j+1]) + (1 * ImE[i+1, j+1]);

      gy := (-1 * ImE[i-1, j-1]) + (-2 * ImE[i, j-1]) + (-1 * ImE[i+1, j-1]) +
            (1  * ImE[i-1, j+1]) + (2  * ImE[i, j+1]) + (1  * ImE[i+1, j+1]);

      magnitude := Sqrt((gx * gx) + (gy * gy));

      if magnitude > 255 then magnitude := 255;
      if magnitude < 0 then magnitude := 0;

      ImS[i, j] := Round(magnitude);
    end;
  end;

  for i := 0 to ImgWidth - 1 do
    for j := 0 to ImgHeight - 1 do
    begin
      if (i = 0) or (i = ImgWidth - 1) or (j = 0) or (j = ImgHeight - 1) then ImS[i, j] := 0;
      Image2.Picture.Bitmap.Canvas.Pixels[i, j] := RGBToColor(ImS[i, j], ImS[i, j], ImS[i, j]);
    end;

  Image2.Invalidate;
  EditMagnitude.Text := 'Sobel Ativo';
  EditDirecao.Text := 'Gx + Gy';
  ShowMessage('Filtro de Sobel aplicado!');
end;

// === AULA 9: OPERADOR LAPLACIANO ===
procedure TForm1.MenuItem11Click(Sender: TObject);
var
  i, j, valorLaplace: Integer;
begin
  if (ImgWidth = 0) or (ImgHeight = 0) then begin ShowMessage('Abra uma imagem primeiro!'); Exit; end;

  for i := 1 to ImgWidth - 2 do
  begin
    for j := 1 to ImgHeight - 2 do
    begin
      valorLaplace := (-1 * ImE[i-1, j-1]) + (-1 * ImE[i, j-1]) + (-1 * ImE[i+1, j-1]) +
                      (-1 * ImE[i-1, j])   + (8  * ImE[i, j])   + (-1 * ImE[i+1, j]) +
                      (-1 * ImE[i-1, j+1]) + (-1 * ImE[i, j+1]) + (-1 * ImE[i+1, j+1]);

      if valorLaplace > 255 then valorLaplace := 255;
      if valorLaplace < 0 then valorLaplace := 0;

      ImS[i, j] := valorLaplace;
    end;
  end;

  for i := 0 to ImgWidth - 1 do
    for j := 0 to ImgHeight - 1 do
    begin
      if (i = 0) or (i = ImgWidth - 1) or (j = 0) or (j = ImgHeight - 1) then ImS[i, j] := 0;
      Image2.Picture.Bitmap.Canvas.Pixels[i, j] := RGBToColor(ImS[i, j], ImS[i, j], ImS[i, j]);
    end;

  Image2.Invalidate;
  EditMagnitude.Text := 'Laplaciano';
  EditDirecao.Text := 'Isotrópico';
  ShowMessage('Filtro Laplaciano aplicado com sucesso!');
end;

// === AULA 7: FILTRO PASSA-BAIXA NA FREQUÊNCIA ===
procedure TForm1.MenuItem12Click(Sender: TObject);
var
  u, v, corte: Integer;
begin
  if (ImgWidth <> 128) or (ImgHeight <> 128) then
  begin
    ShowMessage('Utilize uma imagem 128x128.');
    Exit;
  end;

  try
    corte := StrToInt(EditMagnitude.Text);
  except
    corte := 77;
    EditMagnitude.Text := '77';
  end;

  for u := 0 to 127 do
  begin
    for v := 0 to 127 do
    begin
      if Sqrt((u * u) + (v * v)) > corte then
      begin
        C[u, v] := 0.0;
      end;
    end;
  end;

  ShowMessage('Filtro Passa-Baixa aplicado na matriz C com corte em: ' + IntToStr(corte) + '. Clique em IDCT para ver o espaço.');
end;

// === AULA 7: FILTRO PASSA-ALTA NA FREQUÊNCIA ===
procedure TForm1.MenuItem13Click(Sender: TObject);
var
  u, v, corte: Integer;
begin
  if (ImgWidth <> 128) or (ImgHeight <> 128) then
  begin
    ShowMessage('Utilize uma imagem 128x128.');
    Exit;
  end;

  try
    corte := StrToInt(EditMagnitude.Text);
  except
    corte := 15;
    EditMagnitude.Text := '15';
  end;

  for u := 0 to 127 do
  begin
    for v := 0 to 127 do
    begin
      if (u = 0) and (v = 0) then Continue;

      if Sqrt((u * u) + (v * v)) <= corte then
      begin
        C[u, v] := 0.0;
      end;
    end;
  end;

  ShowMessage('Filtro Passa-Alta aplicado na matriz C com corte em: ' + IntToStr(corte) + '. Clique em IDCT para ver o espaço.');
end;

// === AULA 7: INSERIR RUÍDO DINÂMICO NA FREQUÊNCIA ===
procedure TForm1.MenuItem14Click(Sender: TObject);
var
  u, v, valor: Integer;
begin
  if (ImgWidth <> 128) or (ImgHeight <> 128) then
  begin
    ShowMessage('Utilize uma imagem 128x128.');
    Exit;
  end;

  u := StrToIntDef(InputBox('Ruído', 'Frequência U:', '10'), 10);
  v := StrToIntDef(InputBox('Ruído', 'Frequência V:', '10'), 10);
  valor := StrToIntDef(InputBox('Ruído', 'Valor:', '5000'), 5000);

  if (u >= 0) and (u < 128) and (v >= 0) and (v < 128) then
  begin
     C[u, v] := C[u, v] + valor;
     ShowMessage('Ruído de +' + IntToStr(valor) + ' adicionado em C['+IntToStr(u)+','+IntToStr(v)+']. Execute a IDCT!');
  end
  else
     ShowMessage('Índices fora do intervalo 0-127!');
end;

// === AULA 8.3: PSEUDO CORES ===
procedure TForm1.MenuItem15Click(Sender: TObject);
var
  i, j: Integer;
  v: Byte;
  r, g, b: Byte;
begin
  if (ImgWidth = 0) then Exit;
  for i := 0 to ImgWidth - 1 do
    for j := 0 to ImgHeight - 1 do
    begin
      v := ImE[i, j];
      r := v;
      g := Round(255 * Sin((v / 255.0) * Pi));
      b := 255 - v;
      Image2.Picture.Bitmap.Canvas.Pixels[i, j] := RGBToColor(r, g, b);
    end;
  Image2.Invalidate;
  ShowMessage('Pseudo-cores aplicadas!');
end;

// === AULA 8.3: EQUALIZAÇÃO NO CANAL L (HSL COLORIDO REAL) ===
procedure TForm1.MenuItem16Click(Sender: TObject);
var
  i, j, tom, L_int: Integer;
  hist: array[0..255] of Integer;
  histC: array[0..255] of Double;
  totalPixels: Double;
  somaHist: Integer;
  corLocal: TColor;
  r, g, b: Byte;
  vMax, vMin, delta, H, S, L: Double;
  r_norm, g_norm, b_norm, q, p: Double;

  function HueToRGB(p, q, t: Double): Double;
  begin
    if t < 0 then t := t + 1;
    if t > 1 then t := t - 1;
    if t < 1/6 then Exit(p + (q - p) * 6 * t);
    if t < 1/2 then Exit(q);
    if t < 2/3 then Exit(p + (q - p) * (2/3 - t) * 6);
    Exit(p);
  end;

begin
  if (ImgWidth = 0) then Exit;
  for tom := 0 to 255 do hist[tom] := 0;

  // 1. Mapeamento RGB -> HSL e acúmulo do histograma do canal L
  for i := 0 to ImgWidth - 1 do
  begin
    for j := 0 to ImgHeight - 1 do
    begin
      corLocal := Image1.Picture.Bitmap.Canvas.Pixels[i, j];
      r := Red(corLocal); g := Green(corLocal); b := Blue(corLocal);

      r_norm := r / 255.0; g_norm := g / 255.0; b_norm := b / 255.0;
      vMax := Max(r_norm, Max(g_norm, b_norm));
      vMin := Min(r_norm, Min(g_norm, b_norm));

      L := (vMax + vMin) / 2.0;
      L_int := EnsureRange(Round(L * 255.0), 0, 255);
      Inc(hist[L_int]);
    end;
  end;

  // 2. Criação da Cumulative Distribution Function (CDF) do canal L
  totalPixels := ImgWidth * ImgHeight;
  somaHist := 0;
  for tom := 0 to 255 do
  begin
    somaHist := somaHist + hist[tom];
    histC[tom] := (somaHist / totalPixels) * 255.0;
  end;

  // 3. Aplicação do canal L equalizado e conversão reversa para RGB
  for i := 0 to ImgWidth - 1 do
  begin
    for j := 0 to ImgHeight - 1 do
    begin
      corLocal := Image1.Picture.Bitmap.Canvas.Pixels[i, j];
      r := Red(corLocal); g := Green(corLocal); b := Blue(corLocal);
      r_norm := r / 255.0; g_norm := g / 255.0; b_norm := b / 255.0;
      vMax := Max(r_norm, Max(g_norm, b_norm));
      vMin := Min(r_norm, Min(g_norm, b_norm));
      delta := vMax - vMin;

      L := (vMax + vMin) / 2.0;
      if delta = 0 then
      begin
        H := 0; S := 0;
      end
      else
      begin
        if L < 0.5 then S := delta / (vMax + vMin) else S := delta / (2.0 - vMax - vMin);
        if vMax = r_norm then H := (g_norm - b_norm) / delta + (IfThen(g_norm < b_norm, 6, 0))
        else if vMax = g_norm then H := (b_norm - r_norm) / delta + 2
        else H := (r_norm - g_norm) / delta + 4;
        H := H / 6.0;
      end;

      L_int := EnsureRange(Round(L * 255.0), 0, 255);
      L := histC[L_int] / 255.0;

      if S = 0 then
      begin
        r := EnsureRange(Round(L * 255), 0, 255);
        g := EnsureRange(Round(L * 255), 0, 255);
        b := EnsureRange(Round(L * 255), 0, 255);
      end
      else
      begin
        if L < 0.5 then q := L * (1.0 + S) else q := L + S - L * S;
        p := 2.0 * L - q;
        r := EnsureRange(Round(HueToRGB(p, q, H + 1/3) * 255), 0, 255);
        g := EnsureRange(Round(HueToRGB(p, q, H) * 255), 0, 255);
        b := EnsureRange(Round(HueToRGB(p, q, H - 1/3) * 255), 0, 255);
      end;

      Image2.Picture.Bitmap.Canvas.Pixels[i, j] := RGBToColor(r, g, b);
    end;
  end;
  Image2.Invalidate;
  ShowMessage('Luminância (L) do HLS equalizada mantendo matiz original!');
end;

// === AULA 9: BINARIZAÇÃO AUTOMÁTICA POR OTSU ===
procedure TForm1.MenuItem17Click(Sender: TObject);
var
  i, j, t, limiarOtsu: Integer;
  hist: array[0..255] of Integer;
  wB, wF, somaB, somaF, mB, mF, variancia, maxVariancia: Double;
  totalPixels: Integer;
begin
  if (ImgWidth = 0) then Exit;
  totalPixels := ImgWidth * ImgHeight;
  for t := 0 to 255 do hist[t] := 0;
  for i := 0 to ImgWidth - 1 do
    for j := 0 to ImgHeight - 1 do Inc(hist[ImE[i, j]]);

  somaF := 0;
  for t := 0 to 255 do somaF := somaF + t * hist[t];

  wB := 0; somaB := 0; maxVariancia := -1; limiarOtsu := 128;

  for t := 0 to 255 do
  begin
    wB := wB + hist[t];
    if wB = 0 then Continue;
    wF := totalPixels - wB;
    if wF = 0 then Break;

    somaB := somaB + t * hist[t];
    mB := somaB / wB;
    mF := (somaF - somaB) / wF;

    variancia := wB * wF * (mB - mF) * (mB - mF);
    if variancia > maxVariancia then
    begin
      maxVariancia := variancia;
      limiarOtsu := t;
    end;
  end;

  for i := 0 to ImgWidth - 1 do
    for j := 0 to ImgHeight - 1 do
    begin
      if ImE[i, j] >= limiarOtsu then ImS[i, j] := 255 else ImS[i, j] := 0;
      Image2.Picture.Bitmap.Canvas.Pixels[i, j] := RGBToColor(ImS[i, j], ImS[i, j], ImS[i, j]);
    end;
  Image2.Invalidate;
  EditMagnitude.Text := IntToStr(limiarOtsu);
  ShowMessage('OTSU calculou o limiar ideal em: ' + IntToStr(limiarOtsu));
end;

// === AULA 9: LIMIARIZAÇÃO MANUAL ===
procedure TForm1.MenuItem18Click(Sender: TObject);
var
  i, j, limiar: Integer;
begin
  if (ImgWidth = 0) then begin ShowMessage('Abra uma imagem primeiro!'); Exit; end;

  try
    limiar := StrToInt(EditMagnitude.Text);
  except
    limiar := 128;
    EditMagnitude.Text := '128';
  end;

  for i := 0 to ImgWidth - 1 do
    for j := 0 to ImgHeight - 1 do
    begin
      if ImE[i, j] >= limiar then
        ImS[i, j] := 255
      else
        ImS[i, j] := 0;

      Image2.Picture.Bitmap.Canvas.Pixels[i, j] := RGBToColor(ImS[i, j], ImS[i, j], ImS[i, j]);
    end;

  Image2.Invalidate;
  ShowMessage('Limiarização manual aplicada com corte em: ' + IntToStr(limiar));
end;

// === AULA 12: EROSÃO MORFOLÓGICA ===
procedure TForm1.MenuItem20Click(Sender: TObject);
var
  i, j, x, y: Integer;
  ajuste: Boolean;
begin
  if (ImgWidth = 0) then Exit;
  for i := 1 to ImgWidth - 2 do
    for j := 1 to ImgHeight - 2 do
    begin
      ajuste := True;
      for x := -1 to 1 do
        for y := -1 to 1 do
          if ImE[i+x, j+y] < 128 then ajuste := False;

      if ajuste then ImS[i, j] := 255 else ImS[i, j] := 0;
    end;

  for i := 0 to ImgWidth - 1 do
    for j := 0 to ImgHeight - 1 do
      Image2.Picture.Bitmap.Canvas.Pixels[i, j] := RGBToColor(ImS[i, j], ImS[i, j], ImS[i, j]);
  Image2.Invalidate;
  ShowMessage('Erosão concluída.');
end;

// === AULA 12: DILATAÇÃO MORFOLÓGICA ===
procedure TForm1.MenuItem21Click(Sender: TObject);
var
  i, j, x, y: Integer;
  hit: Boolean;
begin
  if (ImgWidth = 0) then Exit;
  for i := 1 to ImgWidth - 2 do
    for j := 1 to ImgHeight - 2 do
    begin
      hit := False;
      for x := -1 to 1 do
        for y := -1 to 1 do
          if ImE[i+x, j+y] >= 128 then hit := True;

      if hit then ImS[i, j] := 255 else ImS[i, j] := 0;
    end;

  for i := 0 to ImgWidth - 1 do
    for j := 0 to ImgHeight - 1 do
      Image2.Picture.Bitmap.Canvas.Pixels[i, j] := RGBToColor(ImS[i, j], ImS[i, j], ImS[i, j]);
  Image2.Invalidate;
  ShowMessage('Dilatação concluída.');
end;

// === MENU: FILTRO MÍNIMO ===
procedure TForm1.MenuItem2Click(Sender: TObject);
var
  i, j, vizinhoX, vizinhoY, k, aux: Integer;
  valoresVizinhos: array[0..8] of Integer;
begin
  if (ImgWidth = 0) or (ImgHeight = 0) then begin ShowMessage('Abra uma imagem primeiro!'); Exit; end;

  for i := 1 to ImgWidth - 2 do
    for j := 1 to ImgHeight - 2 do
    begin
      k := 0;
      for vizinhoX := -1 to 1 do
        for vizinhoY := -1 to 1 do
        begin
          valoresVizinhos[k] := ImE[i + vizinhoX, j + vizinhoY];
          Inc(k);
        end;

      for k := 0 to 7 do
        for aux := k + 1 to 8 do
          if valoresVizinhos[k] > valoresVizinhos[aux] then swap(valoresVizinhos[k], valoresVizinhos[aux]);

      ImS[i, j] := valoresVizinhos[0];
    end;

  for i := 0 to ImgWidth - 1 do
    for j := 0 to ImgHeight - 1 do
    begin
      if (i = 0) or (i = ImgWidth - 1) or (j = 0) or (j = ImgHeight - 1) then ImS[i, j] := ImE[i, j];
      Image2.Picture.Bitmap.Canvas.Pixels[i, j] := RGBToColor(ImS[i, j], ImS[i, j], ImS[i, j]);
    end;
  Image2.Invalidate;
  ShowMessage('Filtro Mínimo aplicado!');
end;

// === MENU: FILTRO MÁXIMO ===
procedure TForm1.MenuItem3Click(Sender: TObject);
var
  i, j, vizinhoX, vizinhoY, k, aux: Integer;
  valoresVizinhos: array[0..8] of Integer;
begin
  if (ImgWidth = 0) or (ImgHeight = 0) then begin ShowMessage('Abra uma imagem primeiro!'); Exit; end;

  for i := 1 to ImgWidth - 2 do
    for j := 1 to ImgHeight - 2 do
    begin
      k := 0;
      for vizinhoX := -1 to 1 do
        for vizinhoY := -1 to 1 do
        begin
          valoresVizinhos[k] := ImE[i + vizinhoX, j + vizinhoY];
          Inc(k);
        end;

      for k := 0 to 7 do
        for aux := k + 1 to 8 do
          if valoresVizinhos[k] > valoresVizinhos[aux] then swap(valoresVizinhos[k], valoresVizinhos[aux]);

      ImS[i, j] := valoresVizinhos[8];
    end;

  for i := 0 to ImgWidth - 1 do
    for j := 0 to ImgHeight - 1 do
    begin
      if (i = 0) or (i = ImgWidth - 1) or (j = 0) or (j = ImgHeight - 1) then ImS[i, j] := ImE[i, j];
      Image2.Picture.Bitmap.Canvas.Pixels[i, j] := RGBToColor(ImS[i, j], ImS[i, j], ImS[i, j]);
    end;
  Image2.Invalidate;
  ShowMessage('Filtro Máximo aplicado!');
end;

// === MENU: FILTRO PONTO MÉDIO ===
procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  Button1Click(Sender);
end;

// === AULA 7: CÁLCULO DA DCT DIRETA (GRAVA NA MATRIZ C) ===
procedure TForm1.MenuItem7Click(Sender: TObject);
var
  x, y, u, v: Integer;
  soma, alphaU, alphaV, maxC: Double;
  corInt: Byte;
begin
  if (ImgWidth <> 128) or (ImgHeight <> 128) then
  begin
    ShowMessage('Utilize uma imagem 128x128.');
    Exit;
  end;

  for u := 0 to 127 do
  begin
    if u = 0 then alphaU := Sqrt(1.0 / 128.0) else alphaU := Sqrt(2.0 / 128.0);
    for v := 0 to 127 do
    begin
      if v = 0 then alphaV := Sqrt(1.0 / 128.0) else alphaV := Sqrt(2.0 / 128.0);
      soma := 0.0;

      for x := 0 to 127 do
        for y := 0 to 127 do
        begin
          if (x < ImgWidth) and (y < ImgHeight) then
            corInt := ImE[x, y]
          else
            corInt := 0;

          soma := soma + corInt * Cos(((2*x + 1) * u * Pi) / 256.0) * Cos(((2*y + 1) * v * Pi) / 256.0);
        end;
      C[u, v] := alphaU * alphaV * soma;
    end;
  end;

  maxC := -1.0;
  for u := 0 to 127 do
    for v := 0 to 127 do
      if Abs(C[u, v]) > maxC then maxC := Abs(C[u, v]);
  if maxC = 0 then maxC := 1;

  for u := 0 to 127 do
    for v := 0 to 127 do
    begin
      corInt := Round(255 * (Ln(1 + Abs(C[u, v])) / Ln(1 + maxC)));
      Image2.Picture.Bitmap.Canvas.Pixels[u, v] := RGBToColor(corInt, corInt, corInt);
    end;

  Image2.Invalidate;
  ShowMessage('DCT calculada com sucesso! Coeficientes gravados na matriz C[128][128].');
end;

// === AULA 7: CÁLCULO DA IDCT INVERSA (GRAVA NA MATRIZ f) ===
procedure TForm1.MenuItem8Click(Sender: TObject);
var
  x, y, u, v: Integer;
  soma, alphaU, alphaV: Double;
  corFinal: Integer;
begin
  if (ImgWidth <> 128) or (ImgHeight <> 128) then
  begin
    ShowMessage('Utilize uma imagem 128x128.');
    Exit;
  end;

  for x := 0 to 127 do
    for y := 0 to 127 do
    begin
      soma := 0.0;
      for u := 0 to 127 do
      begin
        if u = 0 then alphaU := Sqrt(1.0 / 128.0) else alphaU := Sqrt(2.0 / 128.0);
        for v := 0 to 127 do
        begin
          if v = 0 then alphaV := Sqrt(1.0 / 128.0) else alphaV := Sqrt(2.0 / 128.0);

          soma := soma + alphaU * alphaV * C[u, v] * Cos(((2*x + 1) * u * Pi) / 256.0) * Cos(((2*y + 1) * v * Pi) / 256.0);
        end;
      end;

      corFinal := Round(soma);
      if corFinal < 0 then corFinal := 0;
      if corFinal > 255 then corFinal := 255;

      f[x, y] := corFinal;

      Image2.Picture.Bitmap.Canvas.Pixels[x, y] := RGBToColor(f[x, y], f[x, y], f[x, y]);
    end;

  Image2.Invalidate;
  ShowMessage('IDCT concluída! Resultado gravado na matriz f[128][128].');
end;

// === MENU: SALVAR ===
procedure TForm1.MenuSalvarClick(Sender: TObject);
begin
  SaveDialog1.DefaultExt := 'bmp';
  if SaveDialog1.Execute then
  begin
    Image2.Picture.SaveToFile(SaveDialog1.FileName);
    ShowMessage('Imagem salva com sucesso!');
  end;
end;

// === MENU: ABRIR ===
procedure TForm1.MenuAbrirClick(Sender: TObject);
var
  i, j: Integer;
  corLocal: TColor;
  ImgAux: TPicture;
begin
  if OpenDialog1.Execute then
  begin
    ImgAux := TPicture.Create;
    try
      ImgAux.LoadFromFile(OpenDialog1.FileName);
      ImgWidth := ImgAux.Width;
      ImgHeight := ImgAux.Height;

      if (ImgWidth > 4000) or (ImgHeight > 4000) then
      begin
        ShowMessage('Imagem grande demais! Escolha uma imagem de até 4000x4000.');
        Exit;
      end;

      Image1.Picture.Bitmap.SetSize(ImgWidth, ImgHeight);
      Image2.Picture.Bitmap.SetSize(ImgWidth, ImgHeight);
      Image1.Picture.Bitmap.Canvas.Draw(0, 0, ImgAux.Graphic);

      for i := 0 to ImgWidth - 1 do
      begin
        for j := 0 to ImgHeight - 1 do
        begin
          corLocal := Image1.Picture.Bitmap.Canvas.Pixels[i, j];
          ImE[i, j] := (Red(corLocal) + Green(corLocal) + Blue(corLocal)) div 3;
        end;
      end;

      Image1.Invalidate;
      ShowMessage('Imagem carregada com sucesso! Tamanho: ' + IntToStr(ImgWidth) + 'x' + IntToStr(ImgHeight));

    finally
      ImgAux.Free;
    end;
  end;
end;

end.
