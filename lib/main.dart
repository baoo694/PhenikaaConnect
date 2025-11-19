import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'constants/app_theme.dart';
import 'screens/auth_wrapper.dart';
import 'config/supabase_config.dart';
import 'services/group_reminder_service.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  GroupReminderService.initialize(rootScaffoldMessengerKey);
  
  runApp(const PhenikaaConnectApp());
}

class PhenikaaConnectApp extends StatelessWidget {
  const PhenikaaConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider()..initialize(),
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return MaterialApp(
            title: 'Phenikaa Connect',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appProvider.themeMode,
            scaffoldMessengerKey: rootScaffoldMessengerKey,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}