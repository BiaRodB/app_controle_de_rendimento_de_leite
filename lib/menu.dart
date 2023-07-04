import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vaca_leiteira/cadvaca.dart';
//import 'package:vaca_leiteira/rendimento.dart';


class MenuPage extends StatefulWidget {
  const MenuPage({Key? key});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Vaca> vacas = [];

 Future<void> fetchVacas() async {
  final vacasResponse = await http.get(Uri.parse('http://192.168.18.8:8000/vaca/'));
  final producaoResponse = await http.get(Uri.parse('http://192.168.18.8:8000/rendimento/'));

  if (vacasResponse.statusCode == 200 && producaoResponse.statusCode == 200) {
    final List<dynamic> vacasJson = jsonDecode(vacasResponse.body);
    final List<dynamic> producaoJson = jsonDecode(producaoResponse.body);

    final List<Vaca> fetchedVacas = vacasJson.map((item) {
      final vacaId = item['id'];
      final producaoData = producaoJson.firstWhere((producao) => producao['vaca_id'] == vacaId);

      return Vaca.fromJson({
        
        'nome': producaoData['nome'],
        'raca': producaoData['raca'],
        'idade': producaoData['idade'],
        'peso': producaoData['peso'],
        'dia': producaoData['dia'],
        'litros': producaoData['litros'],
      }
      );
    }).toList();

    setState(() {
      vacas = fetchedVacas;
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Falha ao carregar as vacas.'),
      ),
    );
  }
}

  @override
  void initState() {
    super.initState();
    fetchVacas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: 700,
          width: 500,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CadastroPageV()),
                  );
                },
                child: const Text('Cadastrar Vaca'),
              ),
              const SizedBox(height: 30),
              const Text(
                'Vacas cadastradas:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              if (vacas.isEmpty)
                const Text('Nenhuma vaca cadastrada.')
              else
                Column(
                  children: vacas.map((vaca) {
                    return ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => VacaDetailsPage(vaca: vaca)),
                        );
                      },
                      child: Text('Vaca ${vaca.id} - ${vaca.nome}'),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class VacaDetailsPage extends StatelessWidget {
  final Vaca vaca;

  const VacaDetailsPage({super.key, required this.vaca});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Vaca'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${vaca.id}'),
            Text('Nome: ${vaca.nome}'),
            Text('Raça: ${vaca.raca}'),
            Text('Idade: ${vaca.idade}'),
            Text('Peso: ${vaca.peso}'),
            Text('litros: ${vaca.litros}'),
          ],
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
  final double litros;

  Vaca({
    required this.id,
    required this.nome,
    required this.raca,
    required this.idade,
    required this.peso,
    required this.litros,
  });

  factory Vaca.fromJson(Map<String, dynamic> json) {
    return Vaca(
      id: json['id'],
      nome: json['nome'],
      raca: json['raca'],
      idade: json['idade'],
      peso: json['peso'],
      litros: json['litros'],
    );
  }
}
