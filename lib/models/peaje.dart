class Peaje {
  final int id;
  final String placa;
  final String nombrePeaje;
  final String idCategoriaTarifa;
  final DateTime fecha;
  final int valor;

  Peaje({
    required this.id,
    required this.placa,
    required this.nombrePeaje,
    required this.idCategoriaTarifa,
    required this.fecha,
    required this.valor,
  });

  factory Peaje.fromJson(Map<String, dynamic> json) {
    return Peaje(
      id: json['id'],
      placa: json['placa'],
      nombrePeaje: json['nombrePeaje'],
      idCategoriaTarifa: json['idCategoriaTarifa'],
      fecha: DateTime.parse(json['fecha']),
      valor: json['valor'],
    );
  }
}
