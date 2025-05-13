import 'package:flutter/material.dart';
import 'nom_service.dart';
import 'nom_card.dart';
import 'values/app_colors.dart';

class NomsPage extends StatefulWidget {
  const NomsPage({Key? key}) : super(key: key);

  @override
  State<NomsPage> createState() => _NomsPageState();
}

class _NomsPageState extends State<NomsPage> {
  late Future<List<Nom>> _futureNoms;

  @override
  void initState() {
    super.initState();
    _futureNoms = NomService().obtenerNoms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NOMS"),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primaryColor),
              child: Text("Menú", style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            _buildDrawerItem(context, Icons.home, "Inicio", "/agenda"),
            _buildDrawerItem(context, Icons.add, "Evaluar NOM", "/evaluar"),
            _buildDrawerItem(context, Icons.group, "Equipo", "/equipo"),
            _buildDrawerItem(context, Icons.apartment, "Organizaciones", "/organizaciones"),
            _buildDrawerItem(context, Icons.history, "Historial de evaluaciones", "/historial"),
            _buildDrawerItem(context, Icons.settings, "Configuración", "/configuracion"),
            _buildDrawerItem(context, Icons.logout, "Cerrar sesión", "/logout"),
          ],
        ),
      ),
      body: FutureBuilder<List<Nom>>(
        future: _futureNoms,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron NOMs'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final nom = snapshot.data![index];
                return NomCard(
                  idNom: nom.idNom,
                  regulacion: nom.regulacion,
                  descripcion: nom.descripcion,
                  area: nom.area,
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: AppColors.darkMode),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, route);
      },
    );
  }
}
