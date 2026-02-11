import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart' show Reference;
import '../../../../core/di/di_container.dart';
import '../../../references/domain/reference_repository.dart';

/// Управление справочниками (VET-033). Список по типу, добавление и удаление.
class ReferencesListPage extends ConsumerStatefulWidget {
  final String? type;

  const ReferencesListPage({super.key, this.type});

  @override
  ConsumerState<ReferencesListPage> createState() => _ReferencesListPageState();
}

class _ReferencesListPageState extends ConsumerState<ReferencesListPage> {
  static const List<String> _referenceTypes = [
    'species',
    'rhythm',
    'murmurs',
  ];
  String _selectedType = 'species';

  @override
  void initState() {
    super.initState();
    if (widget.type != null && _referenceTypes.contains(widget.type)) {
      _selectedType = widget.type!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Справочники'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Тип справочника',
                border: OutlineInputBorder(),
              ),
              items: _referenceTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedType = v);
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Reference>>(
              future: getIt<ReferenceRepository>().getByType(_selectedType),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = snapshot.data ?? [];
                if (list.isEmpty) {
                  return const Center(
                    child: Text('Нет записей. Нажмите + чтобы добавить.'),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(context).padding.bottom + 24,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final r = list[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(r.label),
                        subtitle: Text(r.key),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _delete(r.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReference,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addReference() async {
    final keyController = TextEditingController();
    final labelController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Новое значение'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'Ключ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: labelController,
              decoration: const InputDecoration(
                labelText: 'Подпись',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final key = keyController.text.trim();
    final label = labelController.text.trim();
    if (key.isEmpty || label.isEmpty) return;
    try {
      await getIt<ReferenceRepository>().add(_selectedType, key, label);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Добавлено')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  Future<void> _delete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Нет'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Да'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await getIt<ReferenceRepository>().delete(id);
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }
}
