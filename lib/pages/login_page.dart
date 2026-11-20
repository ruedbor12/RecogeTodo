import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:rodrigo_moraga_proyecto/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  String mensajeError = "";
  bool hayError = false;
  final authService = AuthService();
  late final Future<void> googleInitialization;

  @override
    void initState() {
    super.initState();

    googleInitialization = authService.initializeGoogle();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/construction_stripes.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
                child: Container(
              color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.35),
            ),
          ),

          SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:  EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 420),
              child: Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Nombre e icono de la aplicación
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          MdiIcons.excavator,
                          color: Color.fromARGB(255, 255, 255, 255),
                          size: 80,
                        ),
                         SizedBox(width: 12),
                         Text(
                          'Recogetodo',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 242, 255, 253),
                          ),
                        ),
                      ],
                    ),

                     SizedBox(height: 8),

                    // Subtítulo
                     Text(
                      'Encuéntra lo perdido',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 255, 249, 249),
                      ),
                    ),

                     SizedBox(height: 12),

                     Text(
                      'Un lugar para encontrar lo que has perdido '
                      'y devolver lo que alguien está buscando.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Color.fromARGB(255, 8, 250, 177),
                        height: 1.5,
                      ),
                    ),

                     SizedBox(height: 45),

                    // Título de inicio de sesión
                     Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Inicia sesión',
                        style: TextStyle(
                          fontSize: 33,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),
                    ),

                     SizedBox(height: 8),

                     Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Para consultar las publicaciones '
                        'de tu comunidad.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 8, 250, 177),
                        ),
                      ),
                    ),

                     SizedBox(height: 25),

                    // Botón de inicio de sesión con Google
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () async {
                            try {
                              await googleInitialization;

                              hayError = false;
                              mensajeError = "";

                              await authService.signInWithGoogle();

                            } catch (ex) {
                              hayError = true;
                              mensajeError = "No se pudo iniciar sesión con Google";

                              setState(() {});
                            }
                          },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(237, 180, 111, 7),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             Text(
                              'G',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4285F4),
                              ),
                            ),
                             SizedBox(width: 12),
                             Text(
                              'Accede con Google',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                     SizedBox(height: 20),

                    // Mensaje de error
                    hayError
                        ? Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              border: Border.all(
                                color: Colors.red.shade200,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  MdiIcons.alert,
                                  color: Colors.red,
                                ),
                               SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    mensajeError,
                                    style: const TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        :  SizedBox(height: 45),

                     SizedBox(height: 15),

                     Text(
                      'Objetos perdidos y encontrados',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
        ],
      ),    
    );
  }
}