import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vaca_leiteira/cadvaca.dart';
import 'dart:convert';
import 'menu.dart' as menu;
import 'widgets/callgoogle.dart';
import 'widgets/callfacebook.dart';
import 'widgets/inputsfield.dart';
import 'cadastro.dart';

export 'package:flutter/material.dart'; // Importação necessária para exportar a classe Material do Flutter

class LoginPage extends StatefulWidget {
  static String email = '';
  static int? userId;

  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController senhaController = TextEditingController();

  Future<void> performLogin() async {
    if (!mounted) {
      return;
    }

    String email = emailController.text.trim();
    String senha = senhaController.text.trim();

    // Replace 'http://192.168.66.32:8000' with the appropriate API URL
    Uri apiUrl = Uri.parse('http://192.168.18.8:8000/pessoa/');
    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      List<dynamic> users = json.decode(response.body);
      bool isAuthenticated = false;

      for (var user in users) {
        if (user['email'] == email && user['senha'] == senha) {
          isAuthenticated = true;
          setState(() {
            LoginPage.userId = user['id']; // Update the userId variable
          });
          break;
        }
      }

      if (isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Login realizado com sucesso!',
              style: TextStyle(color: Colors.green),
            ),
            duration: Duration(seconds: 2),
          ),
        );
        LoginPage.email = email; // Assign the value of 'nome' to the static variable in the LoginPage class
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const menu.MenuPage()),
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Erro de Login'),
              content: Text('Usuário ou senha inválidos.'),
              actions: [
                TextButton(
                  child: Text('OK'),
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
            title: Text('Erro de Login'),
            content: Text('Não foi possível acessar a API.'),
            actions: [
              TextButton(
                child: Text('OK'),
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
              Image.asset(
          'assets/images/user.png', // Insira o caminho da imagem
          width: 600,
          height: 600, 
        ),
              EmailInputFieldFb3(inputController: emailController),
              PasswordInput(
                hintText: "Senha",
                textEditingController: senhaController,
                controller: senhaController,
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
                    MaterialPageRoute(builder: (context) =>  CadastroPage()),
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
