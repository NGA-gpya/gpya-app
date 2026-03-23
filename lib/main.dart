import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/src/routing/app_router.dart';
import 'package:myapp/src/features/settings/theme_provider.dart';
import 'dart:developer' as developer;

void main() {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Credenciales de Supabase (hardcoded para garantizar funcionamiento en CI/CD y producción)
      const supabaseUrl = 'https://ifbmzqzxvogewkekapcv.supabase.co';
      const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlmYm16cXp4dm9nZXdrZWthcGN2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk1MzAwMjQsImV4cCI6MjA4NTEwNjAyNH0.K3DZB5QmLs-HnkAz5dkokUkHODzXj-CUW2MN8gMHqgs';

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
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
