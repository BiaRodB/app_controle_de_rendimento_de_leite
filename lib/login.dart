import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'menu.dart';
import 'widgets/callgoogle.dart';
import 'widgets/callfacebook.dart';
import 'widgets/inputsfield.dart';
import 'cadastro.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  static int? userId;

  @override
  _LoginPageState createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  Future<void> performLogin() async {
    final email = emailController.text;
    final senha = senhaController.text;

    String apiUrl = 'http://10.0.0.108:8000/pessoa/'; // Substitua pela sua URL da API

    http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      // Verifique se existe algum objeto na lista com o email e senha fornecidos
      bool exists = jsonResponse.any((pessoa) =>
          pessoa['email'] == email && pessoa['senha'] == senha);

      if (exists) {
         LoginPage.userId = jsonResponse.firstWhere(
         (pessoa) => pessoa['email'] == email && pessoa['senha'] == senha,
         )['id'];
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Sucesso'),
              content: const Text('Login bem-sucedido!'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MenuPage()),
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Erro de Login'),
              content: const Text('Credenciais inválidas. Falha no login.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erro de Login'),
            content: const Text('Falha na comunicação com o servidor.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }


  bool rememberMe = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.green[300],
      ),
      body: SingleChildScrollView(
        child: Container(
          height: 700,
          width: 500,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              EmailInputFieldFb3(inputController: emailController),
              PasswordInput(
                hintText: "Senha",
                textEditingController: senhaController, controller: senhaController,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: rememberMe,
                    onChanged: (value) {
                      setState(() {
                        rememberMe = value!;
                      });
                    },
                  ),
                  const Text('Lembre-se de mim'),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      // Lógica para enviar email de redefinição de senha
                      // ...
                    },
                    child: const Text('Esqueceu a senha?'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: performLogin,
                child: const Text('Entrar'),
              ),
              const SizedBox(height: 30),
              TextButton(
                onPressed: () {
                  // Lógica para navegar para a tela de registro ou inscrição
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CadastroPage()),
                  );
                },
                child: const Text('Não tem a senha? Inscreva-se!'),
              ),
              const SizedBox(height: 30),
              SingleChildScrollView(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GoogleBtn1(onPressed: () {}),
                    FacebookBtn1(onPressed: () {}),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}