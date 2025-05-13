import 'package:flutter/material.dart';
import 'dart:math';
import 'usuario_service.dart';
import 'usuario.dart';
import 'contact.dart';
import 'values/app_colors.dart';


class EquipoPage extends StatefulWidget {
  const EquipoPage({super.key});

  @override
  _EquipoPageState createState() => _EquipoPageState();
}

class _EquipoPageState extends State<EquipoPage> {
  int _currentIndex = 0;
  String _circleName = '';
  List<Contact> _selectedContacts = [];
  List<Contact> _allContacts = [];

  final UsuarioService _usuarioService = UsuarioService();

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  void _cargarUsuarios() async {
    try {
      List<Usuario> usuarios = await _usuarioService.obtenerUsuarios();
      setState(() {
        _allContacts = usuarios.map((usuario) => Contact(
          usuario.nombre,
          usuario.telefono,
          _getRandomColor(),
        )).toList();
      });
    } catch (error) {
      print("Error al obtener usuarios: $error");
    }
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


  Color _getRandomColor() {
    List<Color> colores = [Colors.red, Colors.blue, Colors.green, Colors.purple, Colors.orange];
    return colores[Random().nextInt(colores.length)];
  }

  List<Circle> _circles = [];

  void _goBack() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _goForward() {
    if (_currentIndex < 2) {
      setState(() {
        _currentIndex++;
      });
    } else {
      setState(() {
        _circles.add(Circle(_circleName, _selectedContacts.length,
            _selectedContacts.map((c) => c.color).toList()));
        _currentIndex = 0;
        _circleName = '';
        _selectedContacts = [];
      });
    }
  }

  void _toggleContact(Contact contact) {
    setState(() {
      if (_selectedContacts.contains(contact)) {
        _selectedContacts.remove(contact);
      } else {
        if (_selectedContacts.length < 4) {
          _selectedContacts.add(contact);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pueden agregar más de 4 participantes'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
        title: const Text("Mi equipo"),
      )
          : null,

      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primaryColor),
              child: Text(
                "Menú",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
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

      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildYourCirclesScreen(),
            _buildNameCircleScreen(),
            _buildCreateCircleScreen(),
          ],
        ),
      ),
    );
  }


  Widget _buildYourCirclesScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mis Equipos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _circles.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No tienes equipos creados',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => setState(() => _currentIndex = 1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Crear nuevo equipo',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
                : GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                ..._circles.map((circle) => _buildCircleItem(circle)),
                _buildNewCircleButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleItem(Circle circle) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: _buildAvatarStack(circle.avatarColors),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          circle.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          '${circle.memberCount} participantes',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAvatarStack(List<Color> colors) {
    if (colors.isEmpty) return [];

    if (colors.length == 1) {
      return [
        _buildAvatar(colors[0], 0, 0),
      ];
    }

    if (colors.length == 2) {
      return [
        _buildAvatar(colors[0], -15, 0),
        _buildAvatar(colors[1], 15, 0),
      ];
    }

    if (colors.length == 3) {
      return [
        _buildAvatar(colors[0], -20, 5),
        _buildAvatar(colors[1], 0, -15),
        _buildAvatar(colors[2], 20, 5),
      ];
    }

    return [
      _buildAvatar(colors[0], -20, -10),
      _buildAvatar(colors[1], 20, -10),
      _buildAvatar(colors[2], -20, 20),
      _buildAvatar(colors[3], 20, 20),
    ];
  }

  Widget _buildAvatar(Color color, double dx, double dy) {
    return Transform.translate(
      offset: Offset(dx, dy),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Center(
          child: Icon(
            Icons.person_outline,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildNewCircleButton() {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 1), // Ir primero a la pantalla de nombre
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.add,
                size: 40,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nuevo Equipo',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameCircleScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: _goBack,
          ),
          const SizedBox(height: 20),
          const Text(
            'Nombra tu equipo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: _buildAvatarStack(_selectedContacts.map((c) => c.color).toList()),
              ),
            ),
          ),
          const SizedBox(height: 30),
          TextField(
            autofocus: true,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20),
            decoration: const InputDecoration(
              hintText: 'Nombre del equipo',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) {
              setState(() {
                _circleName = value;
              });
            },
          ),
          const Spacer(),
          Center(
            child: ElevatedButton(
              onPressed: _circleName.isNotEmpty ? _goForward : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildCreateCircleScreen() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: _goBack,
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          ),
          const Text(
            'Crea tu equipo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Organiza tu equipo (máximo 4)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: _selectedContacts.isEmpty
                    ? []
                    : _buildAvatarStack(_selectedContacts.map((c) => c.color).toList()),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _allContacts.length,
              itemBuilder: (context, index) {
                final contact = _allContacts[index];
                final isSelected = _selectedContacts.contains(contact);

                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: contact.color,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_outline,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  title: Text(
                    contact.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(contact.phone),
                  trailing: isSelected
                      ? const Text(
                    '✓ Invitado',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  )
                      : TextButton(
                    onPressed: () => _toggleContact(contact),
                    child: const Text(
                      'Invitar',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () => _toggleContact(contact),
                );
              },
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: _selectedContacts.isNotEmpty ? _goForward : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class Contact {
  final String name;
  final String phone;
  final Color color;

  Contact(this.name, this.phone, this.color);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Contact && other.phone == phone;
  }

  @override
  int get hashCode => phone.hashCode;
}

class Circle {
  final String name;
  final int memberCount;
  final List<Color> avatarColors;

  Circle(this.name, this.memberCount, this.avatarColors);
}