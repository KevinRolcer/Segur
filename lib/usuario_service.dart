import 'dart:convert';
import 'package:http/http.dart' as http;
import 'usuario.dart';

class UsuarioService {
  final String baseUrl = "https://kevinrolcer.com/api";

  Future<List<Usuario>> obtenerUsuarios() async {
    final response = await http.post(
      Uri.parse("$baseUrl/usuarios.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"tipo": "obtener"}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        List<dynamic> lista = data['datos'];
        return lista.map((e) => Usuario.fromJson(e)).toList();
      } else {
        throw Exception(data['mensaje']);
      }
    } else {
      throw Exception("Error al cargar usuarios");
    }
  }

  Future<bool> actualizarUsuario(int id, String nombre, String telefono) async {
    final response = await http.post(
      Uri.parse("$baseUrl/usuarios.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "tipo": "editar",
        "id": id,
        "nombre": nombre,
        "telefono": telefono,
      }),
    );

    final data = jsonDecode(response.body);
    return data['success'];
  }
}
