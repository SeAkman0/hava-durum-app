import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/weather_provider.dart';
import 'screens/home_screen.dart';
import 'screens/city_selection_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Sistem UI ayarları
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WeatherProvider(),
      child: MaterialApp(
        title: 'Hava Durumu',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFF1C1C1E),
          fontFamily: 'SF Pro Display',
        ),
        home: const SplashScreen(),
        routes: {
          '/check': (context) => const InitialScreen(),
          '/home': (context) => const HomeScreen(),
          '/city-selection': (context) => const CitySelectionScreen(),
        },
      ),
    );
  }
}

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSelectedCity = prefs.containsKey('selected_city');

    if (!mounted) return;

    if (hasSelectedCity) {
      // Daha önce şehir seçilmiş, ana ekrana git
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // İlk açılış, şehir seçim ekranına git
      setState(() {
        _isChecking = false;
      });
      
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CitySelectionScreen(),
        ),
      );

      if (result != null && mounted) {
        final city = result['city'] as String;
        final district = result['district'] as String;
        
        // Seçilen şehri kaydet
        await prefs.setString('selected_city', city);
        await prefs.setString('selected_district', district);

        // Ana ekrana git
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: Center(
        child: _isChecking
            ? const CircularProgressIndicator(color: Colors.blue)
            : const SizedBox.shrink(),
      ),
    );
  }
}
