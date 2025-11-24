
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../di/injection.dart' as di;
import '../bloc/auth_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/login');
          });
        }
      },
      builder: (context, state) {
        String title = 'ShopFlow';
        String subtitle = 'Welcome';
        if (state is AuthAuthenticated) {
          title = 'Hello, ${state.user.name}';
          subtitle = state.user.email;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              IconButton(
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutRequested());
                },
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 24),
                const Text('This is a placeholder Home screen for ShopFlow.'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // manual logout alternative
                    context.read<AuthBloc>().add(LogoutRequested());
                  },
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
