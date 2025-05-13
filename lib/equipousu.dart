class EquipoUsuario {
  final int id;
  final int equipoId;
  final int usuarioId;
  final String nombreUsuario;
  final String telefono;

  EquipoUsuario({
    required this.id,
    required this.equipoId,
    required this.usuarioId,
    required this.nombreUsuario,
    required this.telefono,
  });

  // Crear un EquipoUsuario a partir de JSON
  factory EquipoUsuario.fromJson(Map<String, dynamic> json) {
    return EquipoUsuario(
      id: json['id'],
      equipoId: json['equipo_id'],
      usuarioId: json['usuario_id'],
      nombreUsuario: json['nombreUsuario'],
      telefono: json['telefono'],
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'equipo_id': equipoId,
      'usuario_id': usuarioId,
      'nombreUsuario': nombreUsuario,
      'telefono': telefono,
    };
  }
}
