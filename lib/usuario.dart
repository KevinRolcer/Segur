class Usuario {
  final String nombre;
  final String telefono;

  Usuario({required this.nombre, required this.telefono});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      nombre: json['nombre'],
      telefono: json['telefono'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'telefono': telefono,
    };
  }
}
