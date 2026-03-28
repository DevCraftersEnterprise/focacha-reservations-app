import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
// import 'router/app_router.dart';

class ReservationApp extends ConsumerWidget {
  const ReservationApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: authState.when(
        data: (session) {
          if (session == null) {
            return const LoginPage();
          }

          return const DashboardPage();
        },
        loading: () => _AppBootLoader(),
        error: (_, _) => const LoginPage(),
      ),
    );
  }
}

class _AppBootLoader extends StatelessWidget {
  const _AppBootLoader();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
