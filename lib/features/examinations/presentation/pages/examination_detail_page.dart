import 'package:flutter/material.dart';

class ExaminationDetailPage extends StatelessWidget {
  final String examinationId;
  
  const ExaminationDetailPage({super.key, required this.examinationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Протокол осмотра'),
      ),
      body: Center(
        child: Text('Детали протокола: $examinationId (будет реализовано)'),
      ),
    );
  }
}
