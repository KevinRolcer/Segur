import 'dart:convert';
import 'package:http/http.dart' as http;

class Nom {
  final int idNom;
  final String regulacion;
  final String descripcion;
  final String area;

  Nom({
    required this.idNom,
    required this.regulacion,
    required this.descripcion,
    required this.area,
  });

  factory Nom.fromJson(Map<String, dynamic> json) {
    return Nom(
      idNom: int.parse(json['idNom'].toString()),
      regulacion: json['regulacion'],
      descripcion: json['descripcion'],
      area: json['area'],
    );
  }
}

class NomService {
  final String baseUrl = "https://kevinrolcer.com/api";

  Future<List<Nom>> obtenerNoms() async {
    final response = await http.post(
      Uri.parse("$baseUrl/nom.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"tipo": "obtener"}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        List<dynamic> lista = data['datos'];
        return lista.map((e) => Nom.fromJson(e)).toList();
      } else {
        throw Exception(data['mensaje']);
      }
    } else {
      throw Exception("Error al cargar las NOMs");
    }
  }
}
