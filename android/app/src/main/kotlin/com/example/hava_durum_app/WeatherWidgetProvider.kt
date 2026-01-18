package com.example.hava_durum_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class WeatherWidgetProvider : AppWidgetProvider() {
    
    companion object {
        private const val ACTION_NEXT_CITY = "com.example.hava_durum_app.ACTION_NEXT_CITY"
        private const val ACTION_PREV_CITY = "com.example.hava_durum_app.ACTION_PREV_CITY"
        
        internal fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val widgetData = HomeWidgetPlugin.getData(context)
            
            // Şehirler listesini al
            val citiesJson = widgetData.getString("widget_cities_list", "[]") ?: "[]"
            val currentIndex = widgetData.getInt("widget_current_index", 0)
            
            // JSON'dan şehir listesini parse et (basit yaklaşım)
            val cities = parseCitiesFromJson(citiesJson)
            
            if (cities.isEmpty()) {
                // Veri yoksa varsayılan göster
                showDefaultData(context, appWidgetManager, appWidgetId)
                return
            }
            
            // Geçerli index kontrolü
            val safeIndex = if (currentIndex >= 0 && currentIndex < cities.size) currentIndex else 0
            val currentCity = cities[safeIndex]
            
            // RemoteViews oluştur
            val views = RemoteViews(context.packageName, R.layout.weather_widget)
            
            // Verileri set et
            views.setTextViewText(R.id.widget_city_name, currentCity.name)
            views.setTextViewText(R.id.widget_temperature, currentCity.temperature)
            views.setTextViewText(R.id.widget_description, currentCity.description)
            views.setTextViewText(R.id.widget_humidity, currentCity.humidity)
            views.setTextViewText(R.id.widget_wind, currentCity.wind)
            
            // İndikator noktaları oluştur
            val indicator = buildIndicator(cities.size, safeIndex)
            views.setTextViewText(R.id.widget_indicator, indicator)
            
            // Buton intent'lerini ayarla
            val prevIntent = Intent(context, WeatherWidgetProvider::class.java).apply {
                action = ACTION_PREV_CITY
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }
            val prevPendingIntent = PendingIntent.getBroadcast(
                context, 
                appWidgetId * 2, 
                prevIntent, 
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_prev_button, prevPendingIntent)
            
            val nextIntent = Intent(context, WeatherWidgetProvider::class.java).apply {
                action = ACTION_NEXT_CITY
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }
            val nextPendingIntent = PendingIntent.getBroadcast(
                context, 
                appWidgetId * 2 + 1, 
                nextIntent, 
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_next_button, nextPendingIntent)
            
            // Widget'ı güncelle
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
        
        private fun showDefaultData(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.weather_widget)
            views.setTextViewText(R.id.widget_city_name, "Şehir Seçilmedi")
            views.setTextViewText(R.id.widget_temperature, "--°")
            views.setTextViewText(R.id.widget_description, "Veri yok")
            views.setTextViewText(R.id.widget_humidity, "--%")
            views.setTextViewText(R.id.widget_wind, "-- km/s")
            views.setTextViewText(R.id.widget_indicator, "●")
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
        
        private fun parseCitiesFromJson(json: String): List<CityData> {
            val cities = mutableListOf<CityData>()
            try {
                // Basit JSON parsing (org.json kullanılabilir ama home_widget'tan gelen formatı parse edelim)
                val cleaned = json.trim().removePrefix("[").removeSuffix("]")
                if (cleaned.isEmpty()) return cities
                
                val cityStrings = cleaned.split("},{")
                for (cityStr in cityStrings) {
                    val cleanCity = cityStr.replace("{", "").replace("}", "")
                    val parts = cleanCity.split(",")
                    
                    var name = ""
                    var temp = ""
                    var desc = ""
                    var humidity = ""
                    var wind = ""
                    
                    for (part in parts) {
                        val keyValue = part.split(":")
                        if (keyValue.size == 2) {
                            val key = keyValue[0].trim().replace("\"", "")
                            val value = keyValue[1].trim().replace("\"", "")
                            when (key) {
                                "name" -> name = value
                                "temperature" -> temp = value
                                "description" -> desc = value
                                "humidity" -> humidity = value
                                "wind" -> wind = value
                            }
                        }
                    }
                    
                    if (name.isNotEmpty()) {
                        cities.add(CityData(name, temp, desc, humidity, wind))
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
            return cities
        }
        
        private fun buildIndicator(totalCities: Int, currentIndex: Int): String {
            val sb = StringBuilder()
            for (i in 0 until totalCities) {
                if (i == currentIndex) {
                    sb.append("● ")
                } else {
                    sb.append("○ ")
                }
            }
            return sb.toString().trim()
        }
    }
    
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        when (intent.action) {
            ACTION_NEXT_CITY -> {
                val widgetData = HomeWidgetPlugin.getData(context)
                val citiesJson = widgetData.getString("widget_cities_list", "[]") ?: "[]"
                val cities = parseCitiesFromJson(citiesJson)
                val currentIndex = widgetData.getInt("widget_current_index", 0)
                
                // Sonraki index'e geç
                val newIndex = (currentIndex + 1) % cities.size.coerceAtLeast(1)
                widgetData.edit().putInt("widget_current_index", newIndex).apply()
                
                // Tüm widget'ları güncelle
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val appWidgetIds = appWidgetManager.getAppWidgetIds(
                    intent.component ?: return
                )
                onUpdate(context, appWidgetManager, appWidgetIds)
            }
            ACTION_PREV_CITY -> {
                val widgetData = HomeWidgetPlugin.getData(context)
                val citiesJson = widgetData.getString("widget_cities_list", "[]") ?: "[]"
                val cities = parseCitiesFromJson(citiesJson)
                val currentIndex = widgetData.getInt("widget_current_index", 0)
                
                // Önceki index'e geç
                val size = cities.size.coerceAtLeast(1)
                val newIndex = if (currentIndex - 1 < 0) size - 1 else currentIndex - 1
                widgetData.edit().putInt("widget_current_index", newIndex).apply()
                
                // Tüm widget'ları güncelle
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val appWidgetIds = appWidgetManager.getAppWidgetIds(
                    intent.component ?: return
                )
                onUpdate(context, appWidgetManager, appWidgetIds)
            }
        }
    }
    
    data class CityData(
        val name: String,
        val temperature: String,
        val description: String,
        val humidity: String,
        val wind: String
    )
}
