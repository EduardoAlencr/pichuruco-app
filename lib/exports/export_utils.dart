import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Exporta os dados em formato CSV permitindo ao usuário escolher o local de salvamento
Future<void> exportarCSV(List<Map<String, dynamic>> dados) async {
  final List<List<dynamic>> linhas = [
    ['Data', 'Valor', 'Elogio']
  ];

  for (var item in dados) {
    linhas.add([
      item['data'],
      item['valor'],
      item['elogio'] ?? ''
    ]);
  }

  String csvData = const ListToCsvConverter().convert(linhas);

  final outputPath = await FilePicker.platform.saveFile(
    dialogTitle: 'Salvar histórico como CSV',
    fileName: 'historico_pichuruco.csv',
    type: FileType.custom,
    allowedExtensions: ['csv'],
  );

  if (outputPath != null) {
    final file = File(outputPath);
    await file.writeAsString(csvData);
    print('CSV exportado para $outputPath');
  } else {
    print('Exportação cancelada pelo usuário');
  }
}

/// Exporta os dados em formato PDF com design semelhante à tela de histórico
Future<void> exportarPDF(List<Map<String, dynamic>> dados) async {
  final pdf = pw.Document();
  final purple = PdfColor.fromHex('#673AB7');
  final background = PdfColor.fromHex('#0D1B2A');

  pdf.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        margin: const pw.EdgeInsets.all(24),
        theme: pw.ThemeData.withFont(
          base: await PdfGoogleFonts.openSansRegular(),
          bold: await PdfGoogleFonts.openSansBold(),
        ),
        buildBackground: (context) => pw.FullPage(
          ignoreMargins: true,
          child: pw.Container(color: background),
        ),
      ),
      build: (context) {
        return [
          pw.Text('Histórico de Depósitos',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              )),
          pw.SizedBox(height: 20),
          ...dados.map((item) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#1B263B'),
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        item['quem'] ?? 'Anônimo',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: purple,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'R\$ ${item['valor'].toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: purple,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  if (item['elogio'] != null && item['elogio'].toString().trim().isNotEmpty)
                    pw.Text('Elogio: ${item['elogio']}', style: pw.TextStyle(color: purple, fontSize: 12)),
                  if (item['lembranca'] != null && item['lembranca'].toString().trim().isNotEmpty)
                    pw.Text(item['lembranca'], style: const pw.TextStyle(color: PdfColors.white, fontSize: 11)),
                  pw.SizedBox(height: 4),
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      item['data'],
                      style: const pw.TextStyle(color: PdfColors.grey, fontSize: 10),
                    ),
                  ),
                ],
              ),
            );
          }).toList()
        ];
      },
    ),
  );

  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}
