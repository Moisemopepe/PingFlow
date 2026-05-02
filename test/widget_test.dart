import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pingflow/app/pingflow_app.dart';
import 'package:pingflow/app/navigation/app_shell.dart';
import 'package:pingflow/core/i18n/app_strings.dart';
import 'package:pingflow/core/models/diagnostic_models.dart';
import 'package:pingflow/core/services/diagnostic_service.dart';
import 'package:pingflow/core/services/history_repository.dart';
import 'package:pingflow/core/services/settings_repository.dart';
import 'package:pingflow/features/settings/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('PingFlow starts bootstrapping', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const PingFlowApp());

    expect(find.byType(PingFlowApp), findsOneWidget);
  });

  testWidgets('language changes immediately from settings',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'language_code': 'en'});
    final settingsRepository = SettingsRepository();
    await settingsRepository.load();

    await tester.pumpWidget(
      AppDependencies(
        diagnosticService: _FakeDiagnosticService(),
        historyRepository: HistoryRepository(),
        settingsRepository: settingsRepository,
        child: ListenableBuilder(
          listenable: settingsRepository,
          builder: (context, _) {
            return MaterialApp(
              locale: settingsRepository.locale,
              supportedLocales: AppStrings.supportedLocales,
              localizationsDelegates: const [
                AppStrings.localizationsDelegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              home: const SettingsScreen(),
            );
          },
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Language'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('French').last);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Parametres'), findsOneWidget);
    expect(find.text('Langue'), findsOneWidget);
    expect(find.text('Francais'), findsOneWidget);
  });

  testWidgets('dashboard rebuilds when language changes',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'language_code': 'en'});
    final settingsRepository = SettingsRepository();
    await settingsRepository.load();

    await tester.pumpWidget(
      AppDependencies(
        diagnosticService: _FakeDiagnosticService(),
        historyRepository: HistoryRepository(),
        settingsRepository: settingsRepository,
        child: ListenableBuilder(
          listenable: settingsRepository,
          builder: (context, _) {
            return MaterialApp(
              locale: settingsRepository.locale,
              supportedLocales: AppStrings.supportedLocales,
              localizationsDelegates: const [
                AppStrings.localizationsDelegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              home: const AppShell(),
            );
          },
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Network\nDiagnostic\nMade Simple'), findsOneWidget);

    await settingsRepository.setLanguageCode('fr');
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Diagnostic\nReseau\nSimplifie'), findsOneWidget);
    expect(find.text('Network\nDiagnostic\nMade Simple'), findsNothing);
    expect(find.text('Accueil'), findsOneWidget);
  });
}

class _FakeDiagnosticService implements DiagnosticService {
  @override
  Future<NetworkInfo> networkInfo() async {
    return const NetworkInfo(
      localIp: '-',
      publicIp: '-',
      dns: '-',
      gateway: '-',
      networkType: '-',
      signal: '-',
      subnetMask: '-',
      backendStatus: '-',
    );
  }

  @override
  Stream<PingReply> ping(String host, {int count = 10}) {
    return const Stream.empty();
  }

  @override
  Future<SpeedResult> speedTest() async {
    return const SpeedResult(
      downloadMbps: 0,
      uploadMbps: 0,
      pingMs: 0,
      jitterMs: 0,
    );
  }

  @override
  Stream<SpeedProgress> speedTestStream() {
    return const Stream.empty();
  }

  @override
  Stream<TraceHop> traceroute(String host) {
    return const Stream.empty();
  }
}
