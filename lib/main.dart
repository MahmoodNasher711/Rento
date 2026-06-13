import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

// Data Layer
import 'package:rento/data/repository/auth_repository.dart';
import 'package:rento/data/repository/firestore_apartment_repository.dart';
import 'package:rento/data/models/tenant_model.dart';

// Domain Layer
import 'package:rento/domain/cubit/apartment_cubit.dart';
import 'package:rento/domain/cubit/expense_cubit.dart';
import 'package:rento/domain/cubit/tenant_cubit.dart';
import 'package:rento/domain/cubit/payment_cubit.dart';
import 'package:rento/domain/cubit/contract_cubit.dart';
import 'package:rento/data/repository/firestore_tenant_repository.dart';
import 'package:rento/data/repository/firestore_expense_repository.dart';
import 'package:rento/data/repository/firestore_payment_repository.dart';
import 'package:rento/data/repository/firestore_contract_repository.dart';

// Presentation Layer
import 'package:rento/presentation/screen/apartments/apartments_screen.dart';
import 'package:rento/presentation/screen/dashboard_screen.dart';
import 'package:rento/presentation/screen/expenses/expenses_screen.dart';
import 'package:rento/presentation/screen/payments/payments_screen.dart';
import 'package:rento/presentation/screen/reports/reports_screen.dart';
import 'package:rento/presentation/screen/settings/settings_screen.dart';
import 'package:rento/presentation/screen/tenants/tenant_details_screen.dart';
import 'package:rento/presentation/screen/tenants/tenants_screen.dart';
import 'package:rento/presentation/screen/search/search_screen.dart';
import 'package:rento/presentation/screen/profile/profile_screen.dart';
import 'package:rento/presentation/widget/smart_fab.dart';

// Utilities
import 'package:rento/utils/theme/app_theme.dart';
import 'package:rento/utils/theme/theme_provider.dart';
import 'package:rento/constants/app_colors.dart';
import 'package:rento/presentation/screen/splash_screen.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rento/domain/cubit/auth_cubit.dart';
import 'package:rento/domain/cubit/profile_cubit.dart';
import 'package:rento/presentation/screen/auth/login_screen.dart';
import 'package:rento/presentation/screen/auth/onboarding_screen.dart';
import 'package:rento/presentation/screen/auth/verify_email_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Enable Offline Persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  await initializeDateFormatting('ar', null);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final authRepository = AuthRepository();

  runApp(
    MultiProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<FirestoreApartmentRepository>(
            create: (_) => FirestoreApartmentRepository()),
        RepositoryProvider<FirestoreTenantRepository>(
            create: (context) => FirestoreTenantRepository()),
        RepositoryProvider<FirestorePaymentRepository>(
            create: (context) => FirestorePaymentRepository()),
        RepositoryProvider<FirestoreContractRepository>(
            create: (context) => FirestoreContractRepository()),
        RepositoryProvider<FirestoreExpenseRepository>(
            create: (context) => FirestoreExpenseRepository()),

        // Cubits
        BlocProvider(
          create: (context) => AuthCubit(
            authRepository: context.read<AuthRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => ProfileCubit(
            authRepository: context.read<AuthRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => ApartmentCubit(
            context.read<FirestoreApartmentRepository>(),
          )..loadApartments(),
        ),
        BlocProvider(
          create: (context) =>
          TenantCubit(context.read<FirestoreTenantRepository>())..loadTenants(),
        ),
        BlocProvider(
          create: (context) =>
          PaymentCubit(context.read<FirestorePaymentRepository>())..loadPayments(),
        ),
        BlocProvider(
          create: (context) =>
          ExpenseCubit(context.read<FirestoreExpenseRepository>())..loadExpenses(),
        ),
        BlocProvider(
          create: (context) =>
          ContractCubit(context.read<FirestoreContractRepository>())..loadContracts(),
        ),

        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const RentoApp(),
    ),
  );
}

class RentoApp extends StatelessWidget {
  const RentoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Rento — إدارة العقارات',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeProvider.themeMode,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: (settings) => _generateRoute(settings),
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.verifyEmail:
        return MaterialPageRoute(builder: (_) => const VerifyEmailScreen());
      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const MainNavigationScreen());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case AppRoutes.tenantDetails:
        final tenant = settings.arguments as TenantModel;
        return MaterialPageRoute(
          builder: (_) => TenantDetailsScreen(tenant: tenant),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
                  const SizedBox(height: 16),
                  const Text('الصفحة غير موجودة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('عذراً، لم يتم العثور على الصفحة المطلوبة.'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard),
                    child: const Text('العودة للرئيسية'),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String verifyEmail = '/verify-email';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String tenantDetails = '/tenant-details';
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // 5 main screens
  final List<Widget> _screens = const [
    DashboardScreen(),
    TenantsScreen(),
    PaymentsScreen(),
    ReportsScreen(),
    _MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDash = _currentIndex == 0;
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: isDash ? SmartFAB() : null,
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

  NavigationBar _buildNavigationBar() {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) => setState(() => _currentIndex = index),
      animationDuration: const Duration(milliseconds: 300),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'الرئيسية',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outlined),
          selectedIcon: Icon(Icons.people),
          label: 'المستأجرون',
        ),
        NavigationDestination(
          icon: Icon(Icons.payments_outlined),
          selectedIcon: Icon(Icons.payments),
          label: 'الإيجارات',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: 'التقارير',
        ),
        NavigationDestination(
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view),
          label: 'المزيد',
        ),
      ],
    );
  }
}

// More screen — shows remaining screens as a grid
class _MoreScreen extends StatelessWidget {
  const _MoreScreen();

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(title: const Text('المزيد')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: [
          _MoreItem(
            icon: Icons.home_work_rounded,
            label: 'الشقق',
            color: AppColors.info,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ApartmentsScreen()),
            ),
          ),
          _MoreItem(
            icon: Icons.search_rounded,
            label: 'البحث',
            color: AppColors.primary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          _MoreItem(
            icon: Icons.money_off_rounded,
            label: 'المصاريف',
            color: AppColors.secondary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ExpensesScreen()),
            ),
          ),
          _MoreItem(
            icon: Icons.person_rounded,
            label: 'الملف الشخصي',
            color: AppColors.primaryDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          _MoreItem(
            icon: Icons.settings_rounded,
            label: 'الإعدادات',
            color: AppColors.greyDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MoreItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
