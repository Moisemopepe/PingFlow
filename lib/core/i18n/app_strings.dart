import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppStrings {
  const AppStrings(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('fr'),
  ];

  static const localizationsDelegate = _AppStringsDelegate();

  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings) ??
        const AppStrings(Locale('en'));
  }

  bool get isFrench => locale.languageCode == 'fr';

  String get appName => 'PingFlow';
  String get home => isFrench ? 'Accueil' : 'Home';
  String get tools => isFrench ? 'Outils' : 'Tools';
  String get history => isFrench ? 'Historique' : 'History';
  String get settings => isFrench ? 'Parametres' : 'Settings';
  String get menu => isFrench ? 'Menu' : 'Menu';
  String get premium => isFrench ? 'Premium' : 'Premium';
  String get general => isFrench ? 'General' : 'General';
  String get theme => isFrench ? 'Theme' : 'Theme';
  String get language => isFrench ? 'Langue' : 'Language';
  String get dark => isFrench ? 'Sombre' : 'Dark';
  String get light => isFrench ? 'Clair' : 'Light';
  String get english => isFrench ? 'Anglais' : 'English';
  String get french => isFrench ? 'Francais' : 'French';
  String get about => isFrench ? 'A propos' : 'About';
  String get aboutPingFlow =>
      isFrench ? 'A propos de PingFlow' : 'About PingFlow';
  String get privacyPolicy =>
      isFrench ? 'Politique de confidentialite' : 'Privacy Policy';
  String get shareApp => isFrench ? 'Partager l app' : 'Share App';
  String get version => isFrench ? 'Version' : 'Version';
  String get developer => isFrench ? 'Developpeur' : 'Developer';
  String get backend => isFrench ? 'API backend' : 'Backend';
  String get aboutDescription => isFrench
      ? 'PingFlow est un outil moderne de diagnostic reseau concu pour analyser la connectivite et les performances en temps reel.\n\nMesurez la latence (ping), visualisez les chemins reseau (traceroute), testez la vitesse de connexion et surveillez votre reseau facilement.'
      : 'PingFlow is a modern network diagnostic tool designed to analyze connectivity and performance in real time.\n\nMeasure latency (ping), visualize network paths (traceroute), test connection speed, and monitor network conditions with accuracy and ease.';
  String get features => isFrench ? 'Fonctionnalites' : 'Features';
  List<String> get featureItems => isFrench
      ? const [
          'Test de latence (Ping)',
          'Analyse de route (Traceroute)',
          'Test de debit',
          'Informations reseau',
          'Historique des tests',
        ]
      : const [
          'Ping (Latency Test)',
          'Traceroute (Route Analysis)',
          'Speed Test',
          'Network Information',
          'Test History',
        ];
  String get builtWithFlutter =>
      isFrench ? 'Developpe avec Flutter' : 'Built with Flutter';
  String get copyright => isFrench
      ? '© 2026 Moise Mopepe. Tous droits reserves.'
      : '© 2026 Moise Mopepe. All rights reserved.';
  String get shareAppText => isFrench
      ? 'Decouvrez PingFlow, un outil moderne de diagnostic reseau : https://play.google.com/store/apps/details?id=com.pingflow.app'
      : 'Check out PingFlow, a modern network diagnostic tool: https://play.google.com/store/apps/details?id=com.pingflow.app';
  String get privacyDescription => isFrench
      ? 'PingFlow respecte votre vie privee. L application ne collecte pas d informations personnelles. Les tests de diagnostic reseau sont effectues uniquement pour mesurer la connectivite, la latence, les sauts de route et la vitesse de connexion. Certains tests peuvent utiliser une API backend pour traiter les diagnostics reseau. Aucune donnee personnelle n est vendue ou partagee.'
      : 'PingFlow respects your privacy. The app does not collect personal information. Network diagnostic tests are performed only to measure connectivity, latency, route hops, and connection speed. Some tests may use a backend API to process network diagnostics. No personal data is sold or shared.';

  String get clearHistory => isFrench ? 'Effacer historique' : 'Clear history';
  String get deleteAllHistory =>
      isFrench ? 'Tout effacer ?' : 'Clear all history?';
  String get clearHistoryMessage => isFrench
      ? 'Cela supprime tous les resultats de diagnostic stockes localement.'
      : 'This removes all locally stored diagnostic results.';
  String get cancel => isFrench ? 'Annuler' : 'Cancel';
  String get clear => isFrench ? 'Effacer' : 'Clear';
  String get all => isFrench ? 'Tout' : 'All';
  String get speed => isFrench ? 'Vitesse' : 'Speed';
  String get noTestsMatch => isFrench
      ? 'Aucun test ne correspond a ce filtre.'
      : 'No tests match this filter.';
  String get recentTests => isFrench ? 'Tests recents' : 'Recent Tests';
  String get seeAll => isFrench ? 'Tout voir' : 'See All';
  String get justNow => isFrench ? 'A l instant' : 'Just now';

  String get ping => 'Ping';
  String get traceroute => 'Traceroute';
  String get networkInfo => isFrench ? 'Infos reseau' : 'Network Info';
  String get speedTest => isFrench ? 'Test de vitesse' : 'Speed Test';
  String get pingSubtitle => isFrench
      ? 'Tester la latence et la perte de paquets'
      : 'Test latency and packet loss';
  String get tracerouteSubtitle => isFrench
      ? 'Decouvrir le chemin vers un hote'
      : 'Discover the path to any host';
  String get networkInfoSubtitle =>
      isFrench ? 'Voir les details du reseau' : 'View detailed network info';
  String get speedTestSubtitle => isFrench
      ? 'Mesurer les performances internet'
      : 'Measure internet performance';
  String get toolsPingSubtitle => isFrench
      ? 'Mesurer la latence, la perte de paquets et la qualite de reponse.'
      : 'Measure latency, packet loss, and response quality.';
  String get toolsTracerouteSubtitle => isFrench
      ? 'Cartographier chaque saut entre cet appareil et une destination.'
      : 'Map each hop between this device and a destination.';
  String get toolsNetworkInfoSubtitle => isFrench
      ? 'Inspecter les adresses IP, DNS, passerelle et interface.'
      : 'Inspect IP addresses, DNS, gateway, and interface data.';
  String get toolsSpeedTestSubtitle => isFrench
      ? 'Tester le download, l upload, le ping et le jitter.'
      : 'Benchmark download, upload, ping, and jitter.';
  String get heroTitle => isFrench
      ? 'Diagnostic\nReseau\nSimplifie'
      : 'Network\nDiagnostic\nMade Simple';
  String get heroSubtitle => isFrench
      ? 'Tous les outils pour analyser et depanner votre reseau.'
      : 'All-in-one tools for network analysis and troubleshooting.';

  String get enterHost =>
      isFrench ? 'Entrer IP ou domaine' : 'Enter IP or domain';
  String get refresh => isFrench ? 'Actualiser' : 'Refresh';
  String get connected => isFrench ? 'Connecte' : 'Connected';
  String get signal => isFrench ? 'Signal' : 'Signal';
  String get interface => isFrench ? 'Interface' : 'Interface';
  String get ipAddresses => isFrench ? 'Adresses IP' : 'IP Addresses';
  String get networkDetails => isFrench ? 'Details reseau' : 'Network Details';
  String get localIp => isFrench ? 'IP locale' : 'Local IP';
  String get publicIp => isFrench ? 'IP publique' : 'Public IP';
  String get gateway => isFrench ? 'Passerelle' : 'Gateway';
  String get subnetMask => isFrench ? 'Masque de sous-reseau' : 'Subnet Mask';
  String get networkType => isFrench ? 'Type de reseau' : 'Network Type';
  String get backendApi => isFrench ? 'API backend' : 'Backend API';
  String get connection => isFrench ? 'Connexion' : 'Connection';
  String get connectionType =>
      isFrench ? 'Type de connexion' : 'Connection type';
  String get advancedMode => isFrench ? 'Mode avance' : 'Advanced mode';
  String get advancedModeSubtitle =>
      isFrench ? 'Afficher les details techniques' : 'Show technical details';
  String get technicalDetails =>
      isFrench ? 'Details techniques' : 'Technical Details';
  String get dnsResolver => isFrench ? 'Resolveur DNS' : 'DNS resolver';
  String get backendStatus =>
      isFrench ? 'Etat du serveur PingFlow' : 'PingFlow server status';
  String get managedBySystem =>
      isFrench ? 'Gere par le systeme' : 'Managed by system';
  String get providedBySystem =>
      isFrench ? 'Fourni par le systeme' : 'Provided by system';
  String get unableNetworkDetails => isFrench
      ? 'Impossible de charger les details reseau.'
      : 'Unable to load network details.';

  String get packets => isFrench ? 'Paquets' : 'Packets';
  String get startPing => isFrench ? 'Demarrer Ping' : 'Start Ping';
  String get stopPing => isFrench ? 'Arreter Ping' : 'Stop Ping';
  String get pingStopped => isFrench ? 'Ping arrete.' : 'Ping stopped.';
  String get sent => isFrench ? 'Envoyes' : 'Sent';
  String get received => isFrench ? 'Recus' : 'Received';
  String get loss => isFrench ? 'Perte' : 'Loss';
  String get min => 'Min';
  String get avg => isFrench ? 'Moy.' : 'Avg';
  String get max => 'Max';
  String get responseTime => isFrench ? 'Temps de reponse' : 'Response Time';
  String get pingResults => isFrench ? 'Resultats Ping' : 'Ping Results';
  String get emptyPing => isFrench
      ? 'Lancez un ping pour voir les reponses en temps reel.'
      : 'Run a ping to see real-time replies.';
  String get networkTimeout => isFrench
      ? 'La requete reseau a expire ou l hote est inaccessible.'
      : 'Network request timed out or host is unreachable.';
  String replyFrom(String host, int latencyMs, int ttl) => isFrench
      ? 'Reponse de $host : temps=${latencyMs}ms ttl=$ttl'
      : 'Reply from $host: time=${latencyMs}ms ttl=$ttl';
  String requestTimedOut(String host) =>
      isFrench ? 'Delai depasse pour $host' : 'Request timed out for $host';

  String get startTraceroute =>
      isFrench ? 'Demarrer Traceroute' : 'Start Traceroute';
  String get stopTraceroute =>
      isFrench ? 'Arreter Traceroute' : 'Stop Traceroute';
  String get tracerouteFailed =>
      isFrench ? 'Traceroute a echoue.' : 'Traceroute failed.';
  String get tracerouteStopped =>
      isFrench ? 'Traceroute arrete.' : 'Traceroute stopped.';
  String get hops => isFrench ? 'Sauts' : 'Hops';
  String get avgTime => isFrench ? 'Temps moy.' : 'Avg. Time';
  String get destination => isFrench ? 'Destination' : 'Destination';
  String get route => isFrench ? 'Route' : 'Route';
  String get emptyTraceroute => isFrench
      ? 'Lancez traceroute pour inspecter les sauts de route.'
      : 'Run traceroute to inspect route hops.';

  String get download => 'Download';
  String get upload => 'Upload';
  String get jitter => 'Jitter';
  String get ready => isFrench ? 'Pret' : 'Ready';
  String get measuringPingJitter =>
      isFrench ? 'Mesure du ping et du jitter' : 'Measuring ping and jitter';
  String get measuringDownload =>
      isFrench ? 'Mesure du download' : 'Measuring download';
  String get measuringUpload =>
      isFrench ? 'Mesure de l upload' : 'Measuring upload';
  String get completed => isFrench ? 'Termine' : 'Completed';
  String get startTest => isFrench ? 'Demarrer le test' : 'Start Test';
  String get stopTest => isFrench ? 'Arreter le test' : 'Stop Test';
  String get speedTestFailed => isFrench
      ? 'Le test de vitesse a echoue. Verifiez votre connexion et l API backend.'
      : 'Speed test failed. Check your connection and backend API.';
  String get speedTestStopped =>
      isFrench ? 'Test de vitesse arrete.' : 'Speed test stopped.';
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppStrings.supportedLocales
        .any((supported) => supported.languageCode == locale.languageCode);
  }

  @override
  Future<AppStrings> load(Locale locale) {
    final languageCode = locale.languageCode == 'fr' ? 'fr' : 'en';
    return SynchronousFuture(AppStrings(Locale(languageCode)));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppStrings> old) => false;
}
