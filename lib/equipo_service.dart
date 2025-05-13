import 'dart:convert';
import 'package:http/http.dart' as http;
import 'equipoD.dart';
import 'usuario.dart';

class EquipoService {
  final String baseUrl = "https://kevinrolcer.com/api";

  Future<List<Equipo>> obtenerEquipos() async {
    final response = await http.post(
      Uri.parse("$baseUrl/equipou.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"tipo": "obtener"}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        List<dynamic> lista = data['datos'];
        return lista.map((e) => Equipo.fromJson(e)).toList();
      } else {
        throw Exception(data['mensaje']);
      }
    } else {
      throw Exception("Error al cargar equipos");
    }
  }
}