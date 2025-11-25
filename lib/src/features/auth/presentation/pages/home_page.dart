
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../di/injection.dart' as di;
import '../../../product/presentation/bloc/product_bloc.dart' show ProductBloc, FetchProducts;
import '../../../product/presentation/pages/product_list_page.dart';
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
            title: Text(title,style: TextStyle(fontWeight: FontWeight.bold),),
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
          body: BlocProvider<ProductBloc>(
            create: (_) => di.sl<ProductBloc>()..add(FetchProducts()),
        child: const ProductListPage(),
        ),

        );
      },
    );
  }
}
