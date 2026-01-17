import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/weather_provider.dart';
import '../models/weather_data.dart';
import 'city_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCity;
  String? _selectedDistrict;

  @override
  void initState() {
    super.initState();
    _loadSelectedCity();
  }

  Future<void> _loadSelectedCity() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedCity = prefs.getString('selected_city');
    _selectedDistrict = prefs.getString('selected_district');

    print('📍 Kaydedilmiş Konum Yüklendi:');
    print('Şehir: $_selectedCity');
    print('İlçe: $_selectedDistrict');

    if (_selectedCity != null && mounted) {
      // API sadece şehir adını destekler, ilçe UI için kullanılır
      context.read<WeatherProvider>().fetchWeatherByCity(_selectedCity!);
    } else {
      print('⚠️ Kaydedilmiş şehir bulunamadı');
    }
  }

  Future<void> _changeLocation() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CitySelectionScreen(),
      ),
    );

    if (result != null && mounted) {
      final city = result['city'] as String;
      final district = result['district'] as String;
      
      setState(() {
        _selectedCity = city;
        _selectedDistrict = district;
      });

      // Seçilen şehri kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_city', city);
      await prefs.setString('selected_district', district);

      // Hava durumunu güncelle (API sadece şehir adını kabul eder)
      if (mounted) {
        context.read<WeatherProvider>().fetchWeatherByCity(city);
      }
    }
  }

  Future<void> _addNewCity() async {
    // Direkt şehir ve ilçe seçim ekranını aç
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CitySelectionScreen(),
      ),
    );

    if (result != null && mounted) {
      final city = result['city'] as String;
      final district = result['district'] as String;

      // Şehri kayıtlı şehirler listesine ekle
      final provider = context.read<WeatherProvider>();
      await provider.addCity(city, district);

      if (provider.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error!),
            backgroundColor: Colors.red,
          ),
        );
        provider.clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.currentWeather == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }

          if (provider.error != null && provider.currentWeather == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedCity != null) {
                        // API sadece şehir adını kabul eder
                        provider.fetchWeatherByCity(_selectedCity!);
                      } else {
                        _changeLocation();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (_selectedCity != null) {
                // API sadece şehir adını kabul eder
                await provider.fetchWeatherByCity(_selectedCity!);
              } else if (provider.currentCityName != null) {
                await provider.fetchWeatherByCity(provider.currentCityName!);
              }
            },
            color: Colors.blue,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      _selectedDistrict != null && _selectedCity != null
                          ? '$_selectedDistrict, $_selectedCity'
                          : provider.currentWeather?.cityName ?? 'Hava Durumu',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    centerTitle: true,
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit_location, color: Colors.white),
                      tooltip: 'Konum Değiştir',
                      onPressed: _changeLocation,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      tooltip: 'Şehir Ekle',
                      onPressed: _addNewCity,
                    ),
                  ],
                ),

                // Ana hava durumu kartı
                SliverToBoxAdapter(
                  child: _buildMainWeatherCard(provider.currentWeather!),
                ),

                // 3 günlük tahmin
                if (provider.currentForecast != null)
                  SliverToBoxAdapter(
                    child: _buildForecastSection(provider.currentForecast!),
                  ),

                // Kaydedilmiş şehirler
                SliverToBoxAdapter(
                  child: _buildSavedCitiesSection(provider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainWeatherCard(WeatherData weather) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade400,
            Colors.blue.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Sıcaklık
          Text(
            '${weather.temperature.round()}°',
            style: const TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.w200,
              color: Colors.white,
            ),
          ),
          
          // Açıklama
          Text(
            weather.description.toUpperCase(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Min/Max
          Text(
            'Min ${weather.tempMin.round()}° • Max ${weather.tempMax.round()}°',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Detaylar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherDetail(
                Icons.water_drop,
                '${weather.humidity}%',
                'Nem',
              ),
              _buildWeatherDetail(
                Icons.air,
                '${weather.windSpeed.toStringAsFixed(1)} m/s',
                'Rüzgar',
              ),
              _buildWeatherDetail(
                Icons.thermostat,
                '${weather.feelsLike.round()}°',
                'Hissedilen',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildForecastSection(ForecastData forecast) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '3 GÜNLÜK TAHMİN',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          ...forecast.dailyForecasts.map((daily) => _buildForecastItem(daily)),
        ],
      ),
    );
  }

  Widget _buildForecastItem(DailyForecast forecast) {
    final dayName = _getTurkishDayName(forecast.date);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Gün
          Expanded(
            flex: 2,
            child: Text(
              dayName.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // İkon ve açıklama
          Expanded(
            flex: 3,
            child: Row(
              children: [
                const Icon(
                  Icons.wb_sunny,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    forecast.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          // Sıcaklık
          Text(
            '${forecast.tempMin.round()}° / ${forecast.tempMax.round()}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedCitiesSection(WeatherProvider provider) {
    if (provider.savedCities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'KAYITLI ŞEHİRLER',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
          
          // Şehirler listesi
          SizedBox(
            height: 172,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: provider.savedCities.length,
              itemBuilder: (context, index) {
                final cityKey = provider.savedCities[index];
                final weather = provider.citiesWeather[cityKey];
                
                return _buildCityCard(cityKey, weather, provider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityCard(
    String cityKey,
    WeatherData? weather,
    WeatherProvider provider,
  ) {
    // cityKey format: "İlçe, Şehir" veya "Şehir"
    final parts = cityKey.split(',');
    final displayName = parts.length > 1 ? parts[0].trim() : cityKey;
    final actualCity = parts.length > 1 ? parts.last.trim() : cityKey;
    
    // Bu şehir seçili mi kontrol et
    final isSelected = _selectedCity == actualCity && 
                      (_selectedDistrict == null || _selectedDistrict == displayName);
    
    return GestureDetector(
      onTap: () async {
        if (weather != null) {
          // Seçili şehri değiştir
          setState(() {
            _selectedCity = actualCity;
            _selectedDistrict = parts.length > 1 ? displayName : null;
          });
          
          // SharedPreferences'a kaydet
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('selected_city', actualCity);
          if (parts.length > 1) {
            await prefs.setString('selected_district', displayName);
          }
          
          // Hava durumunu güncelle
          await provider.fetchWeatherByCity(actualCity);
        }
      },
      onLongPress: () {
        _showDeleteDialog(cityKey, provider);
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    Colors.green.shade400,
                    Colors.green.shade700,
                  ]
                : [
                    Colors.purple.shade400,
                    Colors.purple.shade700,
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: Colors.white, width: 3)
              : null,
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.green.withOpacity(0.5)
                  : Colors.purple.withOpacity(0.3),
              blurRadius: isSelected ? 15 : 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: weather == null
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 20,
                        ),
                    ],
                  ),
                  if (parts.length > 1)
                    Text(
                      actualCity,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${weather.temperature.round()}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      Text(
                        weather.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  // Sayfa göstergesi (noktalar)
  // Türkçe gün adı al
  String _getTurkishDayName(DateTime date) {
    const days = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar'
    ];
    
    // DateTime.weekday: 1 (Monday) to 7 (Sunday)
    return days[date.weekday - 1];
  }

  void _showDeleteDialog(String cityKey, WeatherProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text(
          'Şehri Sil',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '$cityKey şehrini listeden kaldırmak istiyor musunuz?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              provider.removeCity(cityKey);
              Navigator.pop(context);
            },
            child: const Text(
              'Sil',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
