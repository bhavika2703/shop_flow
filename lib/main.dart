import 'package:flutter/material.dart';
import 'package:shop_flow/src/features/auth/presentation/app.dart';

import 'src/di/injection.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const ShopFlowApp());
}
