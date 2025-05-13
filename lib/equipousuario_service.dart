import 'dart:convert';
import 'package:http/http.dart' as http;
import 'equipoUsuarioD.dart'; // Asumiendo que el modelo de EquipoUsuario está en equipoUsuarioD.dart

class EquipoUsuarioService {
  final String baseUrl = "https://kevinrolcer.com/api";

  // Obtener todas las relaciones de equipos y usuarios
  Future<List<EquipoUsuario>> obtenerEquiposUsuarios() async {
    final response = await http.post(
      Uri.parse("$baseUrl/equipou.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"tipo": "obtener"}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        List<dynamic> lista = data['datos']; // Asegúrate de que el nombre coincida con el JSON recibido
        return lista.map((e) => EquipoUsuario.fromJson(e)).toList();
      } else {
        throw Exception(data['mensaje']);
      }
    } else {
      throw Exception("Error al cargar relaciones equipo-usuario");
    }
  }

  // Crear una nueva relación entre un equipo y un usuario
  Future<bool> crearEquipoUsuario(int equipoId, int usuarioId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/equipou.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"tipo": "crear", "equipo_id": equipoId, "usuario_id": usuarioId}),
    );

    final data = jsonDecode(response.body);
    return data['success'];
  }

  // Editar una relación entre un equipo y un usuario
  Future<bool> editarEquipoUsuario(int id, int equipoId, int usuarioId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/equipou.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"tipo": "editar", "id": id, "equipo_id": equipoId, "usuario_id": usuarioId}),
    );

    final data = jsonDecode(response.body);
    return data['success'];
  }

  // Eliminar una relación entre un equipo y un usuario
  Future<bool> eliminarEquipoUsuario(int id) async {
    final response = await http.post(
      Uri.parse("$baseUrl/equipou.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"tipo": "eliminar", "id": id}),
    );

    final data = jsonDecode(response.body);
    return data['success'];
  }
}
