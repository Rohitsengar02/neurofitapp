import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// Centralized API & Server Configuration for Admin HQ with instant Local vs Live Render toggle
class ApiConstants {
  /// 🔘 SWITCH HERE: Set to `true` for Local Backend, or `false` for Live Render Backend
  static const bool useLocalBackend = true;

  /// Live Render Production Base URL
  static const String liveRenderUrl = 'https://neurofit-full.onrender.com';

  /// Local Backend Configuration
  static const int serverPort = 5000;
  static const String serverHost = 'localhost';
  static const String emulatorHost = '10.0.2.2';
  static const String lanIp = '192.168.1.39';

  /// Returns active base URL based on toggle
  static String get baseUrl {
    if (useLocalBackend) {
      if (kIsWeb) {
        return 'http://localhost:$serverPort';
      }
      try {
        if (Platform.isAndroid) {
          return 'http://$emulatorHost:$serverPort';
        }
        if (Platform.isIOS) {
          return 'http://$lanIp:$serverPort';
        }
      } catch (_) {}
      return 'http://localhost:$serverPort';
    }
    return liveRenderUrl;
  }

  /// REST API base URL (e.g. http://localhost:5000/api or https://neurofit-full.onrender.com/api)
  static String get apiBaseUrl {
    return '$baseUrl/api';
  }

  /// Real-time Socket.io server URL
  static String get socketUrl {
    return baseUrl;
  }

  /// Candidate Base URLs list for smart fallback
  static List<String> get candidateBaseUrls {
    if (useLocalBackend) {
      if (kIsWeb) {
        return [
          'http://localhost:$serverPort',
          'http://$lanIp:$serverPort',
          'http://127.0.0.1:$serverPort',
          liveRenderUrl,
        ];
      }
      return [
        'http://$emulatorHost:$serverPort',
        'http://$lanIp:$serverPort',
        'http://localhost:$serverPort',
        'http://127.0.0.1:$serverPort',
        liveRenderUrl,
      ];
    } else {
      return [
        liveRenderUrl,
        'http://$serverHost:$serverPort',
        'http://$lanIp:$serverPort',
      ];
    }
  }
}

