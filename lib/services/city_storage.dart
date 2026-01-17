import 'package:shared_preferences/shared_preferences.dart';

class CityStorage {
  static const String _key = 'saved_cities';

  // Şehirleri kaydet
  Future<void> saveCities(List<String> cities) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, cities);
  }

  // Şehirleri yükle
  Future<List<String>> loadCities() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  // Şehir ekle
  Future<void> addCity(String city) async {
    final cities = await loadCities();
    if (!cities.contains(city)) {
      cities.add(city);
      await saveCities(cities);
    }
  }

  // Şehir sil
  Future<void> removeCity(String city) async {
    final cities = await loadCities();
    cities.remove(city);
    await saveCities(cities);
  }
}
