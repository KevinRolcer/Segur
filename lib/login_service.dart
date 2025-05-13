import 'package:http/http.dart' as http;
import 'dart:convert';

class BuscarUsuarioService {
  final String baseUrl = "https://kevinrolcer.com/api";

  Future<Map<String, dynamic>> buscarUsuario(String telefono) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/telefono.php"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "telefono": telefono,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "mensaje": "Error del servidor: ${response.statusCode}"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "mensaje": "Error de conexión: ${e.toString()}"
      };
    }
  }
}
