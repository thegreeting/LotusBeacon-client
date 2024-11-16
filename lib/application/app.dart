import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotusbeacon/presentation/page/debug_page.dart';
import 'package:lotusbeacon/presentation/page/home_page.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const themeMode = ThemeMode.system; //ref.watch(themeProvider);

    return MaterialApp(
      title: 'Meissa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeMode,
      routes: {
        '/home': (context) => const HomePage(),
        '/debug': (context) => const DebugPage(),
      },
      initialRoute: '/home',
    );
  }
}
