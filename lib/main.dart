import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'viewmodels/dashboard_viewmodel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Suporte WorkSpaceMobile',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: DashboardScreen(),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DashboardViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<DashboardViewModel>(context, listen: false);
    viewModel.initVoiceService();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFE5E5E5),
          appBar: AppBar(
            title: const Text('Dashboard'),
            actions: [
              if (viewModel.fileLoaded) ...[                
                IconButton(
                  icon: Icon(viewModel.isListening ? Icons.mic : Icons.mic_none),
                  onPressed: () async {
                    if (viewModel.isListening) {
                      await viewModel.stopVoiceSearch();
                    } else {
                      await viewModel.startVoiceSearch();
                    }
                  },
                  tooltip: 'Busca por voz',
                ),
                if (viewModel.searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => viewModel.clearSearch(),
                    tooltip: 'Limpar busca',
                  ),
              ],
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: viewModel.loadExcelFile,
                    child: const Text('Carregue um arquivo XLSX',
                    style: TextStyle(color: Color.fromARGB(255, 6, 176, 97)),),
                  ),
                  if (viewModel.searchQuery.isNotEmpty) ...[
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: Text(
              'Resultados da busca: "${viewModel.searchQuery}"',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          if (viewModel.filteredTickets.length > 1) ...[
            IconButton(
              icon: const Icon(Icons.arrow_upward),
              onPressed: () => viewModel.previousSearchResult(),
              tooltip: 'Resultado anterior',
            ),
            Text('${viewModel.selectedResultIndex + 1}/${viewModel.filteredTickets.length}'),
            IconButton(
              icon: const Icon(Icons.arrow_downward),
              onPressed: () => viewModel.nextSearchResult(),
              tooltip: 'Próximo resultado',
                          ),
                         
                        ],
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (viewModel.fileLoaded) ...[  
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total de Tickets', style: TextStyle(fontSize: 16)),
                            Text('${viewModel.totalTickets}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    const Text('Quantidade de Tickets em Atendimento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Container(
                      alignment: Alignment.topLeft,
                      height: MediaQuery.of(context).size.height * 0.9,
                      child: BarChartWidget(data: viewModel.analistaCount, title: 'Tickets por Analista Atual'),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    const Text('Quantidade de Tickets por Cliente Solicitante',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          alignment: Alignment.topLeft,
                          width: MediaQuery.of(context).size.width * 1,
                          height: MediaQuery.of(context).size.height * 0.9,
                          child: BarChartWidget(data: viewModel.clienteCount, title: 'Tickets por Cliente'),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    const Text('Quantidade de Tickets por Estado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: PieChartWidget(data: viewModel.estadoCount, title: 'Distribuição de Tickets por Estado'),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    const Text('Quantidade de Tickets por Fila', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: BarChartWidget(data: viewModel.filaCount, title: 'Distribuição de Tickets por Fila'),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    const Text('Resumo dos Dados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.55,
                      child: SingleChildScrollView(
                        controller: viewModel.scrollController,
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 1,
                            dividerThickness: 1,
                            horizontalMargin: 1,
                            columns: const[
                               DataColumn(label: Text('Analista Atual')),
                               DataColumn(label: Text('Cliente Solicitante')),
                               DataColumn(label: Text('Estado')),
                               DataColumn(label: Text('Última Fila')),
                            ],
                            rows: viewModel.tickets.asMap().entries.map((entry) {
                              final index = entry.key;
                              final ticket = entry.value;
                              final isFiltered = viewModel.searchQuery.isNotEmpty;
                              final isSelected = isFiltered && viewModel.tickets[index] == viewModel.tickets[viewModel.selectedResultIndex];
                              return DataRow(
                                selected: isSelected,
                                color: MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                    if (states.contains(MaterialState.selected)) {
                                      return Colors.blue.withOpacity(0.2);
                                    }
                                    return null;
                                  },
                                ),
                                cells: [
                                  DataCell(Text(viewModel.truncateText(ticket.analistaAtual, 20))),
                                  DataCell(Text(viewModel.truncateText(ticket.clienteSolicitante, 36))),
                                  DataCell(Text(ticket.estado)),
                                  DataCell(Text(ticket.ultimaFila)),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Widget for bar charts
class BarChartWidget extends StatelessWidget {
  final Map<String, int> data;
  final String title;

  BarChartWidget({required this.data, required this.title});

  @override
  Widget build(BuildContext context) {
    final dataList = data.entries.toList();
    final viewModel = Provider.of<DashboardViewModel>(context, listen: false);
    
    // Preparar os dados para o SyncFusion Chart
    List<ChartData> chartData = dataList.map((entry) => 
      ChartData(entry.key, entry.value.toDouble())
    ).toList();
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                if (viewModel.isDescribingChart(title)) ...[
                  IconButton(
                    onPressed: () async {
                      await viewModel.stopDescription(title);
                    },
                    icon: const Icon(Icons.square_rounded),
                  ),
                ] else ...[
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    onPressed: () => viewModel.describeChartData(title, data),
                    tooltip: 'Descrição por áudio',
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),
            Expanded(
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                  labelRotation: 0,
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  maximumLabels: 100,
                  axisLabelFormatter: (AxisLabelRenderDetails details) {
                    String label = details.text;
                    String displayText = label.length > 20 ? '${label.substring(0, 18)}...' : label;
                    return ChartAxisLabel(displayText, details.textStyle);
                  },
                ),
                primaryYAxis: NumericAxis(
                  majorGridLines: const MajorGridLines(width: 0.5, dashArray: <double>[5, 5]),
                  axisLine: const AxisLine(width: 1),
                  title: AxisTitle(text: 'Quantidade', textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
                series: <ChartSeries>[
                  BarSeries<ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    name: 'Tickets',
                    color: Colors.blue.shade800,
                    width: 0.8,
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.outer,
                      textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    enableTooltip: true,
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade800],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Classe para dados do gráfico
class ChartData {
  final String x;
  final double y;
  
  ChartData(this.x, this.y);
}

// Widget for pie charts
class PieChartWidget extends StatelessWidget {
  final Map<String, int> data;
  final String title;

  PieChartWidget({required this.data, required this.title});

  @override
  Widget build(BuildContext context) {
    final dataList = data.entries.toList();
    final total = dataList.fold(0, (sum, item) => sum + item.value);
    final viewModel = Provider.of<DashboardViewModel>(context, listen: false);
    
    // Preparar os dados para o SyncFusion Chart
    List<PieChartData> chartData = dataList.asMap().entries.map((entry) {
      final value = entry.value.value.toDouble();
      final percentage = (value / total * 100).toStringAsFixed(1);
      return PieChartData(
        entry.value.key,
        value,
        '${entry.value.key}: $percentage%',
        Colors.primaries[entry.key % Colors.primaries.length],
      );
    }).cast<PieChartData>().toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                if (viewModel.isDescribingChart(title)) ...[
                  IconButton(
                    onPressed: () async {
                      await viewModel.stopDescription(title);
                    },
                    icon: const Icon(Icons.square_rounded),
                  ),
                ] else ...[
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    onPressed: () => viewModel.describeChartData(title, data),
                    tooltip: 'Descrição por áudio',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: 5,
              child: SfCircularChart(
                margin: EdgeInsets.zero,
                series: <CircularSeries>[
                  PieSeries<PieChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (PieChartData data, _) => data.x,
                    yValueMapper: (PieChartData data, _) => data.y,
                    pointColorMapper: (PieChartData data, _) => data.color,
                    dataLabelMapper: (PieChartData data, _) => data.label,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      connectorLineSettings: ConnectorLineSettings(
                        type: ConnectorType.line,
                        length: '15%',
                      ),
                    ),
                    enableTooltip: true,
                    radius: '80%',
                    explode: true,
                    explodeAll: true,
                    explodeOffset: '10%',
                    explodeGesture: ActivationMode.singleTap,
                  ),
                ],
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  format: 'point.x: point.y',
                  textStyle: const TextStyle(color: Colors.white, fontSize: 14),
                  color: Colors.blueGrey.withOpacity(0.9),
                ),
                legend:  const Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.wrap,
                  itemPadding: 12,
                  textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Expandindo a classe ChartData para incluir informações adicionais para o gráfico de pizza
class PieChartData {
  final String x;
  final double y;
  final String? label;
  final Color? color;

  PieChartData(this.x, this.y, [this.label, this.color]);
}
