class Equipo {
  final int id;
  final String nombreEquipo;
  final List<Usuario> integrantes;

  Equipo({
    required this.id,
    required this.nombreEquipo,
    required this.integrantes,
  });

  factory Equipo.fromJson(Map<String, dynamic> json) {
    List<Usuario> integrantes = [];

    if (json.containsKey('nombreUsuario') && json.containsKey('telefono')) {
      integrantes.add(Usuario(
        nombre: json['nombreUsuario'],
        telefono: json['telefono'],
      ));
    }

    return Equipo(
      id: json['id'],
      nombreEquipo: json['nombreEquipo'],
      integrantes: integrantes,
    );
  }
}