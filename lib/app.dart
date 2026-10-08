import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routes.dart';
import 'core/theme.dart';
import 'data/models/product.dart';
import 'data/models/sale.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/product_repository.dart';
import 'data/repositories/sale_repository.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'providers/sale_provider.dart';
import 'services/voice_service.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/main_shell.dart';
import 'ui/screens/payment_screen.dart';
import 'ui/screens/product_form_screen.dart';
import 'ui/screens/receipt_screen.dart';

class PosVoiceApp extends StatelessWidget {
  const PosVoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthRepository())),
        ChangeNotifierProvider(create: (_) => ProductProvider(ProductRepository())),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => SaleProvider(SaleRepository())),
        Provider<VoiceService>(
          create: (_) => VoiceService(),
          dispose: (_, service) => service.cancel(),
        ),
      ],
      child: MaterialApp(
        title: 'POS Voice',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        initialRoute: Routes.login,
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.login:
        return MaterialPageRoute(settings: settings, builder: (_) => const LoginScreen());
      case Routes.home:
        return MaterialPageRoute(settings: settings, builder: (_) => const MainShell());
      case Routes.payment:
        return MaterialPageRoute(settings: settings, builder: (_) => const PaymentScreen());
      case Routes.receipt:
        final sale = settings.arguments as Sale;
        return MaterialPageRoute(settings: settings, builder: (_) => ReceiptScreen(sale: sale));
      case Routes.productForm:
        final product = settings.arguments as Product?;
        return MaterialPageRoute(settings: settings, builder: (_) => ProductFormScreen(product: product));
    }
    return null;
  }
}
