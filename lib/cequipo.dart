import 'usuario.dart';  // Asegúrate de tener la clase Usuario importada si la usas

class CEquipo {
  final int id;
  final String nombreEquipo;
  final List<Usuario> integrantes;

  CEquipo({
    required this.id,
    required this.nombreEquipo,
    required this.integrantes,
  });

  factory CEquipo.fromJson(Map<String, dynamic> json) {
    List<Usuario> integrantes = [];

    if (json.containsKey('integrantes')) {
      List<dynamic> integrantesData = json['integrantes'];
      for (var integrante in integrantesData) {
        integrantes.add(Usuario.fromJson(integrante));
      }
    }

    return CEquipo(
      id: json['id'],
      nombreEquipo: json['nombreEquipo'],
      integrantes: integrantes,
    );
  }
}
