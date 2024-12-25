import SwiftUI

struct SearchListRowItem: View {
    private let weather: WeatherModel
    
    init(weather: WeatherModel) {
        self.weather = weather
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(weather.cityName)
                    .font(.theme.bold(size: 20))
                Text(weather.temperature)
                    .font(.theme.medium(size: 60))
            }
            Spacer()
            AsyncImage(url: URL(string: weather.iconURL)) { image in
                image
            } placeholder: {
                ProgressView()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.background))
        )
    }
}

#Preview {
    SearchListRowItem(
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
