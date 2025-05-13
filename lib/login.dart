import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'home.dart';
import 'login_service.dart';
import 'values/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _telController = TextEditingController();
  final BuscarUsuarioService _buscarUsuarioService = BuscarUsuarioService();
  bool _isLoading = false;
  String _lada = "+52";

  void _iniciarSesion() async {
    final telefonoSinLada = _telController.text.trim();
    final telefonoCompleto = _lada + telefonoSinLada;

    if (telefonoSinLada.isEmpty) {
      _mostrarError("El teléfono es obligatorio");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _buscarUsuarioService.buscarUsuario(telefonoSinLada);

      if (response['success']) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setBool('isValidated', false);
        await prefs.setString('userPhone', telefonoCompleto);

        HapticFeedback.lightImpact();

        Navigator.pushReplacementNamed(context, '/validacion');
      } else {
        HapticFeedback.heavyImpact();
        _mostrarError(response['mensaje']);
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      _mostrarError('Error al conectar con el servidor. Intenta nuevamente.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("SegurApp", style: TextStyle(fontSize: 32, color: Colors.white)),
              const SizedBox(height: 40),

              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: DropdownButton<String>(
                      value: _lada,
                      items: ["+52", "+1", "+44", "+33", "+57", "+49", "+55", "+91"].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() => _lada = newValue ?? "+52");
                      },
                      dropdownColor: Colors.blueAccent,
                      underline: Container(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _telController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Teléfono'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.orangeAccent)
                  : ElevatedButton(
                onPressed: _iniciarSesion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Validar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white),
      ),
      fillColor: Colors.white10,
      filled: true,
    );
  }
}