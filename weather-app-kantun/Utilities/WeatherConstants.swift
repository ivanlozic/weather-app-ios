
import Foundation

struct WeatherConstants {
    struct API {
        static let weatherIconBaseURL = "https://openweathermap.org/img/wn/"
        static let iconSuffix = "@2x.png"
        
        static func weatherIconURL(for iconCode: String) -> URL? {
            return URL(string: weatherIconBaseURL + iconCode + iconSuffix)
        }
    }
    
    struct Alerts {
        static let errorTitle = "Error"
        static let successTitle = "Success"
        static let okButton = "OK"
        
        struct Messages {
            static let invalidCoordinates = "Invalid location coordinates"
            static let fetchFailed = "Failed to fetch weather data"
            static let missingData = "City or weather data is missing"
            static let saveSuccess = "Weather saved successfully!"
            static let saveFailure = "Failed to save weather data"
        }
    }
    
    struct Format {
        static let temperature = "%.1f%@"
        static let windSpeed = "Wind: %.1f m/s"
        static let humidity = "Humidity: %d%%"
    }
    
    struct Defaults {
        static let unknownCity = "Unknown City"
    }
    
    struct Temperature {
        static let celsiusSymbol = "°C"
        static let fahrenheitSymbol = "°F"
    }
}
