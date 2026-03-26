import 'package:woodnium/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'utils/app_theme.dart';
import 'screens/no_internet_screen.dart';
import 'services/connectivity_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WoodNiumApp());
}

class WoodNiumApp extends StatefulWidget {
  const WoodNiumApp({super.key});

  @override
  State<WoodNiumApp> createState() => _WoodNiumAppState();
}

class _WoodNiumAppState extends State<WoodNiumApp> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    _connectivityService.connectionStatusController.stream.listen((isConnected) {
      if (mounted) {
        setState(() => _isConnected = isConnected);
      }
    });
  }

  Future<void> _checkInitialConnection() async {
    bool isConnected = await _connectivityService.checkConnection();
    if (mounted) {
      setState(() => _isConnected = isConnected);
    }
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WoodNium',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      builder: (context, child) {
        return Stack(
          children: [
            ?child,
            if (!_isConnected)
              Positioned.fill(
                child: NoInternetScreen(
                  onRetry: _checkInitialConnection,
                ),
              ),
          ],
        );
      },
    );
  }
}
