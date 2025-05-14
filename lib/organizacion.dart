class Organizacion {
  final int idEvaluacion;
  final String fechaEvaluacion;
  final String nombre;
  final int id;

  Organizacion({
    required this.idEvaluacion,
    required this.fechaEvaluacion,
    required this.nombre,
    required this.id,
  });

  factory Organizacion.fromJson(Map<String, dynamic> json) {
    return Organizacion(
      idEvaluacion: int.parse(json['idEvaluacion'].toString()),
      fechaEvaluacion: json['fecha_evaluacion'],
      nombre: json['nombre'],
      id: int.parse(json['organizacion_id'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idEvaluacion': idEvaluacion,
      'fecha_evaluacion': fechaEvaluacion,
      'nombre': nombre,
      'id': id,
    };
  }
}
