import 'package:flutter/material.dart';
import '../models/ticket_model.dart';
import '../services/excel_service.dart';
import '../services/voice_service.dart';

class DashboardViewModel extends ChangeNotifier {
  List<TicketModel> get filteredTickets => _filteredTickets;
  Map<String, bool> _isDescribingChart = {};
  
  final ExcelService _excelService = ExcelService();
  final VoiceService _voiceService = VoiceService();
  
  List<TicketModel> _tickets = [];
  int _totalTickets = 0;
  Map<String, int> _analistaCount = {};
  Map<String, int> _clienteCount = {};
  Map<String, int> _estadoCount = {};
  Map<String, int> _filaCount = {};
  bool _fileLoaded = false;
  String _errorMessage = '';
  bool _isLoading = false;
  bool _isListening = false;
  String _searchQuery = '';
  List<TicketModel> _filteredTickets = [];
  final ScrollController scrollController = ScrollController();
  int _selectedResultIndex = -1;

  // Getters
  List<TicketModel> get tickets => _searchQuery.isEmpty ? _tickets : _filteredTickets;
  int get selectedResultIndex => _selectedResultIndex;
  int get totalTickets => _totalTickets;
  Map<String, int> get analistaCount => _analistaCount;
  Map<String, int> get clienteCount => _clienteCount;
  Map<String, int> get estadoCount => _estadoCount;
  Map<String, int> get filaCount => _filaCount;
  bool get fileLoaded => _fileLoaded;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isListening => _isListening;
  String get searchQuery => _searchQuery;


  // Initialize voice service
  Future<void> initVoiceService() async {
    await _voiceService.initSpeech();
 
  }

  // Start voice search
  Future<void> startVoiceSearch() async {
    _isListening = true;
    notifyListeners();
    
    if (!_voiceService.isSpeechEnabled) {
      await initVoiceService();
    }
    
    await _voiceService.startListening((text) {
      _searchQuery = text;
      _filterTickets();
      _isListening = false;
      notifyListeners();
    });
  }

  bool isDescribingChart(String chartTitle) {
    return _isDescribingChart[chartTitle] ?? false;
  }

  // Stop voice search
  Future<void> stopVoiceSearch() async {
    await _voiceService.stopListening();
    _isListening = false;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _filterTickets();
    notifyListeners();
  }
  void clearSearch() {
    _searchQuery = '';
    _filteredTickets = [];
    notifyListeners();
  }

  void _filterTickets() {
    if (_searchQuery.isEmpty) {
      _filteredTickets = List.from(_tickets);
      _selectedResultIndex = -1;
      notifyListeners();
      return;
    }

    _filteredTickets = _tickets.where((ticket) {
      return ticket.analistaAtual.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             ticket.clienteSolicitante.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             ticket.estado.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             ticket.ultimaFila.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    if (_filteredTickets.isNotEmpty) {
      _selectedResultIndex = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedResult();
      });
    }
    notifyListeners();
  }

void _scrollToSelectedResult() {
  if (_selectedResultIndex < 0 || _selectedResultIndex >= _filteredTickets.length) return;

  final rowHeight = 56.0; 
  final selectedTicket = _filteredTickets[_selectedResultIndex];
  final mainListIndex = _tickets.indexOf(selectedTicket);

  if (mainListIndex >= 0) {
    final targetOffset = rowHeight * mainListIndex;

    Future.delayed(const Duration(milliseconds: 400), () { 
      if (scrollController.hasClients) {
        final jumpPosition = (targetOffset - 100).clamp(0, scrollController.position.maxScrollExtent);
        scrollController.jumpTo(jumpPosition.toDouble());

        Future.delayed(const Duration(milliseconds: 200), () {
          if (scrollController.hasClients) {
            scrollController.animateTo(
              targetOffset,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });
  }
}

  void nextSearchResult() {
    if (_filteredTickets.isNotEmpty) {
      _selectedResultIndex = (_selectedResultIndex + 1) % _filteredTickets.length;
      _scrollToSelectedResult();
      notifyListeners();
    }
  }

  void previousSearchResult() {
    if (_filteredTickets.isNotEmpty) {
      _selectedResultIndex = (_selectedResultIndex - 1 + _filteredTickets.length) % _filteredTickets.length;
      _scrollToSelectedResult();
      notifyListeners();
    }
  }


  // Text search
  void search(String query) {
    _searchQuery = query;
    _filterTickets();
    notifyListeners();
  }

  // Describe data using voice
  Future<void> describeDataWithVoice() async {
    if (!_fileLoaded) return;
    
    Map<String, dynamic> metrics = {
      'totalTickets': _totalTickets,
      'analistaCount': _analistaCount,
      'clienteCount': _clienteCount,
      'estadoCount': _estadoCount,
      'filaCount': _filaCount,
    };
    
    await _voiceService.describeTicketData(metrics);
  }

  // Load and process Excel file
  Future<void> loadExcelFile() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _excelService.loadExcelFile();
      
      if (result['success']) {
        _tickets = result['data'];
        _updateMetrics();
        _fileLoaded = true;
      } else {
        _errorMessage = result['message'];
        _fileLoaded = false;
      }
    } catch (e) {
      _errorMessage = 'Erro ao carregar arquivo: $e';
      _fileLoaded = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update metrics based on loaded data
  void _updateMetrics() {
    final metrics = _excelService.calculateMetrics(_tickets);
    _totalTickets = metrics['totalTickets'];
    _analistaCount = metrics['analistaCount'];
    _clienteCount = metrics['clienteCount'];
    _estadoCount = metrics['estadoCount'];
    _filaCount = metrics['filaCount'];
  }

  String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  Future<void> describeChartData(String chartTitle, Map<String, int> chartData) async {
    if (!_fileLoaded || _isDescribingChart[chartTitle] == true) return;

    // Marca o gráfico como sendo descrito
    _isDescribingChart[chartTitle] = true;
    notifyListeners();

    String description = 'Dados do gráfico $chartTitle: ';
    if (chartTitle.contains('Estado')) {
      final total = chartData.values.fold(0, (sum, count) => sum + count);
      for (var entry in chartData.entries) {
        final percentage = (entry.value / total * 100).toStringAsFixed(1);
        description += '${entry.key} representa $percentage% com ${entry.value} tickets. ';
      }
    } else {
      for (var entry in chartData.entries) {
        description += '${entry.key} tem ${entry.value} tickets. ';
      }
    }

    await _voiceService.speak(description);
  }

  // Método para interromper a descrição do gráfico
  Future<void> stopDescription(String chartTitle) async {
    await _voiceService.stopSpeaking();
    _isDescribingChart[chartTitle] = false;
    notifyListeners();
  }

  // Controle de áudio
  bool _isDescribing = false;

  bool get isDescribing => _isDescribing;

}