class AppConstants {

  static const String apiBaseUrl = 'http://10.0.2.2:3000/api'; // Android Emulator
  // static const String apiBaseUrl = 'http://localhost:3000/api'; // iOS
  // static const String apiBaseUrl = 'http://192.168.1.100:3000/api'; // Dispositivo físico

  static const String defaultUserId = 'user1';

  static const Duration autoSyncInterval = Duration(seconds: 30);
  static const int maxRetries = 3;

  static const int colorSynced = 0xFF4CAF50; // Verde
  static const int colorPending = 0xFFFF9800; // Laranja
  static const int colorConflict = 0xFFF44336; // Vermelho
  static const int colorError = 0xFFF44336; // Vermelho
  static const int colorOnline = 0xFF4CAF50; // Verde
  static const int colorOffline = 0xFFF44336; // Vermelho
}



