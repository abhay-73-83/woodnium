import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamController<bool> connectionStatusController = StreamController<bool>.broadcast();

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      bool isConnected = results.isNotEmpty && results.first != ConnectivityResult.none;
      connectionStatusController.add(isConnected);
    });
  }

  Future<bool> checkConnection() async {
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    return results.isNotEmpty && results.first != ConnectivityResult.none;
  }
  
  void dispose() {
    connectionStatusController.close();
  }
}
