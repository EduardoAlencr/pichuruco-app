import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class NovoDepositoScreen extends StatefulWidget {
  const NovoDepositoScreen({super.key});

  @override
  State<NovoDepositoScreen> createState() => _NovoDepositoScreenState();
}

class _NovoDepositoScreenState extends State<NovoDepositoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _elogioController = TextEditingController();
  final _lembrancaController = TextEditingController();

  String? usuario;
  String? codigo;
  String quemDepositou = 'Hay';
  String paraQuem = 'Yogas';
  String elogioAnterior = '';

  @override
  void initState() {
    super.initState();
    final box = Hive.box('pichurucoBox');
    usuario = box.get('usuario');
    codigo = box.get('codigo_casal');

    if (usuario == 'Hay') {
      quemDepositou = 'Hay';
      paraQuem = 'Yogas';
    } else {
      quemDepositou = 'Yogas';
      paraQuem = 'Hay';
    }

    _carregarUltimoElogio();
  }

  Future<void> _carregarUltimoElogio() async {
    if (codigo == null) return;

    final query = await FirebaseFirestore.instance
        .collection('cofrinhos')
        .doc(codigo)
        .collection('depositos')
        .where('quem', isEqualTo: paraQuem)
        .orderBy('data', descending: true)
        .get();

    for (final doc in query.docs) {
      final elogio = doc['elogio']?.toString().trim();
      if (elogio != null && elogio.isNotEmpty) {
        setState(() {
          elogioAnterior = elogio;
        });
        return;
      }
    }

    setState(() {
      elogioAnterior = 'Ainda não há elogios registrados do $paraQuem.';
    });
  }


  Future<void> _salvarDeposito() async {
    if (!_formKey.currentState!.validate()) return;

    final valor = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0;
    final elogio = _elogioController.text.trim();
    final lembranca = _lembrancaController.text.trim();

    await FirebaseFirestore.instance.collection('cofrinhos').doc(codigo).collection('depositos').add({
      'valor': valor,
      'quem': quemDepositou,
      'elogio_para': paraQuem,
      'elogio': elogio,
      'lembranca': lembranca,
      'data': Timestamp.now(),
    });

    // Atualiza o total localmente
    final box = Hive.box('pichurucoBox');
    double saldoAtual = box.get('saldo', defaultValue: 0.0);
    saldoAtual += valor;
    box.put('saldo', saldoAtual);

    if (context.mounted) Navigator.pop(context);
  }

  void _atualizarParaQuem(String selecionado) {
    setState(() {
      quemDepositou = selecionado;
      paraQuem = selecionado == 'Hay' ? 'Yogas' : 'Hay';
      elogioAnterior = '';
    });
    _carregarUltimoElogio();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Slk, vamos casar mesmo, fi.',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _valorController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Valor (R\$)',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) => value == null || value.isEmpty ? 'Informe o valor' : null,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Quem depositou?',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: ['Hay', 'Yogas'].map((nome) {
                          final bool selecionado = quemDepositou == nome;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(
                                nome,
                                style: TextStyle(
                                  color: selecionado ? Colors.white : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              selected: selecionado,
                              onSelected: (_) => _atualizarParaQuem(nome),
                              selectedColor: Colors.deepPurple,
                              backgroundColor: Colors.transparent,
                              side: const BorderSide(color: Colors.white24),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.favorite, color: Colors.purpleAccent),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '$paraQuem\n',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    TextSpan(
                                      text: elogioAnterior,
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _elogioController,
                        decoration: InputDecoration(
                          labelText: 'Deixe um elogio para $paraQuem',
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _lembrancaController,
                        decoration: const InputDecoration(
                          labelText: 'O que você quer se lembrar no futuro?',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _salvarDeposito,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B263B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Salvar'),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
