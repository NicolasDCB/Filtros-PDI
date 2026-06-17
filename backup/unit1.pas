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
          if valoresVizinhos[k] > valoresVizinhos[aux]
