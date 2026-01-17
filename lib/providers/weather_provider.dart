import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';
import '../services/city_storage.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final CityStorage _cityStorage = CityStorage();

  WeatherData? _currentWeather;
  ForecastData? _currentForecast;
  List<String> _savedCities = [];
  Map<String, WeatherData> _citiesWeather = {};
  bool _isLoading = false;
  String? _error;
  String? _currentCityName;

  WeatherData? get currentWeather => _currentWeather;
  ForecastData? get currentForecast => _currentForecast;
  List<String> get savedCities => _savedCities;
  Map<String, WeatherData> get citiesWeather => _citiesWeather;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentCityName => _currentCityName;

  WeatherProvider() {
    loadSavedCities();
  }

  // Kaydedilmiş şehirleri yükle
  Future<void> loadSavedCities() async {
    _savedCities = await _cityStorage.loadCities();
    notifyListeners();
    
    // Kaydedilmiş şehirlerin hava durumunu al
    for (String cityKey in _savedCities) {
      // Format: "İlçe, Şehir" veya "Şehir"
      final parts = cityKey.split(',');
      final actualCity = parts.length > 1 ? parts.last.trim() : cityKey;
      await fetchCityWeather(cityKey, actualCity);
    }
  }

  // Şehir adından hava durumu al
  Future<void> fetchWeatherByCity(String cityName) async {
    print('========================================');
    print('🌤️ HAVA DURUMU İSTEĞİ BAŞLADI');
    print('Aranan Şehir: $cityName');
    print('========================================');
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentWeather = await _weatherService.getWeatherByCity(cityName);
      _currentCityName = cityName;
      
      print('✅ Hava durumu başarıyla alındı!');
      print('Şehir: ${_currentWeather?.cityName}');
      print('Sıcaklık: ${_currentWeather?.temperature}°C');
      
      // Tahmin verilerini al
      _currentForecast = await _weatherService.getForecastByCity(cityName);
      print('✅ Tahmin verileri alındı: ${_currentForecast?.dailyForecasts.length} gün');
      
      _error = null;
    } catch (e) {
      print('❌ HATA OLUŞTU!');
      print('Hata Detayı: $e');
      print('Aranan Şehir: $cityName');
      _error = 'Şehir bulunamadı: $e';
      _currentWeather = null;
      _currentForecast = null;
    } finally {
      _isLoading = false;
      notifyListeners();
      print('========================================');
    }
  }

  // Belirli bir şehrin hava durumunu al (liste için)
  Future<void> fetchCityWeather(String cityKey, [String? actualCityName]) async {
    try {
      // cityKey format: "İlçe, Şehir" veya sadece "Şehir"
      final cityToFetch = actualCityName ?? cityKey.split(',').last.trim();
      final weather = await _weatherService.getWeatherByCity(cityToFetch);
      _citiesWeather[cityKey] = weather;
      notifyListeners();
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }

  // Şehir ekle (ilçe bilgisi ile)
  Future<void> addCity(String cityName, String districtName) async {
    final cityKey = '$districtName, $cityName';
    
    if (_savedCities.contains(cityKey)) {
      _error = 'Bu şehir zaten ekli';
      notifyListeners();
      return;
    }

    try {
      // Önce şehrin geçerli olup olmadığını kontrol et
      await _weatherService.getWeatherByCity(cityName);
      
      await _cityStorage.addCity(cityKey);
      _savedCities = await _cityStorage.loadCities();
      await fetchCityWeather(cityKey, cityName);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Şehir bulunamadı';
      notifyListeners();
    }
  }

  // Şehir sil
  Future<void> removeCity(String cityName) async {
    await _cityStorage.removeCity(cityName);
    _savedCities = await _cityStorage.loadCities();
    _citiesWeather.remove(cityName);
    notifyListeners();
  }

  // Hata mesajını temizle
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
