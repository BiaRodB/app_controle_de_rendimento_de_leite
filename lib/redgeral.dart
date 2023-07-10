import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'menu.dart';

Future<void> generatePDF(List<Vaca> vacas) async {
  final pdf = pw.Document();

  for (var vaca in vacas) {
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, child: pw.Text('Vaca ID: ${vaca.id}')),
              pw.SizedBox(height: 10),
              pw.Text('Nome: ${vaca.nome}'),
              pw.Text('Raça: ${vaca.raca}'),
              pw.Text('Idade: ${vaca.idade}'),
              pw.Text('Peso: ${vaca.peso}'),
              pw.SizedBox(height: 10),
              pw.Header(level: 1, child: pw.Text('Rendimentos')),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headers: ['Dia', 'Litros'],
                data: vaca.rendimentos
                    .map((rendimento) => [rendimento.dia, rendimento.litros.toString()])
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  final output = await getTemporaryDirectory();
  final outputFile = File('${output.path}/vacas.pdf');
  await outputFile.writeAsBytes(await pdf.save());

  // Abre o arquivo PDF após a geração
  //OpenFile.open(outputFile.path);
}
