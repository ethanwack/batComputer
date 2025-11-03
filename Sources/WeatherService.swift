import Foundation
import Alamofire

class WeatherService {
    private let apiKey = "YOUR_OPENWEATHER_API_KEY" // You'll need to get an API key from OpenWeatherMap
    
    func getCurrentWeather(for city: String) async throws -> String {
        let url = "https://api.openweathermap.org/data/2.5/weather"
        let parameters: [String: String] = [
            "q": city,
            "appid": apiKey,
            "units": "metric"
        ]
        
        let response = try await AF.request(url, parameters: parameters)
            .serializingDecodable(WeatherResponse.self)
            .value
            
        return "Current weather in \(city): \(response.weather.first?.description ?? "unknown"), " +
               "temperature: \(Int(response.main.temp))°C"
    }
}

struct WeatherResponse: Decodable {
    let weather: [Weather]
    let main: Main
    
    struct Weather: Decodable {
        let description: String
    }
    
    struct Main: Decodable {
        let temp: Double
    }
}