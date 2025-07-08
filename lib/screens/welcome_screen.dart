import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';

import 'criar_codigo_screen.dart';
import 'login_screen.dart';
import '../utils/transitions.dart';
import '../widgets/animated_background.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _verificarAcesso(BuildContext context) async {
    final box = Hive.box('pichurucoBox');
    final codigoSalvo = box.get('codigo_casal');

    if (codigoSalvo == null || codigoSalvo.isEmpty) {
      Navigator.push(context, createFadeSlideRoute(const CriarCodigoScreen()));
    } else {
      Navigator.push(context, createFadeSlideRoute(const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo animado
          const AnimatedBackground(),

          // Conteúdo central
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Lottie
                        SizedBox(
                          height: 180,
                          child: Lottie.asset('assets/images/couple-love.json'),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          'Bem-vindos ao Pichuruco 💙',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),

                        const Text(
                          'O cofrinho digital perfeito para casais apaixonados\nconstruírem sonhos juntos.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 32),

                        SizedBox(
                          width: 180,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () => _verificarAcesso(context),
                            icon: const Icon(Icons.favorite_border),
                            label: const Text('Começar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF415A77), // azul secundário
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(fontSize: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                        )
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
