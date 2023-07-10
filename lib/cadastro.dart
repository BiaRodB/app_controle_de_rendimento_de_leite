import 'package:equatable/equatable.dart';
//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'widgets/callgoogle.dart';
import 'widgets/callfacebook.dart';
//import 'widgets/callapple.dart';
import 'dart:async';

class CadastroPage extends StatefulWidget {
  const CadastroPage({Key? key}) : super(key: key);

  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController confirmarSenhaController = TextEditingController();

 Future<void> cadastrar(BuildContext context) async {
  final nome = nomeController.text;
  final email = emailController.text;
  final senha = senhaController.text;
  final confirmarSenha = confirmarSenhaController.text;

  if (senha != confirmarSenha) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('As senhas não correspondem.'),
      ),
    );
    return;
  }

    final url = Uri.parse('http://192.168.18.8:8000/pessoa/'); // Atualize com a URL da sua API local

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'email': email,
        'senha': senha,
      }),
    );

    if (response.statusCode == 201) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Cadastro realizado com sucesso!'),
    ),
  );
  Timer(const Duration(seconds: 2), () {
    Navigator.of(context).pop(); 
  });
  }else {
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
              Image.asset(
          'assets/images/user.png', // Insira o caminho da imagem
          width: 100,
          height: 100, 
        ),
         const SizedBox(height: 30),
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                obscureText: true,
                controller: confirmarSenhaController,
                decoration: const InputDecoration(
                labelText: 'Confirmar senha',
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
              const SizedBox(height: 30),
              const Text('Cadastre-se também pelo: ',),
           const SizedBox(height: 30),
            SingleChildScrollView(child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GoogleBtn1(onPressed: () {}),
                FacebookBtn1(onPressed: () {}),
              ],
            ),
            ) 
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class Cadastro extends Equatable {
  late int? id;
  final String nome;
  final String email;
  final String senha;

  Cadastro({this.id, required this.nome, required this.email, required this.senha});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
    };
  }

  factory Cadastro.fromMap(Map<String, dynamic> map) {
    return Cadastro(
      id: map['id'],
      nome: map['nome'],
      email: map['email'],
      senha: map['senha'],
    );
  }

  @override
  List<Object?> get props => [id];
}