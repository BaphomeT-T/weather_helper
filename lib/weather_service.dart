import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // API gratuita de Open-Meteo (no requiere API key)
  
  Future<Map<String, dynamic>> getWeather(String city) async {
    try {
      // Primero obtenemos las coordenadas de la ciudad
      final geoUrl = 'https://geocoding-api.open-meteo.com/v1/search?name=$city&count=1&language=es&format=json';
      final geoResponse = await http.get(Uri.parse(geoUrl));
      
      if (geoResponse.statusCode == 200) {
        final geoData = json.decode(geoResponse.body);
        
        if (geoData['results'] == null || geoData['results'].isEmpty) {
          throw Exception('Ciudad no encontrada');
        }

        final lat = geoData['results'][0]['latitude'];
        final lon = geoData['results'][0]['longitude'];
        final cityName = geoData['results'][0]['name'];
        final country = geoData['results'][0]['country'] ?? '';

        // Obtenemos el clima actual
        final weatherUrl = 'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&timezone=auto';
        final weatherResponse = await http.get(Uri.parse(weatherUrl));

        if (weatherResponse.statusCode == 200) {
          final weatherData = json.decode(weatherResponse.body);
          return {
            'city': cityName,
            'country': country,
            'temperature': weatherData['current_weather']['temperature'],
            'windspeed': weatherData['current_weather']['windspeed'],
            'weathercode': weatherData['current_weather']['weathercode'],
          };
        } else {
          throw Exception('Error al obtener el clima');
        }
      } else {
        throw Exception('Error al buscar la ciudad');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  String getWeatherDescription(int code) {
    if (code == 0) return '☀️ Despejado';
    if (code <= 3) return '⛅ Parcialmente nublado';
    if (code <= 48) return '🌫️ Niebla';
    if (code <= 67) return '🌧️ Lluvia';
    if (code <= 77) return '🌨️ Nieve';
    if (code <= 99) return '⛈️ Tormenta';
    return '🌤️ Clima variable';
  }
}
