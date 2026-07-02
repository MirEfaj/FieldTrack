import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  ConnectivityService(this._connectivity);

  final Connectivity _connectivity;

  Stream<bool> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map(_isConnected);

  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return _isConnected(result);
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any(
      (r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet,
    );
  }

  void debugLogStatus(bool connected) {
    if (kDebugMode) {
      debugPrint('Connectivity: ${connected ? 'online' : 'offline'}');
    }
  }
}
