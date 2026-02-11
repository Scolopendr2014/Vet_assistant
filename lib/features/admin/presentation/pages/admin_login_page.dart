import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Вход администратора (ТЗ 4.6.1). Заглушка: пароль "admin".
class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _controller = TextEditingController();
  String? _error;

  static const _stubPassword = 'admin';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Вход администратора'),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Пароль',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _login(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _login,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Войти'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _login() {
    if (_controller.text.trim() == _stubPassword) {
      setState(() => _error = null);
      context.go('/admin/dashboard');
    } else {
      setState(() => _error = 'Неверный пароль');
    }
  }
}
