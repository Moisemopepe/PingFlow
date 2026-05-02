class AppConfig {
  const AppConfig._();

  static const backendBaseUrl = String.fromEnvironment(
    'PINGFLOW_API_BASE_URL',
    defaultValue: 'https://pingflow-api.onrender.com',
  );
}
