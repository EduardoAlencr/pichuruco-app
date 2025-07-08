import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'login_screen.dart';

class CriarCodigoScreen extends StatefulWidget {
  final String? codigoInicial;
  const CriarCodigoScreen({super.key, this.codigoInicial});

  @override
  State<CriarCodigoScreen> createState() => _CriarCodigoScreenState();
}

class _CriarCodigoScreenState extends State<CriarCodigoScreen> {
  final _codigoController = TextEditingController();
  final _metaController = TextEditingController(text: '15000.00');
  final _fraseController = TextEditingController(
    text: 'Slk, vamos casar mesmo, fi.',
  );

  bool _carregando = false;

  Future<void> _criarCodigo() async {
    final codigo = _codigoController.text.trim();
    final metaStr = _metaController.text.replaceAll(',', '.');
    final frase = _fraseController.text.trim();

    if (codigo.isEmpty || frase.isEmpty || metaStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos.')),
      );
      return;
    }

    final meta = double.tryParse(metaStr);
    if (meta == null || meta <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meta inválida. Informe um número.')),
      );
      return;
    }

    setState(() => _carregando = true);

    final docRef = FirebaseFirestore.instance.collection('cofrinhos').doc(codigo);
    final docSnap = await docRef.get();

    if (docSnap.exists) {
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esse código já está em uso. Escolha outro.')),
      );
      return;
    }

    // Cria o documento no Firestore
    await docRef.set({
      'meta': meta,
      'frase': frase,
      'criado_em': Timestamp.now(),
    });

    // Salva localmente
    final box = Hive.box('pichurucoBox');
    await box.put('codigo_casal', codigo);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.codigoInicial != null) {
      _codigoController.text = widget.codigoInicial!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('Configurar Cofrinho'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Defina o código do casal, a meta de economia\n e uma frase personalizada 💜',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 32),

              // Código
              TextField(
                controller: _codigoController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Código do casal',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Meta
              TextField(
                controller: _metaController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Meta de economia (R\$)',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 24),

              // Frase
              TextField(
                controller: _fraseController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Frase personalizada para a Home',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _carregando ? null : _criarCodigo,
                  icon: _carregando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.lock),
                  label: const Text('Criar Cofrinho'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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
}
