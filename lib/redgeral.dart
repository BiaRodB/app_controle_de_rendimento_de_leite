import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PdfCreator extends StatefulWidget {
  const PdfCreator({Key? key});

  @override
  _PdfCreatorState createState() => _PdfCreatorState();
}

class _PdfCreatorState extends State<PdfCreator> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerador de PDF'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            fetchVacasAndGeneratePDF(context);
          },
          child: Text('Gerar PDF'),
        ),
      ),
    );
  }
}

class Vaca {
  final int id;
  final String nome;
  final String raca;
  final int idade;
  final double peso;
  final List<Rendimento> rendimentos;

  Vaca({
    required this.id,
    required this.nome,
    required this.raca,
    required this.idade,
    required this.peso,
    required this.rendimentos,
  });

  factory Vaca.fromMap(Map<String, dynamic> map) {
    return Vaca(
      id: map['id'],
      nome: map['nome'],
      raca: map['raca'],
      idade: map['idade'],
      peso: map['peso'].toDouble(),
      rendimentos: List<Rendimento>.from(map['rendimentos'].map((json) => Rendimento.fromJson(json))),
    );
  }
}

class Rendimento {
  final String dia;
  final double litros;

  Rendimento({
    required this.dia,
    required this.litros,
  });

  factory Rendimento.fromJson(Map<String, dynamic> json) {
    return Rendimento(
      dia: json['dia'],
      litros: json['litros'].toDouble(),
    );
  }
}

Future<void> fetchVacasAndGeneratePDF(BuildContext context) async {
  final vacasResponse = await http.get(Uri.parse('http://192.168.18.8:8000/vaca/'));
  final rendimentosResponse = await http.get(Uri.parse('http://192.168.18.8:8000/rendimento/'));

  if (vacasResponse.statusCode == 200 && rendimentosResponse.statusCode == 200) {
    final List<dynamic> vacasJson = jsonDecode(vacasResponse.body);
    final List<dynamic> rendimentosJson = jsonDecode(rendimentosResponse.body);

    List<Vaca> vacas = vacasJson.map((json) {
      List<Rendimento> rendimentos = rendimentosJson
          .where((rendimentoJson) => rendimentoJson['vaca'] == json['id'])
          .map((rendimentoJson) => Rendimento.fromJson(rendimentoJson))
          .toList();

      return Vaca.fromMap({
        ...json,
        'rendimentos': rendimentos,
      });
    }).toList();

    generatePDF(vacas);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Falha ao obter os dados das vacas e rendimentos.'),
      ),
    );
  }
}

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
