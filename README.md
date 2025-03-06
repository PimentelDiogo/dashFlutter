# DashPy

DashPy is a Flutter application that provides a visual dashboard for analyzing ticket data from Excel files. The application features voice search capabilities, data visualization through charts, and audio descriptions of chart data.

  DashPy
DashPy é um aplicativo Flutter que fornece um painel visual para analisar dados de tickets a partir de arquivos Excel. O aplicativo possui funcionalidades de pesquisa por voz, visualização de dados através de gráficos e descrições em áudio dos dados dos gráficos.

## Features

- Excel file loading and parsing
- Interactive data visualization with charts:
  - Bar charts for analyst workload, client requests, and queue distribution
  - Pie charts for ticket status distribution
- Voice search functionality
- Audio descriptions of chart data
- Responsive design for various screen sizes

Funcionalidades
Carregamento e parsing de arquivos Excel
Visualização interativa de dados com gráficos:
Gráficos de barras para carga de trabalho do analista, solicitações de clientes e distribuição de filas
Gráficos de pizza para distribuição do status dos tickets
Funcionalidade de pesquisa por voz
Descrições em áudio dos dados dos gráficos
Design responsivo para diversos tamanhos de tela


## Architecture

The application follows the MVVM (Model-View-ViewModel) architecture pattern:

Arquitetura
O aplicativo segue o padrão de arquitetura MVVM (Model-View-ViewModel):


dashpy/
├── lib/
│   ├── main.dart                     # Entry point and UI components
│   ├── models/                       # Data models
│   │   └── ticket.dart               # Ticket data model
│   ├── viewmodels/                   # Business logic
│   │   └── dashboard_viewmodel.dart  # Main ViewModel for dashboard
│   ├── services/                     # External services
│   │   ├── excel_service.dart        # Excel file processing
│   │   └── voice_service.dart        # Voice recognition and TTS
│   └── widgets/                      # Reusable UI components
│       ├── bar_chart_widget.dart     # Bar chart visualization
│       └── pie_chart_widget.dart     # Pie chart visualization
├── assets/                           # Static assets
└── pubspec.yaml                      # Dependencies


## Excel File Processing

The application processes Excel (.xlsx) files to extract ticket data:
Processamento de Arquivos Excel
O aplicativo processa arquivos Excel (.xlsx) para extrair dados de tickets:

1. **File Selection**: Users select an Excel file using the `file_picker` package
2. **Data Parsing**: The `excel` package is used to read and parse the Excel file
3. **Data Mapping**: Excel rows are mapped to `Ticket` model objects
4. **Data Analysis**: The application processes the data to generate:
   - Total ticket count
   - Tickets per analyst
   - Tickets per client
   - Tickets by status
   - Tickets by queue

Seleção de Arquivo: O usuário seleciona um arquivo Excel usando o pacote file_picker
Parsing de Dados: O pacote excel é utilizado para ler e processar o arquivo Excel
Mapeamento de Dados: As linhas do Excel são mapeadas para objetos do modelo Ticket
Análise de Dados: O aplicativo processa os dados para gerar:
Contagem total de tickets
Tickets por analista
Tickets por cliente
Tickets por status
Tickets por fila


### Voice Search

The application implements voice search functionality:
- Users can activate voice search by tapping the microphone icon
- Speech is converted to text using speech recognition
- The search query is applied to filter the ticket data
- Users can navigate through search results

Pesquisa por Voz
O aplicativo implementa a funcionalidade de pesquisa por voz:
Os usuários podem ativar a pesquisa por voz tocando no ícone de microfone
A fala é convertida em texto usando o reconhecimento de fala
A consulta de pesquisa é aplicada para filtrar os dados dos tickets
Os usuários podem navegar pelos resultados da pesquisa


### Chart Audio Description

For accessibility and enhanced user experience, the application provides audio descriptions of chart data:
1. Users tap the speaker icon on any chart
2. The application generates a descriptive summary of the chart data
3. Text-to-speech converts this description to audio
4. Users can stop the audio description at any time

Descrição em Áudio dos Gráficos
Para acessibilidade e melhor experiência do usuário, o aplicativo oferece descrições em áudio dos dados dos gráficos:
Os usuários tocam no ícone de alto-falante em qualquer gráfico
O aplicativo gera um resumo descritivo dos dados do gráfico
A conversão de texto em fala transforma essa descrição em áudio
Os usuários podem parar a descrição em áudio a qualquer momento

## Dependencies

- `flutter`: UI framework
- `provider`: State management
- `file_picker`: File selection dialog
- `excel`: Excel file parsing
- `syncfusion_flutter_charts`: Data visualization
- `speech_to_text`: Voice recognition
- `flutter_tts`: Text-to-speech

## Getting Started

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get

   ## Requirements
- Flutter 3.24 or higher
- Dart 3.6 or higher
- Excel files with the following columns:
  - Analista Atual
  - Cliente Solicitante
  - Estado
  - Última Fila

