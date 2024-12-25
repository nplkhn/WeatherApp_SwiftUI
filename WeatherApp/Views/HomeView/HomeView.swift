import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: AnyHomeViewModel
    
    var body: some View {
        GeometryReader { geometry in
            switch viewModel.viewState {
            case .initial:
                EmptyView()
            case .cityIsNotSelected:
                VStack {
                    Text("No City Selected")
                        .font(.theme.semibold(size: 30))
                        .foregroundStyle(Color(.defaultText))
                    Text("Please Search For A City")
                        .font(.theme.semibold(size: 15))
                        .foregroundStyle(Color(.defaultText))
                }
                .frame(
                    minWidth: geometry.size.width,
                    minHeight: geometry.size.height
                )
            case let .currentWeather(weather):
                CurrentWeatherView(weather: weather)
                    .frame(
                        minWidth: geometry.size.width,
                        minHeight: geometry.size.height
                    )
            case .searchInitiated:
                SearchListView(
                    weather: [],
                    select: { _ in }
                )
                .onTapGesture {
                    viewModel.showLastWeather()
                }
            case let .search(locationsWeather):
                SearchListView(
                    weather: locationsWeather,
                    select: {
                        viewModel.select(weather: $0)
                    }
                )
                
            case .error(let string):
                Text(string)
                    .font(.theme.semibold(size: 30))
                    .foregroundStyle(.red)
            }
        }
        .safeAreaInset(edge: .top) {
            SearchBarView(
                searchText: $viewModel.searchText,
                isPresented: $viewModel.isSearchPresented
            )
            .frame(alignment: .top)
        }
        .onAppear { viewModel.fetchWeather() }
        .animation(.smooth, value: viewModel.viewState)
        
    }
}

#Preview("City is not selected") {
    HomeView(
        viewModel: MockHomeViewModel(viewState: .cityIsNotSelected)
            .eraseToAnyHomeViewModel()
    )
}

#Preview("Current weather") {
    HomeView(
        viewModel: MockHomeViewModel(
            viewState: .currentWeather(
                WeatherModel(
                    cityName: "San Francisco",
                    temperature: "20°",
                    weatherCondition: "Partly Cloudy",
                    iconURL: "https://cdn.weatherapi.com/weather/64x64/day/116.png",
                    humidity: "65%",
                    uvIndex: "5.0",
                    feelsLike: "18.5°C"
                )
            )
        )
        .eraseToAnyHomeViewModel()
    )
}
