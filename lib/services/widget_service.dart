import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../models/weather_data.dart';

class WidgetService {
  /// Widget'ı tek bir şehrin hava durumu verileriyle günceller
  static Future<void> updateWidget(WeatherData weatherData, String cityName) async {
    try {
      // Basit veri formatı (eski metod için)
      await HomeWidget.saveWidgetData<String>(
        'widget_city',
        cityName,
      );
      
      await HomeWidget.saveWidgetData<String>(
        'widget_temperature',
        '${weatherData.temperature.round()}°',
      );
      
      await HomeWidget.saveWidgetData<String>(
        'widget_description',
        weatherData.description,
      );
      
      await HomeWidget.saveWidgetData<String>(
        'widget_humidity',
        '${weatherData.humidity}%',
      );
      
      await HomeWidget.saveWidgetData<String>(
        'widget_wind',
        '${weatherData.windSpeed.toStringAsFixed(1)} km/s',
      );
      
      // Son güncelleme zamanı
      final now = DateTime.now();
      final timeFormat = DateFormat('HH:mm');
      await HomeWidget.saveWidgetData<String>(
        'widget_updated',
        'Son güncelleme: ${timeFormat.format(now)}',
      );

      // Widget'ı güncelle
      await HomeWidget.updateWidget(
        name: 'WeatherWidgetProvider',
        androidName: 'WeatherWidgetProvider',
      );
      
      print('✅ Widget başarıyla güncellendi: $cityName');
    } catch (e) {
      print('❌ Widget güncellenirken hata: $e');
    }
  }

  /// Widget'ı birden fazla şehrin verileriyle günceller (kaydırma için)
  static Future<void> updateWidgetWithMultipleCities(
    Map<String, WeatherData> citiesWeather,
    List<String> cityKeys,
    int currentIndex,
  ) async {
    try {
      // Şehir listesini JSON formatına çevir
      final citiesList = <Map<String, String>>[];
      
      for (String cityKey in cityKeys) {
        final weather = citiesWeather[cityKey];
        if (weather != null) {
          citiesList.add({
            'name': cityKey,
            'temperature': '${weather.temperature.round()}°',
            'description': weather.description,
            'humidity': '${weather.humidity}%',
            'wind': '${weather.windSpeed.toStringAsFixed(1)} km/s',
          });
        }
      }
      
      // JSON string'e çevir
      final citiesJson = jsonEncode(citiesList);
      
      // SharedPreferences'a kaydet
      await HomeWidget.saveWidgetData<String>(
        'widget_cities_list',
        citiesJson,
      );
      
      await HomeWidget.saveWidgetData<int>(
        'widget_current_index',
        currentIndex,
      );

      // Widget'ı güncelle
      await HomeWidget.updateWidget(
        name: 'WeatherWidgetProvider',
        androidName: 'WeatherWidgetProvider',
      );
      
      print('✅ Widget ${citiesList.length} şehirle güncellendi (index: $currentIndex)');
    } catch (e) {
      print('❌ Widget güncellenirken hata: $e');
    }
  }

  /// Widget'ı temizler
  static Future<void> clearWidget() async {
    try {
      await HomeWidget.saveWidgetData<String>('widget_city', 'Şehir Seçilmedi');
      await HomeWidget.saveWidgetData<String>('widget_temperature', '--°');
      await HomeWidget.saveWidgetData<String>('widget_description', 'Veri yok');
      await HomeWidget.saveWidgetData<String>('widget_humidity', '--%');
      await HomeWidget.saveWidgetData<String>('widget_wind', '-- km/s');
      await HomeWidget.saveWidgetData<String>('widget_updated', 'Henüz güncellenmedi');
      await HomeWidget.saveWidgetData<String>('widget_cities_list', '[]');
      await HomeWidget.saveWidgetData<int>('widget_current_index', 0);
      
      await HomeWidget.updateWidget(
        name: 'WeatherWidgetProvider',
        androidName: 'WeatherWidgetProvider',
      );
    } catch (e) {
      print('❌ Widget temizlenirken hata: $e');
    }
  }
}
