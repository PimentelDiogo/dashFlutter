import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import '../models/ticket_model.dart';

class ExcelService {
  // Load and process Excel file
  Future<Map<String, dynamic>> loadExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null) {
      return {
        'success': false,
        'message': 'Nenhum arquivo selecionado',
        'data': null
      };
    }

    try {
      File file = File(result.files.single.path!);
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      // Process Excel data
      var sheet = excel.tables.keys.first;
      var rows = excel.tables[sheet]?.rows;

      if (rows == null || rows.isEmpty) {
        return {
          'success': false,
          'message': 'Arquivo vazio ou inválido',
          'data': null
        };
      }

      // Get headers
      var headers = rows[0].map((cell) => cell?.value.toString() ?? "").toList();

      // Check required columns
      List<String> requiredColumns = ["Analista Atual", "Cliente Solicitante", "Estado", "Última Fila"];
      List<String> missingColumns = [];

      for (var col in requiredColumns) {
        if (!headers.contains(col)) {
          missingColumns.add(col);
        }
      }

      if (missingColumns.isNotEmpty) {
        return {
          'success': false,
          'message': 'Colunas faltando: ${missingColumns.join(", ")}',
          'data': null
        };
      }

      // Process data rows
      List<TicketModel> tickets = [];
      for (int i = 1; i < rows.length; i++) {
        Map<String, dynamic> rowData = {};
        for (int j = 0; j < headers.length; j++) {
          if (j < rows[i].length) {
            rowData[headers[j]] = rows[i][j]?.value.toString() ?? "";
          }
        }
        tickets.add(TicketModel.fromMap(rowData));
      }

      return {
        'success': true,
        'message': 'Arquivo carregado com sucesso',
        'data': tickets
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao processar arquivo: $e',
        'data': null
      };
    }
  }

  // Calculate metrics from ticket data
  Map<String, dynamic> calculateMetrics(List<TicketModel> tickets) {
    int totalTickets = tickets.length;
    
    // Count by Analista
    Map<String, int> analistaCount = {};
    for (var ticket in tickets) {
      analistaCount[ticket.analistaAtual] = (analistaCount[ticket.analistaAtual] ?? 0) + 1;
    }

    // Count by Cliente
    Map<String, int> clienteCount = {};
    for (var ticket in tickets) {
      clienteCount[ticket.clienteSolicitante] = (clienteCount[ticket.clienteSolicitante] ?? 0) + 1;
    }

    // Count by Estado
    Map<String, int> estadoCount = {};
    for (var ticket in tickets) {
      estadoCount[ticket.estado] = (estadoCount[ticket.estado] ?? 0) + 1;
    }

    // Count by Fila
    Map<String, int> filaCount = {};
    for (var ticket in tickets) {
      filaCount[ticket.ultimaFila] = (filaCount[ticket.ultimaFila] ?? 0) + 1;
    }

    return {
      'totalTickets': totalTickets,
      'analistaCount': analistaCount,
      'clienteCount': clienteCount,
      'estadoCount': estadoCount,
      'filaCount': filaCount,
    };
  }
}