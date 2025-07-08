import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../utils/transitions.dart';

class ConfigurarCofrinhoScreen extends StatefulWidget {
  const ConfigurarCofrinhoScreen({super.key});

  @override
  State<ConfigurarCofrinhoScreen> createState() => _ConfigurarCofrinhoScreenState();
}

class _ConfigurarCofrinhoScreenState extends State<ConfigurarCofrinhoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fraseController = TextEditingController();
  final _metaController = TextEditingController();
  DateTime? _dataSelecionada;

  String codigo = '';

  @override
  void initState() {
    super.initState();
    final box = Hive.box('pichurucoBox');
    codigo = box.get('codigo_casal', defaultValue: '');
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final doc = await FirebaseFirestore.instance.collection('cofrinhos').doc(codigo).get();
    if (doc.exists) {
      final data = doc.data()!;
      _metaController.text = (data['meta'] as num?)?.toStringAsFixed(2) ?? '';
      _fraseController.text = data['frase'] ?? '';
      _dataSelecionada = (data['data_meta'] as Timestamp?)?.toDate();
      setState(() {});
    }
  }

  Future<void> _salvarConfiguracoes() async {
    if (_formKey.currentState!.validate()) {
      final novaMeta = double.tryParse(_metaController.text) ?? 0.0;
      final novaFrase = _fraseController.text.trim();

      await FirebaseFirestore.instance.collection('cofrinhos').doc(codigo).update({
        'meta': novaMeta,
        'frase': novaFrase,
        'data_meta': _dataSelecionada,
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configurações atualizadas com sucesso!')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _selecionarData() async {
    final agora = DateTime.now();
    final novaData = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? agora,
      firstDate: agora,
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: ThemeData.dark(),
        child: child!,
      ),
    );
    if (novaData != null) {
      setState(() => _dataSelecionada = novaData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Configurar Cofrinho'),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _metaController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nova Meta (R\$)',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Informe a meta' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fraseController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Frase motivacional',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Data da Meta', style: TextStyle(color: Colors.white70)),
                subtitle: Text(
                  _dataSelecionada != null ? formatter.format(_dataSelecionada!) : 'Nenhuma data selecionada',
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_month, color: Colors.white70),
                  onPressed: _selecionarData,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvarConfiguracoes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B263B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Salvar Configurações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
