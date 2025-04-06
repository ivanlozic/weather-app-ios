struct Weather: Decodable {
    struct Main: Decodable {
        let temp: Double
        let pressure: Int
        let humidity: Int
        let tempMin: Double
        let tempMax: Double
        let feelsLike: Double

        private enum CodingKeys: String, CodingKey {
            case temp, pressure, humidity
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case feelsLike = "feels_like"
        }
    }

    struct Wind: Decodable {
        let speed: Double
        let deg: Double?
    }

    struct WeatherInfo: Decodable {
        let main: String
        let description: String
        let icon: String
    }

    let main: Main
    let wind: Wind
    let weather: [WeatherInfo]
    let name: String
}
