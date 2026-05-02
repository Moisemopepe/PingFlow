class AppConfig {
  const AppConfig._();

  static const backendBaseUrl = String.fromEnvironment(
    'PINGFLOW_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8787',
  );
}
