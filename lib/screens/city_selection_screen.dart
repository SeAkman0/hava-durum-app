import 'package:flutter/material.dart';
import '../data/cities_data.dart';

class CitySelectionScreen extends StatefulWidget {
  const CitySelectionScreen({super.key});

  @override
  State<CitySelectionScreen> createState() => _CitySelectionScreenState();
}

class _CitySelectionScreenState extends State<CitySelectionScreen> {
  String? selectedCity;
  String? selectedDistrict;
  List<String> districts = [];
  
  final TextEditingController _citySearchController = TextEditingController();
  final TextEditingController _districtSearchController = TextEditingController();
  
  List<String> filteredCities = TurkeyCitiesData.cities;
  List<String> filteredDistricts = [];

  @override
  void dispose() {
    _citySearchController.dispose();
    _districtSearchController.dispose();
    super.dispose();
  }

  void _onCitySelected(String city) {
    setState(() {
      selectedCity = city;
      selectedDistrict = null;
      districts = TurkeyCitiesData.getDistricts(city);
      filteredDistricts = districts;
      _districtSearchController.clear();
    });
  }

  void _onDistrictSelected(String district) {
    setState(() {
      selectedDistrict = district;
    });
  }

  void _filterCities(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCities = TurkeyCitiesData.cities;
      } else {
        filteredCities = TurkeyCitiesData.cities
            .where((city) => city.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _filterDistricts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredDistricts = districts;
      } else {
        filteredDistricts = districts
            .where((district) => district.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _confirm() {
    if (selectedCity != null && selectedDistrict != null) {
      Navigator.pop(context, {
        'city': selectedCity!,
        'district': selectedDistrict!,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.location_city,
                    size: 64,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Şehir ve İlçe Seçin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hava durumu takibi için bölgenizi seçin',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Seçim göstergesi
            if (selectedCity != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade800],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      selectedDistrict != null
                          ? '$selectedDistrict, $selectedCity'
                          : selectedCity!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            // İçerik
            Expanded(
              child: Row(
                children: [
                  // Şehirler listesi
                  Expanded(
                    child: Column(
                      children: [
                        // Şehir arama
                        Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _citySearchController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Şehir ara...',
                              hintStyle: TextStyle(color: Colors.white38),
                              prefixIcon: Icon(Icons.search, color: Colors.white38),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(12),
                            ),
                            onChanged: _filterCities,
                          ),
                        ),
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'ŞEHİR',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),

                        // Şehirler
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: filteredCities.length,
                            itemBuilder: (context, index) {
                              final city = filteredCities[index];
                              final isSelected = city == selectedCity;
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? Colors.blue.withOpacity(0.2)
                                      : const Color(0xFF2C2C2E),
                                  borderRadius: BorderRadius.circular(10),
                                  border: isSelected
                                      ? Border.all(color: Colors.blue, width: 2)
                                      : null,
                                ),
                                child: ListTile(
                                  dense: true,
                                  title: Text(
                                    city,
                                    style: TextStyle(
                                      color: isSelected ? Colors.blue : Colors.white,
                                      fontWeight: isSelected 
                                          ? FontWeight.w600 
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(Icons.check_circle, color: Colors.blue)
                                      : null,
                                  onTap: () => _onCitySelected(city),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Dikey çizgi
                  Container(
                    width: 1,
                    color: Colors.white12,
                  ),

                  // İlçeler listesi
                  Expanded(
                    child: Column(
                      children: [
                        // İlçe arama
                        Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selectedCity != null
                                ? const Color(0xFF2C2C2E)
                                : const Color(0xFF2C2C2E).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _districtSearchController,
                            enabled: selectedCity != null,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'İlçe ara...',
                              hintStyle: TextStyle(color: Colors.white38),
                              prefixIcon: Icon(Icons.search, color: Colors.white38),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(12),
                            ),
                            onChanged: _filterDistricts,
                          ),
                        ),
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'İLÇE',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),

                        // İlçeler
                        Expanded(
                          child: selectedCity == null
                              ? Center(
                                  child: Text(
                                    'Önce şehir seçin',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.3),
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  itemCount: filteredDistricts.length,
                                  itemBuilder: (context, index) {
                                    final district = filteredDistricts[index];
                                    final isSelected = district == selectedDistrict;
                                    
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 6),
                                      decoration: BoxDecoration(
                                        color: isSelected 
                                            ? Colors.purple.withOpacity(0.2)
                                            : const Color(0xFF2C2C2E),
                                        borderRadius: BorderRadius.circular(10),
                                        border: isSelected
                                            ? Border.all(color: Colors.purple, width: 2)
                                            : null,
                                      ),
                                      child: ListTile(
                                        dense: true,
                                        title: Text(
                                          district,
                                          style: TextStyle(
                                            color: isSelected ? Colors.purple : Colors.white,
                                            fontWeight: isSelected 
                                                ? FontWeight.w600 
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        trailing: isSelected
                                            ? const Icon(Icons.check_circle, color: Colors.purple)
                                            : null,
                                        onTap: () => _onDistrictSelected(district),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Onay butonu
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedCity != null && selectedDistrict != null
                      ? _confirm
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    disabledBackgroundColor: Colors.grey.shade800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    selectedCity != null && selectedDistrict != null
                        ? 'Devam Et'
                        : 'Şehir ve İlçe Seçin',
                    style: TextStyle(
                      color: selectedCity != null && selectedDistrict != null
                          ? Colors.white
                          : Colors.white38,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
