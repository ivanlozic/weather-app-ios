import UIKit

class WeatherDetailsViewController: UIViewController {
    
    var city: String?
    var longitude: Double?
    var latitude: Double?
    private var weatherData: Weather?
    private var isCelsius = true {
        didSet {
            updateTemperatureDisplay()
        }
    }
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var weatherDescLabel: UILabel!
    @IBOutlet weak var feelsLikeTempLabel: UILabel!
    @IBOutlet weak var windSpeedValueLabel: UILabel!
    @IBOutlet weak var humidityValueLabel: UILabel!
    @IBOutlet weak var weatherIconImage: UIImageView!
    @IBOutlet weak var tempUnitSegmentedControl: UISegmentedControl!
    @IBOutlet weak var saveWeatherButton: UIButton!
    
    
    private enum Constants {
        static let weatherIconURL = "https://openweathermap.org/img/wn/"
        static let errorTitle = "Error"
        static let successTitle = "Success"
        static let saveSuccessMessage = "Weather saved successfully!"
        static let saveFailureMessage = "Failed to save weather data"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchWeatherData()
    }
    
    private func setupUI() {
        cityNameLabel.text = city ?? "Unknown City"
        tempUnitSegmentedControl.setTitle("°C", forSegmentAt: 0)
        tempUnitSegmentedControl.setTitle("°F", forSegmentAt: 1)
        tempUnitSegmentedControl.selectedSegmentIndex = 0
        tempUnitSegmentedControl.addTarget(self, action: #selector(temperatureUnitChanged), for: .valueChanged)
    }
    
    @objc private func temperatureUnitChanged() {
        isCelsius = tempUnitSegmentedControl.selectedSegmentIndex == 0
    }
    
    private func fetchWeatherData() {
        guard let lat = latitude, let lon = longitude else {
            showError(message: "Invalid location coordinates")
            return
        }

        WeatherService.fetchWeather(lat: lat, lon: lon) { [weak self] weather in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if let weather = weather {
                    self.weatherData = weather
                    self.updateWeatherUI(with: weather)
                } else {
                    self.showError(message: "Failed to fetch weather data")
                }
            }
        }
    }

    
    private func celsiusToFahrenheit(_ celsius: Double) -> Double {
        return celsius * 9/5 + 32
    }
    
    private func updateTemperatureDisplay() {
        guard let weather = weatherData else { return }
        
        let temp: Double
        let feelsLikeTemp: Double
        
        if isCelsius {
            temp = weather.main.temp
            feelsLikeTemp = weather.main.feelsLike
        } else {
            temp = celsiusToFahrenheit(weather.main.temp)
            feelsLikeTemp = celsiusToFahrenheit(weather.main.feelsLike)
        }
        
        currentTempLabel.text = String(format: "Temperature: %.1f%@", temp, isCelsius ? "°C" : "°F")
        feelsLikeTempLabel.text = String(format: "Feels like: %.1f%@", feelsLikeTemp, isCelsius ? "°C" : "°F")
    }
    
    private func updateWeatherUI(with weather: Weather) {
        updateTemperatureDisplay()
        
        guard let weatherInfo = weather.weather.first else { return }
        
        weatherDescLabel.text = weatherInfo.description.capitalized
        loadWeatherIcon(iconCode: weatherInfo.icon)
        windSpeedValueLabel.text = String(format: "Wind: %.1f m/s", weather.wind.speed)
        humidityValueLabel.text = String(format: "Humidity: %d%%", weather.main.humidity)
        cityNameLabel.text = weather.name.isEmpty ? "Unknown City" : weather.name
    }
    
    private func loadWeatherIcon(iconCode: String) {
        let iconUrl = Constants.weatherIconURL + "\(iconCode)@2x.png"
        
        guard let url = URL(string: iconUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  error == nil,
                  let image = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                self.weatherIconImage.image = image
            }
        }.resume()
    }

    private func showError(message: String) {
        showAlert(title: Constants.errorTitle, message: message, isError: true)
    }
    
    private func showAlert(title: String, message: String, isError: Bool = false) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: isError ? .destructive : .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    @IBAction func saveWeatherButtonTapped(_ sender: Any) {
        guard let city = city, let weather = weatherData else {
            showAlert(title: Constants.errorTitle, message: "City or weather data is missing", isError: true)
            return
        }
        
        saveWeatherData(city: city, weather: weather)
    }
    
    private func saveWeatherData(city: String, weather: Weather) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let newWeatherRecord = Forecast(context: context)
        
        newWeatherRecord.cityName = city
        newWeatherRecord.temperature = weather.main.temp
        newWeatherRecord.windSpeed = weather.wind.speed
        newWeatherRecord.date = Date()
        
        do {
            try context.save()
            showAlert(title: Constants.successTitle, message: Constants.saveSuccessMessage)
        } catch {
            showAlert(title: Constants.errorTitle, message: Constants.saveFailureMessage, isError: true)
        }
    }
}
