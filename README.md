# Processamento Digital de Imagens (PDI)

Projeto desenvolvido em **Object Pascal (Free Pascal/Lazarus)** para a disciplina de **Processamento Digital de Imagens (PDI)**.

O sistema implementa algoritmos clássicos de processamento digital de imagens estudados durante o segundo bimestre da disciplina.

## Funcionalidades Implementadas

### Aula 7 – Transformada Discreta do Cosseno (DCT)

* Implementação da DCT bidimensional
* Implementação da IDCT (Transformada Inversa)
* Armazenamento dos coeficientes na matriz `C[128][128]`
* Reconstrução da imagem na matriz `f[128][128]`
* Exibição dos resultados na `Image2`
* Processamento restrito a imagens `128×128`

### Filtros no Domínio da Frequência

* Filtro Passa-Baixa
* Filtro Passa-Alta
* Frequência de corte definida pelo usuário
* Inserção de ruído no domínio da frequência
* Reconstrução da imagem através da IDCT

### Aula 8 – Filtros Espaciais

* Filtro do Mínimo
* Filtro do Máximo
* Filtro do Ponto Médio

### Aula 8.3 – Processamento Colorido

* Aplicação de pseudo-cores em imagens em escala de cinza
* Equalização de histograma utilizando o canal **L** do modelo **HSL**

### Aula 9 – Segmentação

* Limiarização manual
* Binarização automática por OTSU

### Aula 12 – Morfologia Matemática

* Erosão de imagens binárias
* Dilatação de imagens binárias

## Tecnologias Utilizadas

* Lazarus IDE
* Free Pascal Compiler (FPC)
* Object Pascal

Bibliotecas utilizadas:

* `Graphics`
* `Math`
* `Dialogs`
* `ExtCtrls`
* `FPReadPNG`
* `FPReadJPEG`

## Estrutura do Projeto

```text
.
├── Unit1.pas
├── Unit1.lfm
├── Projeto.lpi
├── Projeto.lpr
└── README.md
```

## Como Executar

1. Clone o repositório:

```bash
git clone https://github.com/SEU_USUARIO/NOME_DO_REPOSITORIO.git
```

2. Abra o projeto no Lazarus.

3. Compile utilizando:

```text
Run → Build
```

ou pressione:

```text
F9
```

4. Carregue uma imagem através do menu **Abrir**.

## Exemplos de Uso

* Aplicar DCT em imagens `128×128`;
* Filtrar frequências altas ou baixas;
* Inserir ruído no domínio da frequência;
* Reconstruir a imagem usando IDCT;
* Aplicar pseudo-cores;
* Equalizar imagens coloridas pelo modelo HSL;
* Realizar segmentação utilizando OTSU;
* Aplicar operações morfológicas em imagens binárias.

## Autor

Desenvolvido como trabalho prático da disciplina de **Processamento Digital de Imagens (PDI)**.
