class WeatherData {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String description;
  final String icon;
  final DateTime dateTime;
  final double tempMin;
  final double tempMax;

  WeatherData({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
    required this.dateTime,
    required this.tempMin,
    required this.tempMax,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'] ?? '',
      country: json['sys']['country'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '',
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      tempMax: (json['main']['temp_max'] as num).toDouble(),
    );
  }

  // Open-Meteo API'sinden veri dönüşümü
  factory WeatherData.fromOpenMeteo(Map<String, dynamic> json, String cityName) {
    final current = json['current'];
    final daily = json['daily'];
    final weatherCode = current['weather_code'] as int;
    
    return WeatherData(
      cityName: cityName,
      country: 'TR',
      temperature: (current['temperature_2m'] as num).toDouble(),
      feelsLike: (current['temperature_2m'] as num).toDouble(), // Open-Meteo'da feels_like yok, aynı değer
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      description: _getWeatherDescription(weatherCode),
      icon: _getWeatherIcon(weatherCode),
      dateTime: DateTime.parse(current['time']),
      tempMin: (daily['temperature_2m_min'][0] as num).toDouble(),
      tempMax: (daily['temperature_2m_max'][0] as num).toDouble(),
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@4x.png';

  // Open-Meteo hava durumu kodunu açıklamaya çevir
  static String _getWeatherDescription(int code) {
    switch (code) {
      case 0: return 'açık';
      case 1: return 'çoğunlukla açık';
      case 2: return 'parçalı bulutlu';
      case 3: return 'kapalı';
      case 45: case 48: return 'sisli';
      case 51: case 53: case 55: return 'çiseliyor';
      case 61: case 63: case 65: return 'yağmurlu';
      case 71: case 73: case 75: return 'karlı';
      case 80: case 81: case 82: return 'sağanak yağışlı';
      case 85: case 86: return 'kar yağışlı';
      case 95: return 'gök gürültülü fırtına';
      case 96: case 99: return 'dolu fırtınası';
      default: return 'bilinmeyen';
    }
  }

  // Open-Meteo hava durumu kodunu ikona çevir
  static String _getWeatherIcon(int code) {
    switch (code) {
      case 0: return '01d';
      case 1: return '02d';
      case 2: return '03d';
      case 3: return '04d';
      case 45: case 48: return '50d';
      case 51: case 53: case 55: case 61: case 63: case 65: return '10d';
      case 71: case 73: case 75: case 85: case 86: return '13d';
      case 80: case 81: case 82: return '09d';
      case 95: case 96: case 99: return '11d';
      default: return '01d';
    }
  }
}

class ForecastData {
  final List<DailyForecast> dailyForecasts;

  ForecastData({required this.dailyForecasts});

  factory ForecastData.fromJson(Map<String, dynamic> json) {
    List<dynamic> list = json['list'];
    
    // Günlük tahminleri grupla
    Map<String, List<Map<String, dynamic>>> groupedByDay = {};
    
    for (var item in list) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      String dateKey = '${date.year}-${date.month}-${date.day}';
      
      if (!groupedByDay.containsKey(dateKey)) {
        groupedByDay[dateKey] = [];
      }
      groupedByDay[dateKey]!.add(item);
    }

    // Her gün için ortalama değerleri hesapla
    List<DailyForecast> forecasts = [];
    groupedByDay.forEach((dateKey, items) {
      if (forecasts.length < 4) { // Bugün + 3 gün
        forecasts.add(DailyForecast.fromList(items));
      }
    });

    return ForecastData(dailyForecasts: forecasts);
  }

  // Open-Meteo API'sinden veri dönüşümü
  factory ForecastData.fromOpenMeteo(Map<String, dynamic> json) {
    final daily = json['daily'];
    List<DailyForecast> forecasts = [];

    for (int i = 0; i < (daily['time'] as List).length && i < 4; i++) {
      forecasts.add(DailyForecast(
        date: DateTime.parse(daily['time'][i]),
        tempMin: (daily['temperature_2m_min'][i] as num).toDouble(),
        tempMax: (daily['temperature_2m_max'][i] as num).toDouble(),
        description: WeatherData._getWeatherDescription(daily['weather_code'][i] as int),
        icon: WeatherData._getWeatherIcon(daily['weather_code'][i] as int),
        humidity: (daily['relative_humidity_2m_mean'][i] as num).toInt(),
        windSpeed: (daily['wind_speed_10m_max'][i] as num).toDouble(),
      ));
    }

    return ForecastData(dailyForecasts: forecasts);
  }
}

class DailyForecast {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;

  DailyForecast({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
  });

  factory DailyForecast.fromList(List<Map<String, dynamic>> items) {
    double minTemp = double.infinity;
    double maxTemp = double.negativeInfinity;
    double totalHumidity = 0;
    double totalWindSpeed = 0;
    String description = '';
    String icon = '';
    DateTime date = DateTime.fromMillisecondsSinceEpoch(items[0]['dt'] * 1000);

    for (var item in items) {
      double temp = (item['main']['temp'] as num).toDouble();
      if (temp < minTemp) minTemp = temp;
      if (temp > maxTemp) maxTemp = temp;
      
      totalHumidity += item['main']['humidity'];
      totalWindSpeed += (item['wind']['speed'] as num).toDouble();
      
      // Öğlen saatlerindeki hava durumunu al (daha temsili)
      DateTime itemDate = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      if (itemDate.hour >= 12 && itemDate.hour <= 15) {
        description = item['weather'][0]['description'];
        icon = item['weather'][0]['icon'];
      }
    }

    // Eğer öğlen verisi yoksa ilk veriyi kullan
    if (description.isEmpty) {
      description = items[0]['weather'][0]['description'];
      icon = items[0]['weather'][0]['icon'];
    }

    return DailyForecast(
      date: date,
      tempMin: minTemp,
      tempMax: maxTemp,
      description: description,
      icon: icon,
      humidity: (totalHumidity / items.length).round(),
      windSpeed: totalWindSpeed / items.length,
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
}
