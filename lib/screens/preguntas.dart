import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../respuesta_service.dart';
import '../itemO.dart';
import '../respuesta_item.dart';

class Pregunta {
  final int id;
  final String texto;

  Pregunta({required this.id, required this.texto});
}

class QuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QuizScreen(idNom: 1, descripcionNom: "NOM de Seguridad e Higiene"),
      debugShowCheckedModeBanner: false,
    );
  }
}

class QuizScreen extends StatefulWidget {
  final int idNom;
  final String descripcionNom;

  const QuizScreen({
    Key? key,
    required this.idNom,
    required this.descripcionNom,
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Pregunta> preguntas = [];
  List<RespuestaItem> respuestasAnteriores = [];

  bool cargando = true;

  int preguntaActual = 0;
  int puntajeTotal = 0;
  String? aplicaRespuesta;
  String? cumpleRespuesta;
  TextEditingController observacionesController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  Future<void> _preguntaAnterior() async {
    int valorItem = calcularValorItem();

    RespuestaItem respuesta = RespuestaItem(
      evaluacionId: widget.idNom,
      itemId: preguntas[preguntaActual].id,
      aplica: aplicaRespuesta ?? '',
      cumple: cumpleRespuesta ?? '',
      observaciones: observacionesController.text,
      valor: valorItem,
    );

    try {
      final servicio = RespuestaService();
      await servicio.editarRespuesta(respuesta);
    } catch (e) {
      print("Error al actualizar la respuesta: $e");
    }

    setState(() {
      preguntaActual--;
      _cargarRespuestaAnterior();
    });
  }

  Future<void> _cargarRespuestaAnterior() async {
    int itemId = preguntas[preguntaActual].id;
    RespuestaItem? respuesta = respuestasAnteriores.firstWhere(
          (r) => r.itemId == itemId,
      orElse: () => RespuestaItem(
        evaluacionId: widget.idNom,
        itemId: itemId,
        aplica: '',
        cumple: '',
        observaciones: '',
        valor: 0,
      ),
    );

    setState(() {
      aplicaRespuesta = respuesta.aplica;
      cumpleRespuesta = respuesta.cumple;
      observacionesController.text = respuesta.observaciones;
      _image = null; // Si quieres cargar imagen previa, adapta aquí.
    });
  }

  Future<void> _cargarRespuestasAnteriores() async {
    try {
      final servicio = RespuestaService();
      List<RespuestaItem> respuestasObtenidas =
      await servicio.obtenerRespuestas(widget.idNom);

      setState(() {
        respuestasAnteriores = respuestasObtenidas;
      });

      _cargarRespuestaAnterior();
    } catch (e) {
      print('Error al cargar respuestas anteriores: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarTodo();
  }

  Future<void> _cargarTodo() async {
    await _cargarPreguntas();
    await _cargarRespuestasAnteriores();
  }

  Future<void> _cargarPreguntas() async {
    try {
      final servicio = RespuestaService();
      List<Item> items = await servicio.obtenerItems(widget.idNom);

      setState(() {
        preguntas = items
            .map((item) => Pregunta(id: item.idItem, texto: item.pregunta))
            .toList();
        cargando = false;
      });
    } catch (e) {
      setState(() {
        cargando = false;
      });
      print('Error al cargar preguntas: $e');
    }
  }

  int calcularValorItem() {
    if (aplicaRespuesta == 'No') {
      cumpleRespuesta = 'No';
      return 0;
    }
    if (aplicaRespuesta == 'Sí' && cumpleRespuesta == 'No') {
      return 1;
    }
    if (aplicaRespuesta == 'Sí' && cumpleRespuesta == 'Sí') {
      return 2;
    }
    return 0;
  }

  Future<void> siguientePregunta() async {
    if (aplicaRespuesta == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona 'Aplica' para continuar")),
      );
      return;
    }

    if (aplicaRespuesta == 'No') {
      cumpleRespuesta = 'No';
    }

    if (cumpleRespuesta == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona 'Cumple' para continuar")),
      );
      return;
    }

    int valorItem = calcularValorItem();
    puntajeTotal += valorItem;

    RespuestaItem respuesta = RespuestaItem(
      evaluacionId: widget.idNom,
      itemId: preguntas[preguntaActual].id,
      aplica: aplicaRespuesta!,
      cumple: cumpleRespuesta!,
      observaciones: observacionesController.text,
      valor: valorItem,
    );

    try {
      final servicio = RespuestaService();
      await servicio.crearRespuesta(respuesta);
    } catch (e) {
      print('Error al guardar la respuesta: $e');
    }

    if (preguntaActual < preguntas.length - 1) {
      setState(() {
        preguntaActual++;
        aplicaRespuesta = null;
        cumpleRespuesta = null;
        observacionesController.clear();
        _image = null;
        _cargarRespuestaAnterior();
      });
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Cuestionario completado"),
          content: Text("Tu puntaje total es: $puntajeTotal"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar"),
            )
          ],
        ),
      );
    }
  }

  void _mostrarObservaciones() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom, top: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Observaciones",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: observacionesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Escribe tus observaciones...",
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.camera_alt, size: 30),
                onPressed: _pickImage,
              ),
              if (_image != null)
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.file(_image!, height: 100),
                ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cerrar"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildOpcion(
      String titulo,
      String? seleccion,
      Function(String) onChange, {
        bool habilitado = true,
      }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Row(
            children: [
              Radio<String>(
                value: 'Sí',
                groupValue: seleccion,
                onChanged: habilitado ? (val) => onChange(val!) : null,
                activeColor: Colors.orange,
              ),
              const Text('Sí'),
              Radio<String>(
                value: 'No',
                groupValue: seleccion,
                onChanged: habilitado ? (val) => onChange(val!) : null,
                activeColor: Colors.orange,
              ),
              const Text('No'),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progreso = preguntas.isEmpty ? 0.0 : (preguntaActual + 1) / preguntas.length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Cuestionario"),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: preguntaActual > 0 ? _preguntaAnterior : null,
        ),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : preguntas.isEmpty
          ? const Center(child: Text("No se encontraron preguntas."))
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sección: ${widget.descripcionNom}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                "Pregunta ${preguntaActual + 1} de ${preguntas.length}",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: progreso,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
              const SizedBox(height: 20),
              Text(
                preguntas[preguntaActual].texto,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              buildOpcion(
                "¿Aplica?",
                aplicaRespuesta,
                    (value) => setState(() => aplicaRespuesta = value),
              ),
              buildOpcion(
                "¿Cumple?",
                cumpleRespuesta,
                    (value) => setState(() => cumpleRespuesta = value),
              ),
              ElevatedButton(
                onPressed: _mostrarObservaciones,
                child: const Text("Añadir Observaciones"),
              ),
              const Spacer(),
              Row(
                children: [
                  if (preguntaActual > 0)
                    TextButton(
                      onPressed: _preguntaAnterior,
                      child: const Text("Anterior"),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: siguientePregunta,
                    child: const Text("Siguiente"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
