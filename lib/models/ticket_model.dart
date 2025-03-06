class TicketModel {
  final String analistaAtual;
  final String clienteSolicitante;
  final String estado;
  final String ultimaFila;

  TicketModel({
    required this.analistaAtual,
    required this.clienteSolicitante,
    required this.estado,
    required this.ultimaFila,
  });

  factory TicketModel.fromMap(Map<String, dynamic> map) {
    return TicketModel(
      analistaAtual: map['Analista Atual'] ?? '',
      clienteSolicitante: map['Cliente Solicitante'] ?? '',
      estado: map['Estado'] ?? '',
      ultimaFila: map['Última Fila'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Analista Atual': analistaAtual,
      'Cliente Solicitante': clienteSolicitante,
      'Estado': estado,
      'Última Fila': ultimaFila,
    };
  }
}