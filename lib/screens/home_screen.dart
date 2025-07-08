import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:animations/animations.dart';
import 'package:animated_background/animated_background.dart';

import 'cofrinho_config_screen.dart';
import 'novo_deposito_screen.dart';
import 'historico_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String usuario = '';
  String codigo = '';
  String frase = '';
  double meta = 15000.0;
  double saldo = 0.0;
  DateTime? dataMeta;

  bool _metaAlcancada = false;
  bool _mostrarCelebracao = false;

  late AnimationController _pulseController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _carregarDadosLocais();
    _carregarDadosFirestore();

    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _carregarDadosFirestore();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _carregarDadosLocais() async {
    final box = Hive.box('pichurucoBox');
    usuario = box.get('usuario', defaultValue: 'Usuário');
    codigo = box.get('codigo_casal', defaultValue: '');
    setState(() {});
  }

  Future<void> _carregarDadosFirestore() async {
    final doc = await FirebaseFirestore.instance.collection('cofrinhos').doc(codigo).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        meta = (data['meta'] as num).toDouble();
        frase = data['frase'] ?? '';
        dataMeta = (data['data_meta'] as Timestamp?)?.toDate();
      });

      final depositos = await FirebaseFirestore.instance
          .collection('cofrinhos')
          .doc(codigo)
          .collection('depositos')
          .get();

      final total = depositos.docs.fold(0.0, (soma, doc) {
        return soma + (doc['valor'] as num).toDouble();
      });

      final novaMetaAlcancada = total >= meta;

      if (novaMetaAlcancada && !_metaAlcancada) {
        setState(() {
          _metaAlcancada = true;
          _mostrarCelebracao = true;
        });

        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            setState(() {
              _mostrarCelebracao = false;
            });
          }
        });
      } else if (!novaMetaAlcancada) {
        setState(() {
          _metaAlcancada = false;
        });
      }

      setState(() {
        saldo = total;
      });
    }
  }

  double get progresso => saldo / meta;
  double get restante => meta - saldo;
  String get tempoRestante {
    if (dataMeta == null) return 'Sem data definida';
    final dias = dataMeta!.difference(DateTime.now()).inDays;
    return dias > 0 ? '$dias dias restantes' : 'Data da meta atingida';
  }

  void _abrirConfiguracoes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ConfigurarCofrinhoScreen()),
    ).then((_) => _carregarDadosFirestore());
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirConfiguracoes,
        backgroundColor: const Color(0xFF1B263B),
        foregroundColor: Colors.white,
        child: const Icon(Icons.settings),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: RefreshIndicator(
              color: Colors.deepPurple,
              backgroundColor: const Color(0xFF0D1B2A),
              onRefresh: _carregarDadosFirestore,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        '"$frase"',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B263B),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              if (_metaAlcancada)
                                BoxShadow(
                                  color: Colors.deepPurple.withOpacity(
                                    0.3 + 0.3 * _pulseController.value,
                                  ),
                                  blurRadius: 16,
                                  spreadRadius: 1,
                                ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text('Saldo atual', style: TextStyle(fontSize: 16, color: Colors.white70)),
                              const SizedBox(height: 4),
                              Text(
                                currencyFormat.format(saldo),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text('Meta', style: TextStyle(fontSize: 16, color: Colors.white70)),
                              const SizedBox(height: 4),
                              Text(
                                currencyFormat.format(meta),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.white12,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Stack(
                                    children: [
                                      FractionallySizedBox(
                                        widthFactor: progresso.clamp(0.0, 1.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFFD1C4E9),
                                                Color(0xFF9575CD),
                                                Color(0xFF512DA8),
                                              ],
                                              stops: [0.0, 0.5, 1.0],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('${(progresso * 100).round()}%', style: const TextStyle(color: Colors.white60)),
                              const SizedBox(height: 8),
                              Text(
                                'Faltam ${currencyFormat.format(restante > 0 ? restante : 0)} • $tempoRestante',
                                style: const TextStyle(fontSize: 14, color: Colors.white60),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OpenContainer(
                          closedColor: Colors.transparent,
                          openColor: Colors.transparent,
                          closedElevation: 0,
                          transitionDuration: const Duration(milliseconds: 500),
                          openBuilder: (_, __) => const NovoDepositoScreen(),
                          closedBuilder: (_, openContainer) => IconButton(
                            icon: const Icon(Icons.add_circle_outline, size: 32, color: Colors.white),
                            onPressed: openContainer,
                          ),
                        ),
                        OpenContainer(
                          closedColor: Colors.transparent,
                          openColor: Colors.transparent,
                          closedElevation: 0,
                          transitionDuration: const Duration(milliseconds: 500),
                          openBuilder: (_, __) => const HistoricoDepositosScreen(),
                          closedBuilder: (_, openContainer) => IconButton(
                            icon: const Icon(Icons.history, size: 32, color: Colors.white),
                            onPressed: openContainer,
                          ),
                        ),
                        OpenContainer(
                          closedColor: Colors.transparent,
                          openColor: Colors.transparent,
                          closedElevation: 0,
                          transitionDuration: const Duration(milliseconds: 500),
                          openBuilder: (_, __) => const Placeholder(),
                          closedBuilder: (_, openContainer) => IconButton(
                            icon: const Icon(Icons.download, size: 32, color: Colors.white),
                            onPressed: openContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          if (_mostrarCelebracao)
            AnimatedBackground(
              behaviour: RandomParticleBehaviour(
                options: ParticleOptions(
                  baseColor: Colors.deepPurpleAccent,
                  spawnMinSpeed: 30,
                  spawnMaxSpeed: 100,
                  spawnMinRadius: 20,
                  spawnMaxRadius: 50,
                  particleCount: 60,
                ),
              ),
              vsync: this,
              child: Container(
                color: Colors.deepPurple.withOpacity(0.85),
                alignment: Alignment.center,
                child: const Text(
                  'Meta atingida 🎉',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
