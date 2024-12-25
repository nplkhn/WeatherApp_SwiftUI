import SwiftUI

struct CurrentWeatherView: View {
    private let weather: WeatherModel
    
    init(weather: WeatherModel) {
        self.weather = weather
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 24) {
                AsyncImage(url: URL(string: weather.iconURL)!) { phase in
                    switch phase {
                    case .empty:
                        Text("Couldn't load image")
                    case .success(let image):
                        image
                    case .failure(let error):
                        Text(error.localizedDescription)
                    default:
                        EmptyView()
                    }
                }
                
                Text(weather.cityName)
                    .font(.system(size: 30, weight: .semibold))
                Text("\(weather.temperature)")
                    .font(.system(size: 70))
            }
            HStack(spacing: 56) {
                Group {
                    VStack(spacing: 2) {
                        Text("Humidity")
                            .font(.system(size: 12))
                        Text("\(weather.humidity)%")
                            .font(.system(size: 15))
                    }
                    .padding(.all, 0)
                    VStack(spacing: 2) {
                        Text("UV")
                            .font(.system(size: 12))
                        Text("\(weather.uvIndex)")
                            .font(.system(size: 15))
                    }
                    .padding(.all, 0)
                    VStack(spacing: 2) {
                        Text("Feels Like")
                            .font(.system(size: 12))
                        Text("\(weather.feelsLike)°")
                            .font(.system(size: 15))
                    }
                    .padding(.all, 0)
                }
                .padding(.all, 16)
            }
            .background(Color(.background))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct WeatherDetailView: View {
    let label: String
    let value: String

    var body: some View {
        VStack {
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentWeatherView(
            weather: WeatherModel(
                cityName: "San Francisco",
                temperature: "20°C",
                weatherCondition: "Partly Cloudy",
                iconURL: "https://cdn.weatherapi.com/weather/64x64/day/116.png",
                humidity: "65%",
                uvIndex: "5.0",
                feelsLike: "18.5°C"
            )
        )
    }
}
