import 'dart:convert';
import 'package:http/http.dart' as http;
import 'organizacion.dart';

class OrganizacionService {
  final String baseUrl = "https://kevinrolcer.com/api/organizacion.php";

  Future<List<Organizacion>> obtenerOrganizaciones() async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"tipo": "obtener"}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        List<dynamic> lista = data['datos'];
        return lista.map((e) => Organizacion.fromJson(e)).toList();
      } else {
        throw Exception(data['mensaje']);
      }
    } else {
      throw Exception("Error al conectar con la API");
    }
  }
}
