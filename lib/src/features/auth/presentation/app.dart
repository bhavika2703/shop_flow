import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_flow/src/features/auth/presentation/pages/home_page.dart';
import 'package:shop_flow/src/features/auth/presentation/pages/login_page.dart';
import 'package:shop_flow/src/features/auth/presentation/pages/splash_page.dart';

import '../../../di/injection.dart' as di;
import 'bloc/auth_bloc.dart';

class ShopFlowApp extends StatelessWidget {
  const ShopFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  BlocProvider<AuthBloc>.value(
      value: di.sl<AuthBloc>(),
      child: MaterialApp(
        title: 'ShopFlow',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const SplashPage(),
        routes: {
          '/login': (_) => const LoginPage(),
          '/home': (_) => const HomePage(),
        },
      ),
    );
  }
}
