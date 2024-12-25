import SwiftUI
import Combine

struct SearchListView: View {
    private let weather: [WeatherModel]
    private let select: (WeatherModel) -> Void
    
    init(
        weather: [WeatherModel],
        select: @escaping (WeatherModel) -> Void
    ) {
        self.weather = weather
        self.select = select
    }
    
    var body: some View {
        List(weather) { weather in
            SearchListRowItem(weather: weather)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .onTapGesture {
                    select(weather)
                }
        }
        .listStyle(.plain)
        .listRowSpacing(8)
        .padding(.horizontal, 8)
    }
}


#Preview {
    SearchListView(
        weather: [
            WeatherModel(
                cityName: "San Francisco",
                temperature: "20°C",
                weatherCondition: "Partly Cloudy",
                iconURL: "https://cdn.weatherapi.com/weather/64x64/day/116.png",
                humidity: "65%",
                uvIndex: "5.0",
                feelsLike: "18.5°C"
            ),
            WeatherModel(
                cityName: "New York",
                temperature: "20°C",
                weatherCondition: "Partly Cloudy",
                iconURL: "https://cdn.weatherapi.com/weather/64x64/day/116.png",
                humidity: "65%",
                uvIndex: "5.0",
                feelsLike: "18.5°C"
            ),
            WeatherModel(
                cityName: "Chicago",
                temperature: "20°C",
                weatherCondition: "Partly Cloudy",
                iconURL: "https://cdn.weatherapi.com/weather/64x64/day/116.png",
                humidity: "65%",
                uvIndex: "5.0",
                feelsLike: "18.5°C"
            )
            
        ],
        select: { print($0) }
    )
}


