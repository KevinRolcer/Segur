class Evaluacion {
  final DateTime fechaEvaluacion;
  final String version;
  final String objetivo;
  final String nombreOrganizacion;
  final String nombreEquipo;

  Evaluacion({
    required this.fechaEvaluacion,
    required this.version,
    required this.objetivo,
    required this.nombreOrganizacion,
    required this.nombreEquipo,
  });

  factory Evaluacion.fromJson(Map<String, dynamic> json) {
    return Evaluacion(
      fechaEvaluacion: DateTime.parse(json['fecha_evaluacion']),
      version: json['version'],
      objetivo: json['objetivo'],
      nombreOrganizacion: json['nombreOrganizacion'],
      nombreEquipo: json['nombreEquipo'],
    );
  }
}