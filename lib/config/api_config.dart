class ApiConfig {
  static const String baseUrl = 'https://bf7036ee52d5.ngrok-free.app/api';
  static const String wsUrl = 'wss://api.evhub.lk/ws';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}

class AppConfig {
  static const String appName = 'EVHub';
  static const String appVersion = '1.0.0';
  static const String currency = 'LKR';
  static const String currencySymbol = 'Rs.';

  static const double defaultLatitude = 6.9271;
  static const double defaultLongitude = 79.8612;
  static const double defaultRadius = 50.0;

  static const int bookingHoldMinutes = 10;
  static const int graceWindowMinutes = 15;

  static const List<String> connectorTypes = [
    'Type 2',
    'CCS',
    'CHAdeMO',
    'Type 1',
  ];

  static const List<int> powerLevels = [7, 11, 22, 50, 100, 150, 350];
}
