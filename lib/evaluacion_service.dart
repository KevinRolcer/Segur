import 'dart:convert';
import 'package:http/http.dart' as http;
import 'evaluacion.dart';

class EvaluacionService {
  final String baseUrl = "https://kevinrolcer.com/api";

  Future<List<Evaluacion>> obtenerEvaluaciones(String tipo) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/eventos.php"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "tipo": tipo,
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        if (data['success']) {
          List<dynamic> evaluacionesData = data['evaluaciones'];
          return evaluacionesData.map((e) => Evaluacion.fromJson(e)).toList();
        } else {
          throw Exception(data['mensaje'] ?? 'Error desconocido');
        }
      } else {
        throw Exception('Error en la conexión o en la API');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}