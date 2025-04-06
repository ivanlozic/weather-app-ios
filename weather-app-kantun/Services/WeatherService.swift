import Foundation
import UIKit

class WeatherService {
    private static var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "WeatherAPIKey") as? String else {
            fatalError("❌ Weather API key not found in Info.plist")
        }
        return key
    }

    static func fetchWeather(lat: Double, lon: Double, completion: @escaping (Weather?) -> Void) {
        let urlString = "\(Constants.API.baseURL)\(Constants.API.weatherEndpoint)?lat=\(lat)&lon=\(lon)&appid=\(Constants.API.apiKey)&units=metric"
        fetchWeatherData(from: urlString, completion: completion)
    }
    
    private static func fetchWeatherData(from urlString: String, completion: @escaping (Weather?) -> Void) {
        guard let url = URL(string: urlString) else {
            showAlert(message: "Invalid URL")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                showAlert(message: "Error fetching weather data: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                showAlert(message: "No data received")
                completion(nil)
                return
            }
            
            do {
                let weather = try JSONDecoder().decode(Weather.self, from: data)
                DispatchQueue.main.async {
                    completion(weather)
                }
            } catch {
                showAlert(message: "Failed to decode weather data")
                completion(nil)
            }
        }.resume()
    }
    
    private static func showAlert(message: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
            return
        }
    
        if let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }
}
