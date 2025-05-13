import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  @override
  void initState() {
    super.initState();
    _cargarPreguntas();
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
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 20),
              Text(
                preguntas[preguntaActual].texto,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              buildOpcion("¿Aplica?", aplicaRespuesta, (val) {
                setState(() {
                  aplicaRespuesta = val;
                });
              }),
              buildOpcion("¿Cumple?", cumpleRespuesta, (val) {
                setState(() {
                  cumpleRespuesta = val;
                });
              }, habilitado: aplicaRespuesta == 'Sí'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: observacionesController,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: "Observaciones "),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_note),
                    onPressed: _mostrarObservaciones,
                  ),
                ],
              ),
              const Spacer(),
              LinearProgressIndicator(value: progreso),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: siguientePregunta,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text("Siguiente"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
