import 'package:flutter/material.dart';

class PatientsListPage extends StatelessWidget {
  const PatientsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Пациенты'),
      ),
      body: const Center(
        child: Text('Список пациентов (будет реализовано)'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Навигация к созданию пациента
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
