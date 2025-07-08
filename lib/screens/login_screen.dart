import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';
import 'criar_codigo_screen.dart';
import '../utils/transitions.dart';
import '../widgets/animated_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _codigo = '';
  String _usuario = 'Yogas';

  void _tentarEntrar() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('cofrinhos').doc(_codigo).get();

      if (doc.exists) {
        final box = Hive.box('pichurucoBox');
        await box.put('codigo_casal', _codigo);
        await box.put('usuario', _usuario);
        Navigator.pushReplacement(context, createFadeSlideRoute(const HomeScreen()));
      } else {
        // Redirecionar para definição do código se não existir
        Navigator.pushReplacement(context, createFadeSlideRoute(const CriarCodigoScreen()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao verificar código. Tente novamente.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),

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
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Entrar no Pichuruco',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),

                        Wrap(
                          spacing: 12,
                          children: ['Yogas', 'Hay'].map((nome) {
                            return ChoiceChip(
                              label: Text(nome),
                              selected: _usuario == nome,
                              selectedColor: const Color(0xFF415A77),
                              onSelected: (_) {
                                setState(() => _usuario = nome);
                              },
                              backgroundColor: Colors.white10,
                              labelStyle: const TextStyle(color: Colors.white),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        TextField(
                          onChanged: (value) => _codigo = value.trim(),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Código do casal',
                            hintStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white10,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: 160,
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: _tentarEntrar,
                            icon: const Icon(Icons.login),
                            label: const Text('Entrar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF415A77),
                              foregroundColor: Colors.white,
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
