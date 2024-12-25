import Foundation

struct WeatherModel: Identifiable, Equatable {
    let id = UUID()
    let cityName: String
    let temperature: String
    let weatherCondition: String
    let iconURL: String
    let humidity: String
    let uvIndex: String
    let feelsLike: String
    
    init(
        cityName: String,
        temperature: String,
        weatherCondition: String,
        iconURL: String,
        humidity: String,
        uvIndex: String,
        feelsLike: String
    ) {
        self.cityName = cityName
        self.temperature = temperature
        self.weatherCondition = weatherCondition
        self.iconURL = iconURL
        self.humidity = humidity
        self.uvIndex = uvIndex
        self.feelsLike = feelsLike
    }
    
    init(weather: WeatherAPIResponse) {
        cityName = weather.location.name
        temperature = "\(Int(weather.current.tempC))˚"
        weatherCondition = weather.current.condition.text
        iconURL = "https:\(weather.current.condition.icon)"
        humidity = String(weather.current.humidity)
        uvIndex = String(weather.current.uv)
        feelsLike = String(weather.current.feelslikeC)
    }
}
