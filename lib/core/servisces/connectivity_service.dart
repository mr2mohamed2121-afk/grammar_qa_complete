
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService(this._connectivity);

  Stream<ConnectivityResult> get connectivityStream {
    return _connectivity.onConnectivityChanged;
  }

  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<bool> isWifi() async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.wifi;
  }

  Future<bool> isMobile() async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.mobile;
  }

  String getConnectionType(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.none:
        return 'No Connection';
      default:
        return 'Unknown';
    }
  }
}
