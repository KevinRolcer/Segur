import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cequipo.dart';

class CEquipoService {
  final String baseUrl = "https://kevinrolcer.com/api";

  Future<List<CEquipo>> obtenerEquipos() async {
    final response = await http.post(
      Uri.parse("$baseUrl/equipo.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"tipo": "obtener"}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        List<dynamic> lista = data['equipos'];
        return lista.map((e) => CEquipo.fromJson(e)).toList();
      } else {
        throw Exception(data['mensaje']);
      }
    } else {
      throw Exception("Error al cargar equipos");
    }
  }
}
