import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/src/routing/app_router.dart';
import 'package:myapp/src/features/settings/theme_provider.dart';
import 'dart:developer' as developer;

void main() {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Intentar cargar .env (opcional, para desarrollo local)
      try {
        await dotenv.load(fileName: ".env");
      } catch (e) {
        developer.log(
          '.env file not found, using dart-define variables',
          name: 'main',
        );
      }

      // Prioridad: .env > --dart-define > vacío
      const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
      const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

      final url = dotenv.env['SUPABASE_URL'] ?? 
          (supabaseUrl.isNotEmpty ? supabaseUrl : '');
      final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 
          (supabaseAnonKey.isNotEmpty ? supabaseAnonKey : '');

      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );

      runApp(const ProviderScope(child: MyApp()));
    },
    (error, stack) {
      developer.log(
        'Error fatal no controlado',
        name: 'main',
        error: error,
        stackTrace: stack,
      );
    },
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    const accentRed = Color(0xFFD32F2F);

    final lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.white,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      colorScheme: ColorScheme.light(
        primary: accentRed,
        secondary: accentRed,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black87,
        error: Colors.redAccent,
      ),
      textTheme: GoogleFonts.montserratTextTheme(ThemeData.light().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black87,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.black87,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: accentRed,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
      ),
    );

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF1A1A1A),
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      colorScheme: ColorScheme.dark(
        primary: accentRed,
        secondary: accentRed,
        surface: Colors.grey[850]!,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white70,
        error: Colors.redAccent,
      ),
      textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1A1A1A),
        selectedItemColor: accentRed,
        unselectedItemColor: Colors.grey[500],
        type: BottomNavigationBarType.fixed,
      ),
    );

    return MaterialApp.router(
      title: 'GPYA',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
