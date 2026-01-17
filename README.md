# 🌤️ Hava Durumu Uygulaması

Modern ve şık bir iOS tarzı hava durumu uygulaması. Flutter ile geliştirilmiştir.

## ✨ Özellikler

- 🏙️ **Şehir ve İlçe Seçimi**: İlk açılışta Türkiye'nin tüm il ve ilçelerinden seçim yapın
- 📍 **81 İl ve Tüm İlçeler**: Türkiye genelinde tam kapsam
- 📅 **3 Günlük Tahmin**: Bugün dahil 3 günlük detaylı hava durumu tahmini
- 🎨 **Modern iOS Tasarımı**: Gradient renkler, yumuşak animasyonlar ve şık kartlar
- 💾 **Kalıcı Veri**: Seçiminiz ve eklediğiniz şehirler kaydedilir
- 🔄 **Yenileme**: Aşağı kaydırarak hava durumunu güncelleyin
- 🌡️ **Detaylı Bilgi**: Sıcaklık, nem, rüzgar hızı ve hissedilen sıcaklık
- ➕ **Çoklu Şehir Takibi**: İstediğiniz kadar şehir ekleyip takip edebilirsiniz
- 🔍 **Arama Özelliği**: Şehir ve ilçe listelerinde hızlı arama

## 🚀 Kullanılan Teknolojiler

- **Flutter**: Mobil uygulama framework'ü
- **Provider**: State management
- **OpenWeatherMap API**: Ücretsiz hava durumu API'si
- **Shared Preferences**: Yerel veri saklama
- **HTTP**: API istekleri
- **Intl**: Tarih formatları

## 📱 Ekran Görüntüleri

Uygulama şunları içerir:
- **İlk Açılış Ekranı**: İkiye bölünmüş şehir ve ilçe seçim ekranı
- **Ana Ekran**: Seçilen bölgenin hava durumu
- **3 Günlük Tahmin Kartı**: Detaylı günlük tahminler
- **Yatay Kaydırmalı Şehir Kartları**: Eklenen şehirlerin kartları
- **Şehir Ekleme Ekranı**: Popüler şehirler listesi ile

## 🛠️ Kurulum

1. Flutter SDK'nın yüklü olduğundan emin olun
2. Projeyi klonlayın
3. Bağımlılıkları yükleyin:
```bash
flutter pub get
```

4. Android emülatör veya cihazda çalıştırın:
```bash
flutter run
```

## 🔑 API Anahtarı

Uygulama OpenWeatherMap API'sini kullanmaktadır. Ücretsiz API anahtarı dahil edilmiştir.
Kendi API anahtarınızı kullanmak isterseniz:

1. [OpenWeatherMap](https://openweathermap.org/api) sitesinden ücretsiz hesap oluşturun
2. `lib/services/weather_service.dart` dosyasındaki `_apiKey` değişkenini değiştirin

## 📋 İzinler

Uygulama şu izinleri gerektirir:
- İnternet erişimi (OpenWeatherMap API için)

## 🎯 Kullanım

1. **İlk Açılış**: 
   - Şehir ve ilçe seçim ekranı açılır
   - Sol taraftan şehrinizi seçin (arama yapabilirsiniz)
   - Sağ taraftan ilçenizi seçin
   - "Devam Et" butonuna tıklayın

2. **Ana Ekran**:
   - Seçtiğiniz bölgenin hava durumu otomatik yüklenir
   - Aşağı kaydırarak yenileyin
   - 3 günlük tahminleri görüntüleyin

3. **Konum Değiştirme**: 
   - Sağ üstteki konum düzenleme ikonuna tıklayın
   - Yeni şehir ve ilçe seçin

4. **Şehir Ekleme**: 
   - Sağ üstteki + butonuna tıklayın
   - Şehir adı yazın veya popüler şehirlerden seçin
   - Eklenen şehirler yatay kartlar halinde görünür

5. **Şehir Değiştirme**: 
   - Kaydedilmiş şehir kartlarına tıklayarak o şehrin detaylarını görün

6. **Şehir Silme**: 
   - Şehir kartına uzun basarak silme seçeneğini açın

## 🎨 Tasarım Özellikleri

- Koyu tema (Dark mode)
- Gradient renkli kartlar (Mavi ve mor tonları)
- Yumuşak köşeler ve gölgeler
- iOS tarzı tipografi
- Responsive tasarım
- Smooth animasyonlar

## 📦 Proje Yapısı

```
lib/
├── main.dart                      # Uygulama giriş noktası
├── data/
│   └── cities_data.dart          # Türkiye il ve ilçe verileri
├── models/
│   └── weather_data.dart         # Veri modelleri
├── services/
│   ├── weather_service.dart      # API servisi
│   └── city_storage.dart         # Yerel depolama
├── providers/
│   └── weather_provider.dart     # State management
└── screens/
    ├── home_screen.dart          # Ana ekran
    ├── city_selection_screen.dart # İlk açılış şehir seçimi
    └── add_city_screen.dart      # Şehir ekleme ekranı
```

## 🌍 Desteklenen Diller

- Türkçe (Hava durumu açıklamaları ve gün isimleri)

## 📝 Notlar

- Uygulama sadece Türkiye şehirlerini desteklemektedir
- API ücretsiz sürümü günde 1000 istek sınırına sahiptir
- 81 il ve tüm ilçeler dahil edilmiştir
- Konum izni gerektirmez, tamamen manuel seçim yapılır
- İlk açılışta yapılan seçim kaydedilir ve hatırlanır

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje eğitim amaçlı geliştirilmiştir.

## 👨‍💻 Geliştirici

Flutter ile ❤️ ile geliştirildi.

---

**Not**: Emülatörde test edilmiştir. Gerçek cihazda da sorunsuz çalışacaktır.
