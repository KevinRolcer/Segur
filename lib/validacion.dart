import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'package:innova/values/app_colors.dart';

class ValidacionPage extends StatefulWidget {
  const ValidacionPage({super.key});

  @override
  State<ValidacionPage> createState() => _ValidacionPageState();
}

class _ValidacionPageState extends State<ValidacionPage> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _verificationId = "";
  bool _isLoading = false;
  String _telefonoUsuario = "";
  final FocusNode _focusNode = FocusNode();
  bool _isKeyboardVisible = false;

  List<String> _codigo = ["", "", "", "", "", ""];
  int _currentDigitIndex = 0;
  final TextEditingController _controller = TextEditingController();

  List<AnimationController> _animControllers = [];
  List<Animation<double>> _animations = [];

  @override
  void initState() {
    super.initState();
    _obtenerNumeroUsuario();

    for (int i = 0; i < 6; i++) {
      AnimationController controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      Animation<double> animation = Tween<double>(begin: 0.0, end: -15.0)
          .chain(CurveTween(curve: Curves.easeOutBack))
          .animate(controller);

      _animControllers.add(controller);
      _animations.add(animation);
    }

    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChange);

    Future.delayed(const Duration(milliseconds: 500), () {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void _onFocusChange() {
    setState(() {
      _isKeyboardVisible = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    for (var controller in _animControllers) {
      controller.dispose();
    }
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;

    setState(() {
      for (int i = 0; i < 6; i++) {
        if (i < text.length) {
          if (_codigo[i] != text[i]) {
            _codigo[i] = text[i];
            _playJumpAnimation(i);
          } else {
            _codigo[i] = text[i];
          }
        } else {
          _codigo[i] = "";
        }
      }

      _currentDigitIndex = text.length;
    });

    if (text.length == 6) {
      _verificarCodigo();
    }
  }

  void _playJumpAnimation(int index) {
    _animControllers[index].reset();
    _animControllers[index].forward();
  }

  Future<void> _obtenerNumeroUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _telefonoUsuario = prefs.getString('userPhone') ?? "";
    });

    if (_telefonoUsuario.isNotEmpty) {
      _enviarCodigo();
    }
  }

  Future<void> _enviarCodigo() async {
    if (_telefonoUsuario.isEmpty) return;

    setState(() => _isLoading = true);

    await _auth.verifyPhoneNumber(
      phoneNumber: _telefonoUsuario,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        _marcarValidado();
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.message}")),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Código enviado")),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );

    setState(() => _isLoading = false);
  }

  Future<void> _verificarCodigo() async {
    String codigoIngresado = _codigo.join();
    if (_verificationId.isEmpty || codigoIngresado.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ingrese un código válido de 6 dígitos")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: codigoIngresado,
      );

      await _auth.signInWithCredential(credential);
      _marcarValidado();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Código incorrecto, intenta nuevamente")),
      );
      setState(() {
        _codigo = ["", "", "", "", "", ""];
        _currentDigitIndex = 0;
        _isLoading = false;
        _controller.text = "";
      });
    }
  }

  Future<void> _marcarValidado() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isValidated', true);
    Navigator.pushReplacementNamed(context, '/agenda');
  }

  void _toggleKeyboard() {
    if (_isKeyboardVisible) {
      // Si el teclado está visible, lo ocultamos
      FocusScope.of(context).unfocus();
    } else {
      // Si el teclado está oculto, lo mostramos
      FocusScope.of(context).requestFocus(_focusNode);
      _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        title: const Text("Validación", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(_focusNode);
          },
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Código de verificación",
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        "Porfavor ingresa el código mandado a\n$_telefonoUsuario",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),

              // TextField oculto
              Opacity(
                opacity: 0,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(counterText: ""),
                ),
              ),

              // Cajas de dígitos con ícono flotante encima
              Expanded(
                flex: 3,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(6, (index) => _buildDigitBox(index)),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 35,
                      child: IconButton(
                        icon: Icon(
                          _isKeyboardVisible ? Icons.keyboard_hide : Icons.keyboard,
                          color: Colors.white,
                        ),
                        tooltip: _isKeyboardVisible ? 'Cerrar teclado' : 'Abrir teclado',
                        onPressed: _toggleKeyboard,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                flex: 2,
                child: Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verificarCodigo,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.primaryColor,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(200, 50),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                      "VALIDATE",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDigitBox(int index) {
    bool isActive = _codigo[index].isNotEmpty;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(_focusNode);
            _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
          },
          child: AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, isActive ? _animations[index].value : 0),
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _codigo[index],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}