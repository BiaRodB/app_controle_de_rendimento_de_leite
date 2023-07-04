//import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class RendPage extends StatefulWidget {
  const RendPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RendPageState createState() => _RendPageState();
}

class _RendPageState extends State<RendPage> {
  final TextEditingController diaController = TextEditingController();
  final TextEditingController rendimentoController = TextEditingController();
  void cadastrarRendimento(BuildContext context) async {
  final data = diaController.text; // Obter a data do TextFormField
  final rendimento = double.parse(rendimentoController.text); // Obter o rendimento do TextFormField

  final response = await http.post(
    Uri.parse('http://10.0.0.108:8000/rendimento/'), // Atualize com a URL correta da sua API local
    body: {
      'dia': data,
      'rend': rendimento.toString(),
    },
  );

  if (response.statusCode == 201) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rendimento cadastrado com sucesso!'),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Falha ao cadastrar o rendimento.'),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rendimento de leite do dia'),
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
            ],
          ),
        ),
      ),
    );
  }
}
class RendimentoD {
  int? id;
  DateTime dia;
  double rend;
 

  RendimentoD({this.id, required this.dia, required this.rend});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dia': dia,
      'rend': rend,
      
      
    };
  }

  factory RendimentoD.fromMap(Map<String, dynamic> map) {
    return RendimentoD(
      id: map['id'],
      dia: map['data'],
      rend: map['rendimento'],
      
    );
  }
   List<Object?> get props => [id];
}
