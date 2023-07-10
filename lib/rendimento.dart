import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RendPage extends StatefulWidget {
  const RendPage({Key? key, required this.vacaId});

  final int vacaId;

  @override
  _RendPageState createState() => _RendPageState();
}

class _RendPageState extends State<RendPage> {
  final TextEditingController diaController = TextEditingController();
  final TextEditingController rendimentoController = TextEditingController();

  double totalRendimento = 0.0;

  void cadastrarRendimento(BuildContext context) async {
    final dia = diaController.text;
    final rendimento = double.tryParse(rendimentoController.text);

    if (rendimento != null) {
      final rendimentoObj = RendimentoD(
        dia: dia,
        litros: rendimento,
        vaca: widget.vacaId,
      );

      final response = await http.post(
        Uri.parse('http://192.168.18.8:8000/rendimento/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(rendimentoObj.toMap()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rendimento cadastrado com sucesso!'),
          ),
        );
        Navigator.pop(context); // Redirect to the previous page (MenuPage)
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Falha ao cadastrar o rendimento.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Valor de rendimento inválido.'),
        ),
      );
    }
  }

  Future<double> getTotalRendimento() async {
    final response = await http.get(
      Uri.parse('http://192.168.18.8:8000/rendimento/?vaca=${widget.vacaId}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> rendimentosJson = jsonDecode(response.body);
      final double sum = rendimentosJson.fold(0.0, (previousValue, rendimentoJson) {
        final rendimento = RendimentoD.fromMap(rendimentoJson);
        return previousValue + rendimento.litros;
      });
      return sum;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha ao obter o total de rendimentos.'),
        ),
      );
      return 0.0;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTotalRendimento();
  }

  Future<void> fetchTotalRendimento() async {
    final total = await getTotalRendimento();
    setState(() {
      totalRendimento = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rendimento de leite do dia'),
       backgroundColor: Colors.green[300],
      ),
      body: SingleChildScrollView(
        child: Container(
          height: 700,
          width: 500,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
             'assets/images/vaca.jpg', // Insira o caminho da imagem
             width: 100,
             height: 100, 
            ),
            const SizedBox(height: 30),
              TextFormField(
                controller: diaController,
                decoration: const InputDecoration(
                  labelText: 'Data',
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: rendimentoController,
                decoration: const InputDecoration(
                  labelText: 'Rendimento',
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => cadastrarRendimento(context),
                    child: const Text('Cadastrar'),
                  ),
                  const SizedBox(width: 20),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              FutureBuilder<double>(
                future: getTotalRendimento(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Erro ao obter o total de rendimentos.');
                  } else {
                    final totalRendimento = snapshot.data!;
                    return Text(
                      'Total de Rendimentos: $totalRendimento',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RendimentoD {
  int? id;
  String dia;
  double litros;
  int vaca;

  RendimentoD({this.id, required this.dia, required this.litros, required this.vaca});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dia': dia,
      'litros': litros,
      'vaca': vaca,
    };
  }

  factory RendimentoD.fromMap(Map<String, dynamic> map) {
    return RendimentoD(
      id: map['id'],
      dia: map['dia'],
      litros: double.parse(map['litros'].toString()),
      vaca: map['vaca'],
    );
  }
}
