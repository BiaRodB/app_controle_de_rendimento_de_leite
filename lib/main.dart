import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';
import 'login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: SplashPage(),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        //'/': (context) => SplashFuturePage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State {
  @override
  Widget build(BuildContext context) {
    return EasySplashScreen(
      
      logo: Image.asset(
          'assets/images/vaca.jpg', // Insira o caminho da imagem
          width: 600,
          height: 600,
          
        ),
      title: Text('Vaca Leiteira'),
      backgroundColor: Colors.green,
      
      showLoader: true,
      loadingText: const Text("Loading..."),
      navigator: const LoginPage(),
      durationInSeconds: 5,
    );
  }
}