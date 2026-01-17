import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../data/cities_data.dart';
import 'city_selection_screen.dart';

class AddCityScreen extends StatefulWidget {
  const AddCityScreen({super.key});

  @override
  State<AddCityScreen> createState() => _AddCityScreenState();
}

class _AddCityScreenState extends State<AddCityScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  // Türkiye'nin popüler şehirleri
  final List<String> _popularCities = [
    'İstanbul',
    'Ankara',
    'İzmir',
    'Antalya',
    'Bursa',
    'Adana',
    'Gaziantep',
    'Konya',
    'Mersin',
    'Kayseri',
    'Eskişehir',
    'Diyarbakır',
    'Samsun',
    'Denizli',
    'Şanlıurfa',
    'Adapazarı',
    'Malatya',
    'Kahramanmaraş',
    'Erzurum',
    'Van',
    'Batman',
    'Elazığ',
    'İzmit',
    'Manisa',
    'Sivas',
    'Gebze',
    'Balıkesir',
    'Tarsus',
    'Kütahya',
    'Trabzon',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addCity(String cityName) async {
    if (cityName.isEmpty) return;

    // Şehir ve ilçe seçimi için yeni ekran aç
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CitySelectionScreen(),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _isLoading = true;
      });

      final city = result['city'] as String;
      final district = result['district'] as String;

      final provider = context.read<WeatherProvider>();
      await provider.addCity(city, district);

      setState(() {
        _isLoading = false;
      });

      if (provider.error == null) {
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Şehir Ekle',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Arama kutusu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Şehir adı girin...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search, color: Colors.white38),
                  suffixIcon: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.blue,
                            ),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.blue),
                          onPressed: () => _addCity(_controller.text.trim()),
                        ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                onSubmitted: _addCity,
              ),
            ),
          ),

          // Popüler şehirler başlığı
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'POPÜLER ŞEHİRLER',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),

          // Popüler şehirler listesi
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _popularCities.length,
              itemBuilder: (context, index) {
                final city = _popularCities[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.location_city,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      city,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.blue,
                    ),
                    onTap: () => _addCity(city),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
