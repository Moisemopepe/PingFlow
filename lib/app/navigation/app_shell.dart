import 'package:flutter/material.dart';

import '../../app/pingflow_app.dart';
import '../../core/i18n/app_strings.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/tools/tools_screen.dart';
import 'pingflow_drawer.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final settings = AppDependencies.of(context).settingsRepository;
    return Scaffold(
      key: _scaffoldKey,
      drawer: const PingFlowDrawer(),
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) {
          final languageCode = settings.languageCode;
          return IndexedStack(
            key: ValueKey(languageCode),
            index: _index,
            children: [
              DashboardScreen(
                key: ValueKey('dashboard-$languageCode'),
                onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              ToolsScreen(key: ValueKey('tools-$languageCode')),
              HistoryScreen(key: ValueKey('history-$languageCode')),
              SettingsScreen(key: ValueKey('settings-$languageCode')),
            ],
          );
        },
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: settings,
        builder: (context, _) {
          final strings = AppStrings.of(context);
          return BottomNavigationBar(
            currentIndex: _index,
            onTap: (value) => setState(() => _index = value),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_rounded),
                label: strings.home,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.construction_rounded),
                label: strings.tools,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.history_rounded),
                label: strings.history,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings_rounded),
                label: strings.settings,
              ),
            ],
          );
        },
      ),
    );
  }
}
