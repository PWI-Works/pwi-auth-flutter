import 'package:flutter/material.dart';
import 'package:pwi_auth/core/default_global_controller.dart';
import 'package:pwi_auth/widgets/loading_page.dart';
import 'mock_pwi_auth.dart';

void main() {
  DefaultGlobalController(
    appTitle: 'Flutter Demo',
    auth: MockPwiAuth(),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final global = DefaultGlobalController.instance;
    return MaterialApp(
      title: global.appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MyHomePage(title: global.appTitle),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: LoadingPage(initialMessage: 'Loading...'),
    );
  }
}
