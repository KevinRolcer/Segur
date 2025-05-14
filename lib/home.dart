import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'values/app_colors.dart';
import 'login.dart';
import 'equipo.dart';
import 'evaluacion_service.dart';
import 'evaluacion.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  runApp(MiApp(isLoggedIn: isLoggedIn));
}

class MiApp extends StatelessWidget {
  final bool isLoggedIn;
  const MiApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda Diaria',
      theme: ThemeData(
        fontFamily: 'Arial',
        brightness: Brightness.light,
        primaryColor: AppColors.primaryColor,
      ),
      home: isLoggedIn ? const AgendaDiaria() : const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AgendaDiaria extends StatefulWidget {
  const AgendaDiaria({super.key});

  @override
  State<AgendaDiaria> createState() => _AgendaDiariaState();
}

class _AgendaDiariaState extends State<AgendaDiaria> {
  final EvaluacionService evaluacionService = EvaluacionService();
  List<Evaluacion> futurasEvaluaciones = [];
  List<Evaluacion> pasadasEvaluaciones = [];
  bool isLoading = true;

  late List<DateTime> semana;
  late DateTime hoy;

  @override
  void initState() {
    super.initState();
    hoy = DateTime.now();
    semana = List.generate(7, (i) => hoy.subtract(Duration(days: hoy.weekday - 1 - i)));
    obtenerEvaluaciones();
  }

  Future<void> obtenerEvaluaciones() async {
    try {
      List<Evaluacion> futuras = await evaluacionService.obtenerEvaluaciones("futuras");
      List<Evaluacion> pasadas = await evaluacionService.obtenerEvaluaciones("pasadas");

      setState(() {
        futurasEvaluaciones = futuras;
        pasadasEvaluaciones = pasadas;
        isLoading = false;
      });
    } catch (e) {
      print("Error obteniendo evaluaciones: $e");
      setState(() => isLoading = false);
    }
  }

  String obtenerDia(DateTime fecha) {
    return DateFormat.EEEE('es_ES').format(fecha).substring(0, 3); // Ej: "lun", "mar"
  }

  Widget construirTarea(Evaluacion evaluacion) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            evaluacion.nombreOrganizacion,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            "Objetivo: ${evaluacion.objetivo}",
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            "Versión: ${evaluacion.version}",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                DateFormat('yyyy-MM-dd').format(evaluacion.fechaEvaluacion),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agenda Diaria"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Acción para ver notificaciones
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primaryColor),
              child: Text("Menú", style: TextStyle(color: Colors.white)),
            ),
            _buildDrawerItem(context, Icons.home, "Inicio", "/"),
            _buildDrawerItem(context, Icons.add, "Evaluar NOM", "/evaluar"),
            _buildDrawerItem(context, Icons.group, "Equipo", "/equipo"),
            _buildDrawerItem(context, Icons.apartment, "Organizaciones", "/organizaciones"),
            _buildDrawerItem(context, Icons.history, "Historial de evaluaciones", "/historial"),
            _buildDrawerItem(context, Icons.settings, "Configuración", "/configuracion"),
            _buildDrawerItem(context, Icons.logout, "Cerrar sesión", "/logout"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: ListView(
            children: [
              const Text("Hoy", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: semana.map((fecha) {
                  final esHoy = DateFormat('yyyy-MM-dd').format(fecha) ==
                      DateFormat('yyyy-MM-dd').format(hoy);
                  return Expanded(
                    child: Column(
                      children: [
                        Text(obtenerDia(fecha), style: TextStyle(color: esHoy ? Colors.black : Colors.grey)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: esHoy ? AppColors.primaryColor : Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${fecha.day}',
                            style: TextStyle(
                              color: esHoy ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 25),
              const Text("Próximo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              futurasEvaluaciones.isNotEmpty
                  ? Column(children: futurasEvaluaciones.map(construirTarea).toList())
                  : const Center(child: Text("No hay evaluaciones para cargar", style: TextStyle(color: Colors.grey))),
              const SizedBox(height: 15),
              const Text("Últimos 30 días", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              pasadasEvaluaciones.isNotEmpty
                  ? Column(children: pasadasEvaluaciones.map(construirTarea).toList())
                  : const Center(child: Text("No hay evaluaciones en los últimos 30 días", style: TextStyle(color: Colors.grey))),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}