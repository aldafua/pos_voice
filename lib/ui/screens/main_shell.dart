import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/sale_provider.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'pos_screen.dart';
import 'products_screen.dart';

class _TabSpec {
  const _TabSpec(this.label, this.icon, this.selectedIcon, this.page);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;
}

/// Kerangka utama dengan bottom navigation.
/// Kasir: Beranda, Kasir, Riwayat. Admin: ditambah tab Produk.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProductProvider>().load();
      final sales = context.read<SaleProvider>();
      sales.loadToday();
      sales.loadHistory(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;
    final tabs = <_TabSpec>[
      _TabSpec('Beranda', Icons.home_outlined, Icons.home,
          HomeScreen(onStartTransaction: () => setState(() => _index = 1))),
      const _TabSpec('Kasir', Icons.point_of_sale_outlined, Icons.point_of_sale, PosScreen()),
      if (isAdmin)
        const _TabSpec('Produk', Icons.inventory_2_outlined, Icons.inventory_2, ProductsScreen()),
      const _TabSpec('Riwayat', Icons.receipt_long_outlined, Icons.receipt_long, HistoryScreen()),
    ];
    if (_index >= tabs.length) _index = 0;

    return Scaffold(
      body: IndexedStack(index: _index, children: tabs.map((t) => t.page).toList()),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: tabs
            .map((t) => NavigationDestination(
                  icon: Icon(t.icon),
                  selectedIcon: Icon(t.selectedIcon),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}
