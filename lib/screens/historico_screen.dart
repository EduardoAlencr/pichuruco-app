import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:pichuruco/exports/export_utils.dart';

class HistoricoDepositosScreen extends StatefulWidget {
  const HistoricoDepositosScreen({super.key});

  @override
  State<HistoricoDepositosScreen> createState() => _HistoricoDepositosScreenState();
}

class _HistoricoDepositosScreenState extends State<HistoricoDepositosScreen> {
  String? codigo;
  List<Map<String, dynamic>> listaDados = [];

  @override
  void initState() {
    super.initState();
    final box = Hive.box('pichurucoBox');
    codigo = box.get('codigo_casal');
  }

  Future<void> _carregarDados() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('cofrinhos')
        .doc(codigo)
        .collection('depositos')
        .orderBy('data', descending: true)
        .get();

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    listaDados = snapshot.docs.map((doc) {
      final data = (doc['data'] as Timestamp).toDate();
      return {
        'valor': (doc['valor'] as num).toDouble(),
        'quem': doc['quem'],
        'elogio': doc['elogio'] ?? '',
        'lembranca': doc['lembranca'] ?? '',
        'data': dateFormat.format(data),
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('Histórico de Depósitos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: () async {
              await _carregarDados();
              exportarPDF(listaDados);
            },
          ),
          IconButton(
            icon: const Icon(Icons.table_view_outlined, color: Colors.white),
            onPressed: () async {
              await _carregarDados();
              exportarCSV(listaDados);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cofrinhos')
            .doc(codigo)
            .collection('depositos')
            .orderBy('data', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum depósito ainda.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
          final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final valor = (doc['valor'] as num).toDouble();
              final quem = doc['quem'];
              final elogio = doc['elogio'] ?? '';
              final lembranca = doc['lembranca'] ?? '';
              final data = (doc['data'] as Timestamp).toDate();

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          quem,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                        Text(
                          currencyFormat.format(valor),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Elogio  ',
                            style: TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.w500),
                          ),
                          TextSpan(
                            text: elogio,
                            style: const TextStyle(color: Colors.deepPurpleAccent),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lembranca,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        dateFormat.format(data),
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
