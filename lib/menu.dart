import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vaca_leiteira/rendimento.dart';
import 'package:vaca_leiteira/widgets/calldown.dart';
import 'cadvaca.dart';
import 'login.dart' as login;
import 'login.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Vaca> vacas = [];
  int? userId;

  Future<void> fetchVacas() async {
    userId = login.LoginPage.userId;

    final vacasResponse = await http.get(Uri.parse('http://192.168.18.8:8000/vaca/?usuario=$userId'));

    if (vacasResponse.statusCode == 200) {
      final List<dynamic> vacasJson = jsonDecode(vacasResponse.body);

      final List<Vaca> fetchedVacas = vacasJson.map((item) {
        return Vaca(
          id: item['id'],
          nome: item['nome'],
          raca: item['raca'],
          idade: item['idade'],
          peso: item['kg'].toDouble(),
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

  Future<void> deleteVaca(int vacaId) async {
    final url = Uri.parse('http://192.168.18.8:8000/vaca/$vacaId/');

    final response = await http.delete(url);

    if (response.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vaca excluída com sucesso.'),
        ),
      );
      fetchVacas();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha ao excluir a vaca.'),
        ),
      );
    }
  }

  Future<bool?> showDeleteConfirmationDialog(int vacaId) {
    return showDialog<bool?>(

      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmação'),
          content: Text('Tem certeza de que deseja excluir esta vaca?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(false); // Retorna false para indicar que a exclusão foi cancelada
              },
            ),
            TextButton(
              child: Text('Excluir'),
              onPressed: () {
                Navigator.of(context).pop(true); // Retorna true para indicar que a exclusão foi confirmada
              },
            ),
          ],
        );
      },
    );
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
  title: const Text('Menu de Vacas Cadastradas'),
  backgroundColor: Colors.green[300],
  automaticallyImplyLeading: false,
  actions: [
    IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () {
         Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  LoginPage()),
                  );
      },
    ),
  ],
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
                    return Card(
                      child: ListTile(
                        title: Text('Nome: ${vaca.nome}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Raça: ${vaca.raca}'),
                            Text('Idade: ${vaca.idade}'),
                            Text('Peso: ${vaca.peso}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete,size: 30, color: Color.fromARGB(255, 165, 6, 6),),
                          onPressed: () async {
                            bool? deleteConfirmed = await showDeleteConfirmationDialog(vaca.id);
                            if (deleteConfirmed == true) {
                              deleteVaca(vaca.id);
                            }
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => VacaDetailsPage(vaca: vaca)),
                          );
                        },
                        
                      ),
                    );
                  }).toList(),
               ),
               ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CadastroPageV()),
                  );
                },
                child: Icon(Icons.add),
              ),   ],
          ),
     ),
       ),
    );
  }
}

class VacaDetailsPage extends StatelessWidget {
  final Vaca vaca;

  const VacaDetailsPage({Key? key, required this.vaca}) : super(key: key);

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

            const SizedBox(height: 10),
              ElevatedButton(
               onPressed: () {
               Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => RendPage(vacaId: vaca.id)),
      );
    },
    child: const Text('Cadastrar Rendimentos'),
),
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

  Vaca({
    required this.id,
    required this.nome,
    required this.raca,
    required this.idade,
    required this.peso,
  });

  factory Vaca.fromJson(Map<String, dynamic> json) {
    final pesoString = json['peso'].toString();
    final peso = double.parse(pesoString.contains('.') ? pesoString.replaceAll(RegExp(r"0*$"), '') : pesoString);

    return Vaca(
      id: json['id'],
      nome: json['nome'],
      raca: json['raca'],
      idade: json['idade'],
      peso: peso,
    );
  }

  get rendimentos => null;
}
