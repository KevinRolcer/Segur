import 'dart:convert';
import 'package:http/http.dart' as http;
import 'itemO.dart';
import 'respuesta_item.dart';

class RespuestaService {
  final String baseUrl = "https://kevinrolcer.com/api/item.php";

  // Obtener los ítems según el 'nomId'
  Future<List<Item>> obtenerItems(int nomId) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"tipo": "obtener_items", "nom_id": nomId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        List<dynamic> lista = data['items'];
        return lista.map((e) => Item.fromJson(e)).toList();
      } else {
        throw Exception(data['mensaje']);
      }
    } else {
      throw Exception("Error al obtener los ítems");
    }
  }

  // Obtener las respuestas basadas en 'evaluacionId'
  Future<List<RespuestaItem>> obtenerRespuestas(int evaluacionId) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"tipo": "obtener_respuestas", "evaluacion_id": evaluacionId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        List<dynamic> lista = data['respuestas'];
        return lista.map((e) => RespuestaItem.fromJson(e)).toList();
      } else {
        throw Exception(data['mensaje']);
      }
    } else {
      throw Exception("Error al obtener respuestas");
    }
  }

  // Crear una nueva respuesta
  Future<void> crearRespuesta(RespuestaItem respuesta) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "tipo": "crear_respuesta",
        ...respuesta.toJson(),
      }),
    );

    if (response.statusCode != 200 || !jsonDecode(response.body)['success']) {
      throw Exception("Error al crear respuesta");
    }
  }

  // Editar una respuesta existente
  Future<void> editarRespuesta(RespuestaItem respuesta) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "tipo": "editar_respuesta",
        ...respuesta.toJson(),
      }),
    );

    if (response.statusCode != 200 || !jsonDecode(response.body)['success']) {
      throw Exception("Error al editar respuesta");
    }
  }

  // Eliminar una respuesta basada en 'evaluacionId' y 'itemId'
  Future<void> eliminarRespuesta(int evaluacionId, int itemId) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "tipo": "eliminar_respuesta",
        "evaluacion_id": evaluacionId,
        "item_id": itemId,
      }),
    );

    if (response.statusCode != 200 || !jsonDecode(response.body)['success']) {
      throw Exception("Error al eliminar respuesta");
    }
  }
}
