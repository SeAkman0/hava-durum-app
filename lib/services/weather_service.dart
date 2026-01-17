import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WeatherService {
  // Open-Meteo API - Ücretsiz, API key gerektirmiyor!
  static const String _baseUrl = 'https://api.open-meteo.com/v1';
  static const String _geocodingUrl = 'https://geocoding-api.open-meteo.com/v1';


  // Şehir adından koordinat al
  Future<Map<String, double>> _getCityCoordinates(String cityName) async {
    final url = Uri.parse(
      '$_geocodingUrl/search?name=$cityName&count=1&language=tr&format=json',
    );

    print('Geocoding Request: $url');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        final result = data['results'][0];
        print('✅ Koordinatlar bulundu: ${result['name']} (${result['latitude']}, ${result['longitude']})');
        return {
          'latitude': result['latitude'],
          'longitude': result['longitude'],
        };
      }
    }
    
    throw Exception('Şehir koordinatları bulunamadı: $cityName');
  }

  // Şehir adından hava durumu al
  Future<WeatherData> getWeatherByCity(String cityName) async {
    try {
      // Önce koordinatları al
      final coordinates = await _getCityCoordinates(cityName);
      final lat = coordinates['latitude']!;
      final lon = coordinates['longitude']!;

      // Şimdi hava durumunu al
      final url = Uri.parse(
        '$_baseUrl/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto',
      );

      print('Weather API Request: $url');

      final response = await http.get(url);

      print('Weather API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Open-Meteo formatını OpenWeatherMap formatına dönüştür
        return WeatherData.fromOpenMeteo(data, cityName);
      } else {
        throw Exception('Hava durumu alınamadı');
      }
    } catch (e) {
      print('❌ Hata: $e');
      rethrow;
    }
  }

  // 3 günlük tahmin al (şehir adı ile)
  Future<ForecastData> getForecastByCity(String cityName) async {
    try {
      final coordinates = await _getCityCoordinates(cityName);
      final lat = coordinates['latitude']!;
      final lon = coordinates['longitude']!;

      final url = Uri.parse(
        '$_baseUrl/forecast?latitude=$lat&longitude=$lon&daily=weather_code,temperature_2m_max,temperature_2m_min,wind_speed_10m_max,relative_humidity_2m_mean&timezone=auto&forecast_days=4',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ForecastData.fromOpenMeteo(data);
      } else {
        throw Exception('Tahmin alınamadı');
      }
    } catch (e) {
      print('❌ Tahmin hatası: $e');
      rethrow;
    }
  }

}
