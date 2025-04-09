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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialUI()
        fetchWeatherData()
    }
    
    @IBAction func temperatureUnitChanged(_ sender: Any) {
        isCelsius = tempUnitSegmentedControl.selectedSegmentIndex == 0
    }
    
    @IBAction func saveWeatherButtonTapped(_ sender: Any) {
        saveWeatherData()
    }
    
    private func setupInitialUI() {
        cityNameLabel.text = city ?? WeatherConstants.Defaults.unknownCity
    }
    
    private func fetchWeatherData() {
        guard let lat = latitude, let lon = longitude else {
            showError(message: WeatherConstants.Alerts.Messages.invalidCoordinates)
            return
        }

        WeatherService.fetchWeather(lat: lat, lon: lon) { [weak self] weather in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if let weather = weather {
                    self.weatherData = weather
                    self.updateWeatherUI(with: weather)
                } else {
                    self.showError(message: WeatherConstants.Alerts.Messages.fetchFailed)
                }
            }
        }
    }
    
    private func saveWeatherData() {
        guard let city = city, let weather = weatherData else {
            showError(message: WeatherConstants.Alerts.Messages.missingData)
            return
        }
        
        CoreDataManager.shared.saveForecast(
            city: city,
            temperature: weather.main.temp,
            date: Date()
        )
        
        showAlert(
            title: WeatherConstants.Alerts.successTitle,
            message: WeatherConstants.Alerts.Messages.saveSuccess
        )
    }

    private func celsiusToFahrenheit(_ celsius: Double) -> Double {
        return celsius * 9/5 + 32
    }
    
    private func updateTemperatureDisplay() {
        guard let weather = weatherData else { return }
        
        let temp = isCelsius ? weather.main.temp : celsiusToFahrenheit(weather.main.temp)
        let feelsLikeTemp = isCelsius ? weather.main.feelsLike : celsiusToFahrenheit(weather.main.feelsLike)
        let unitSymbol = isCelsius ? WeatherConstants.Temperature.celsiusSymbol : WeatherConstants.Temperature.fahrenheitSymbol
        
        currentTempLabel.text = String(format: WeatherConstants.Format.temperature, temp, unitSymbol)
        feelsLikeTempLabel.text = String(format: WeatherConstants.Format.temperature, feelsLikeTemp, unitSymbol)
    }
    
    private func updateWeatherUI(with weather: Weather) {
        updateTemperatureDisplay()
        
        guard let weatherInfo = weather.weather.first else { return }
        
        weatherDescLabel.text = weatherInfo.description.capitalized
        loadWeatherIcon(iconCode: weatherInfo.icon)
        windSpeedValueLabel.text = String(format: WeatherConstants.Format.windSpeed, weather.wind.speed)
        humidityValueLabel.text = String(format: WeatherConstants.Format.humidity, weather.main.humidity)
        cityNameLabel.text = weather.name.isEmpty ? WeatherConstants.Defaults.unknownCity : weather.name
    }
    
    private func loadWeatherIcon(iconCode: String) {
        guard let url = WeatherConstants.API.weatherIconURL(for: iconCode) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
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
        showAlert(
            title: WeatherConstants.Alerts.errorTitle,
            message: message,
            isError: true
        )
    }
    
    private func showAlert(title: String, message: String, isError: Bool = false) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: WeatherConstants.Alerts.okButton,
            style: isError ? .destructive : .default
        )
        alert.addAction(action)
        present(alert, animated: true)
    }
}
