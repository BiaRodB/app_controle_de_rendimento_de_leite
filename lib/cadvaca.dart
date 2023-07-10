import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vaca_leiteira/menu.dart';
import 'dart:convert';
import 'login.dart';
// Importe a classe MenuPage

class CadastroPageV extends StatefulWidget {
  CadastroPageV({Key? key}) : super(key: key);

  @override
  _CadastroPageVState createState() => _CadastroPageVState();
}

class _CadastroPageVState extends State<CadastroPageV> {
  TextEditingController nomeController = TextEditingController();
  TextEditingController racaController = TextEditingController();
  TextEditingController idadeController = TextEditingController();
  TextEditingController pesoController = TextEditingController();

  Future<void> cadastrar(BuildContext context) async {
    final nome = nomeController.text;
    final raca = racaController.text;
    final idade = int.tryParse(idadeController.text) ?? 0;
    final peso = double.tryParse(pesoController.text) ?? 0;

    final url = Uri.parse('http://192.168.18.8:8000/vaca/');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'raca': raca,
        'idade': idade,
        'kg': peso,
        'usuario': LoginPage.userId.toString(),
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado com sucesso!'),
        ),
      );

      // Redirecione para a página MenuPage
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MenuPage()),
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
                  labelText: 'Idade',
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: pesoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Kg',
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => cadastrar(context),
                child: const Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
