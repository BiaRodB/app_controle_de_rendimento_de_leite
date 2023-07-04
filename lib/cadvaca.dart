import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CadastroPageV extends StatefulWidget {
  const CadastroPageV({Key? key});

  @override
  _CadastroPageVState createState() => _CadastroPageVState();
}

class _CadastroPageVState extends State<CadastroPageV> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController racaController = TextEditingController();
  final TextEditingController idadeController = TextEditingController();
  final TextEditingController pesoController = TextEditingController();

  Future<void> cadastrar(BuildContext context) async {
    final nome = nomeController.text;
    final raca = racaController.text;
    final idade = int.tryParse(idadeController.text) ?? 0;
    final peso = double.tryParse(pesoController.text) ?? 0;

    final url = Uri.parse('http://10.0.0.108:8000/vaca/'); // Atualize com a URL da sua API local

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'raca': raca,
        'idade': idade,
        'kg': peso,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado com sucesso!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha ao cadastrar. Tente novamente.'),
        ),
      );
    }
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
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: racaController,
                decoration: const InputDecoration(
                  labelText: 'Raça',
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: idadeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Idade:',
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: pesoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Kg:',
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => cadastrar(context),
                    child: const Text('Cadastrar'),
                  ),
                  const SizedBox(width: 20,),
                  TextButton(
                    onPressed: () {},
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

class CadastroV {
  int? id;
  final String nome;
  final String raca;
  final int idade;
  final double peso;

  CadastroV({this.id, required this.nome, required this.raca, required this.idade, required this.peso});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'raca': raca,
      'idade': idade,
      'peso': peso,
    };
  }

  factory CadastroV.fromMap(Map<String, dynamic> map) {
    return CadastroV(
      id: map['id'],
      nome: map['nome'],
      raca: map['raca'],
      idade: map['idade'],
      peso: map['kg'],
    );
  }
  List<Object?> get props => [id];

}
