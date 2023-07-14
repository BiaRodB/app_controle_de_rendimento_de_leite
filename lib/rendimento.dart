import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class CadastroRendimentoPage extends StatefulWidget {
  const CadastroRendimentoPage({Key? key, required this.vacaId});

  final int vacaId;

  @override
  _CadastroRendimentoPageState createState() => _CadastroRendimentoPageState();
}

class _CadastroRendimentoPageState extends State<CadastroRendimentoPage> {
  final TextEditingController diaController = TextEditingController();
  final TextEditingController rendimentoController = TextEditingController();

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
        Navigator.pop(context); // Redirect to the previous page
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar a Quantidade de Litros de Leite'),
        backgroundColor: Colors.green[300],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                  labelText: 'Litros de Leite',
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
                    onPressed: () {
                      Navigator.pop(context); // Redirect to the previous page
                    },
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class VisualizacaoRendimentoPage extends StatefulWidget {
  const VisualizacaoRendimentoPage({Key? key, required this.vacaId});

  final int vacaId;

  @override
  _VisualizacaoRendimentoPageState createState() =>
      _VisualizacaoRendimentoPageState();
}

class _VisualizacaoRendimentoPageState extends State<VisualizacaoRendimentoPage> {
  double totalRendimento = 0.0;
  List<RendimentoD> rendimentos = [];
  String nomeVaca = '';

  Future<double> getTotalRendimento() async {
    final response = await http.get(
      Uri.parse('http://192.168.18.8:8000/rendimento/?vaca=${widget.vacaId}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> rendimentosJson = jsonDecode(response.body);

      final filteredRendimentos = rendimentosJson.where((rendimentoJson) {
        final rendimento = RendimentoD.fromMap(rendimentoJson);
        return rendimento.vaca == widget.vacaId;
      }).toList();

      final double sum = filteredRendimentos.fold(0.0, (previousValue, rendimentoJson) {
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

  Future<List<RendimentoD>> getRendimentos() async {
    final response = await http.get(
      Uri.parse('http://192.168.18.8:8000/rendimento/'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> rendimentosJson = jsonDecode(response.body);
      final List<RendimentoD> rendimentosList = rendimentosJson.map((rendimentoJson) {
        final rendimento = RendimentoD.fromMap(rendimentoJson);
        if (rendimento.vaca == widget.vacaId) {
          return rendimento;
        } else {
          return null;
        }
      }).whereType<RendimentoD>().toList();

      return rendimentosList;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha ao obter os rendimentos.'),
        ),
      );
      return [];
    }
  }

  Future<String> getNomeVaca() async {
    final response = await http.get(
      Uri.parse('http://192.168.18.8:8000/vaca/${widget.vacaId}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> vacaJson = jsonDecode(response.body);
      final vaca = Vaca.fromMap(vacaJson);
      return vaca.nome;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha ao obter o nome da vaca.'),
        ),
      );
      return '';
    }
  }

  @override
  void initState() {
    super.initState();
    getTotalRendimento().then((total) {
      setState(() {
        totalRendimento = total;
      });
    });
    getRendimentos().then((list) {
      setState(() {
        rendimentos = list;
      });
    });
    getNomeVaca().then((nome) {
      setState(() {
        nomeVaca = nome;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rendimento de leite'),
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
                      'Total de Rendimentos da vaca $nomeVaca: $totalRendimento',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 30),
              Text(
                'Rendimentos de Litros de Leite:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                itemCount: rendimentos.length,
                itemBuilder: (context, index) {
                  final rendimento = rendimentos[index];
                  return ListTile(
                    title:  Text('Rendimento: ${rendimento.litros}'),
                    subtitle: Text('Dia: ${rendimento.dia}'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Vaca {
  int id;
  String nome;

  Vaca({required this.id, required this.nome});

  factory Vaca.fromMap(Map<String, dynamic> map) {
    return Vaca(
      id: map['id'],
      nome: map['nome'],
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
