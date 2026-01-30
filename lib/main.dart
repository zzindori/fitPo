import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/datasources/local/hive_data_source.dart';
import 'domain/providers/analysis_provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화
  final hiveDataSource = HiveDataSource();
  await hiveDataSource.init();

  runApp(
    ProviderScope(
      overrides: [
        // HiveDataSource를 ProviderScope에 주입
        hiveDataSourceProvider.overrideWithValue(hiveDataSource),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '패션 평가',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
