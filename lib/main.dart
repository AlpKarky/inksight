import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inksight/repositories/analysis_history_repository.dart';
import 'package:inksight/repositories/analysis_history_repository_local.dart';
import 'package:inksight/repositories/analysis_repository.dart';
import 'package:inksight/repositories/analysis_repository_ai.dart';
import 'package:inksight/screens/home_screen.dart';
import 'package:inksight/services/analysis_service.dart';
import 'package:inksight/services/storage_service.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => AnalysisService()),
        Provider(
          create: (context) => AnalysisRepositoryAi(
            analysisService: context.read(),
          ) as AnalysisRepository,
        ),
        Provider(create: (_) => StorageService()),
        Provider(
          create: (context) => AnalysisHistoryRepositoryLocal(
            storageService: context.read(),
          ) as AnalysisHistoryRepository,
        ),
      ],
      child: MaterialApp(
        title: 'InkSight',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
