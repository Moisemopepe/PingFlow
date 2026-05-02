import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/i18n/app_strings.dart';
import '../core/services/diagnostic_service.dart';
import '../core/services/history_repository.dart';
import '../core/services/settings_repository.dart';
import 'navigation/app_shell.dart';
import 'theme/app_theme.dart';

class PingFlowApp extends StatefulWidget {
  const PingFlowApp({super.key});

  @override
  State<PingFlowApp> createState() => _PingFlowAppState();
}

class _PingFlowAppState extends State<PingFlowApp> {
  late final DiagnosticService diagnosticService;
  late final HistoryRepository historyRepository;
  late final SettingsRepository settingsRepository;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    diagnosticService = RealDiagnosticService();
    historyRepository = HistoryRepository();
    settingsRepository = SettingsRepository();
    _load();
  }

  Future<void> _load() async {
    await Future.wait([
      historyRepository.load(),
      settingsRepository.load(),
    ]);
    if (mounted) setState(() => _loaded = true);
  }

  @override
  Widget build(BuildContext context) {
    return AppDependencies(
      diagnosticService: diagnosticService,
      historyRepository: historyRepository,
      settingsRepository: settingsRepository,
      child: ListenableBuilder(
        listenable: settingsRepository,
        builder: (context, _) {
          return MaterialApp(
            title: 'PingFlow',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settingsRepository.themeMode,
            locale: settingsRepository.locale,
            supportedLocales: AppStrings.supportedLocales,
            localizationsDelegates: const [
              AppStrings.localizationsDelegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            home: _loaded
                ? const AppShell()
                : const Scaffold(
                    body: Center(child: CircularProgressIndicator())),
          );
        },
      ),
    );
  }
}

class AppDependencies extends InheritedWidget {
  const AppDependencies({
    required this.diagnosticService,
    required this.historyRepository,
    required this.settingsRepository,
    required super.child,
    super.key,
  });

  final DiagnosticService diagnosticService;
  final HistoryRepository historyRepository;
  final SettingsRepository settingsRepository;

  static AppDependencies of(BuildContext context) {
    final dependencies =
        context.dependOnInheritedWidgetOfExactType<AppDependencies>();
    assert(dependencies != null, 'AppDependencies not found in widget tree');
    return dependencies!;
  }

  @override
  bool updateShouldNotify(AppDependencies oldWidget) {
    return diagnosticService != oldWidget.diagnosticService ||
        historyRepository != oldWidget.historyRepository ||
        settingsRepository != oldWidget.settingsRepository;
  }
}
