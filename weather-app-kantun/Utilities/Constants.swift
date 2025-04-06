import Foundation

enum Constants {
    enum API {
        static let baseURL = "https://api.openweathermap.org/data/2.5"
        static let weatherEndpoint = "/weather"
        static let apiKey = Bundle.main.object(forInfoDictionaryKey: "WeatherAPIKey") as? String ?? ""
    }
}

