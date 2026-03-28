import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsetsGeometry.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.loginTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pantalla base de login',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Correo'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(onPressed: () {}, child: const Text('Entrar')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
