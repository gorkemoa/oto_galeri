import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:oto_galeri/app/app_theme.dart';
import 'package:oto_galeri/core/responsive/size_config.dart';
import 'package:oto_galeri/core/responsive/size_tokens.dart';
import 'package:oto_galeri/views/home/home_view.dart';
import 'package:oto_galeri/views/vehicles/vehicles_view.dart';
import 'package:oto_galeri/views/expenses/expenses_view.dart';
import 'package:oto_galeri/views/reports/reports_view.dart';
import 'package:oto_galeri/views/profile/profile_view.dart';
import 'package:provider/provider.dart';
import 'package:oto_galeri/viewmodels/dashboard_view_model.dart';
import 'package:oto_galeri/viewmodels/vehicles_view_model.dart';
import 'package:oto_galeri/viewmodels/expenses_view_model.dart';
import 'package:oto_galeri/viewmodels/reports_view_model.dart';
import 'package:oto_galeri/viewmodels/profile_view_model.dart';
import 'package:oto_galeri/viewmodels/vehicle_add_view_model.dart';
import 'package:oto_galeri/viewmodels/expense_add_view_model.dart';
import 'package:oto_galeri/viewmodels/vehicle_sale_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR');
  runApp(const OtoGaleriApp());
}

class OtoGaleriApp extends StatelessWidget {
  const OtoGaleriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => VehiclesViewModel()),
        ChangeNotifierProvider(create: (_) => VehicleAddViewModel()),
        ChangeNotifierProvider(create: (_) => ExpenseAddViewModel()),
        ChangeNotifierProvider(create: (_) => VehicleSaleViewModel()),
        ChangeNotifierProvider(create: (_) => ExpensesViewModel()),
        ChangeNotifierProvider(create: (_) => ReportsViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ],
      child: MaterialApp(
        title: 'Oto Galeri',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('tr', 'TR'),
          Locale('en', 'US'),
        ],
        // Font Scaling Protection - zorunlu
        builder: (context, child) {
          // SizeConfig init
          SizeConfig.init(context);
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.noScaling,
            ),
            child: child!,
          );
        },
        home: const MainShell(),
      ),
    );
  }
}

/// MainShell - Bottom Navigation yapısı
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeView(),
    VehiclesView(),
    ExpensesView(),
    ReportsView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: SizeTokens.spacingLg,
              offset: Offset(0, -SizeTokens.spacingXs),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined, size: SizeTokens.iconMd),
              activeIcon: Icon(Icons.dashboard, size: SizeTokens.iconMd),
              label: 'Ana Sayfa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car_outlined, size: SizeTokens.iconMd),
              activeIcon: Icon(Icons.directions_car, size: SizeTokens.iconMd),
              label: 'Araçlar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined, size: SizeTokens.iconMd),
              activeIcon: Icon(Icons.receipt_long, size: SizeTokens.iconMd),
              label: 'Giderler',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined, size: SizeTokens.iconMd),
              activeIcon: Icon(Icons.bar_chart, size: SizeTokens.iconMd),
              label: 'Rapor',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: SizeTokens.iconMd),
              activeIcon: Icon(Icons.person, size: SizeTokens.iconMd),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
