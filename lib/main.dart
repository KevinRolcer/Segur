import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'validacion.dart';
import 'home.dart';
import 'noms.dart';
import 'equipo.dart' as eq;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.clear();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MiApp());
}

class MiApp extends StatelessWidget {

  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Innova App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/validacion': (context) => const ValidacionPage(),
        '/agenda': (context) => const AgendaDiaria(),
        '/equipo': (context) => const eq.EquipoPage(),
        '/evaluar':(context)=> const NomsPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}