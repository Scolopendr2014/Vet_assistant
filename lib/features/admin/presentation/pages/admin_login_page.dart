import 'package:flutter/material.dart';

class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Вход администратора'),
      ),
      body: const Center(
        child: Text('Вход администратора (будет реализовано)'),
      ),
    );
  }
}
