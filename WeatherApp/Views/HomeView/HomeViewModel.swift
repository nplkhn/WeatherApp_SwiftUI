import SwiftUI
import Combine

protocol CurrentWeatherViewModel: ObservableObject {
    var weather: WeatherModel? { get }
}

protocol SearchListViewModel: ObservableObject {
    var results: [WeatherModel] { get }
    
    func showLastWeather()
    func select(weather: WeatherModel)
}

enum HomeViewState: Equatable {
    case initial
    case cityIsNotSelected
    case currentWeather(WeatherModel)
    case searchInitiated
    case search([WeatherModel])
    case error(String)
}

protocol HomeViewModel: ObservableObject {
    var viewState: HomeViewState { get }
    var searchText: String { get set }
    var isSearchPresented: Bool { get set }
    
    func showLastWeather()
    func select(weather: WeatherModel)
    func fetchWeather()
}

extension HomeViewModel {
    func eraseToAnyHomeViewModel() -> AnyHomeViewModel {
        AnyHomeViewModel(self)
    }
}

class AnyHomeViewModel: HomeViewModel {
    var viewState: HomeViewState {
        viewStateGet()
    }
    
    var searchText: String {
        get { searchTextGet() }
        set { searchTextSet(newValue) }
    }
    
    var isSearchPresented: Bool {
        get { isSearchPresentedGet() }
        set { isSearchPresentedSet(newValue) }
    }
    
    private let viewStateGet: () -> HomeViewState
    private let searchTextGet: () -> String
    private let searchTextSet: (String) -> Void
    private let isSearchPresentedGet: () -> Bool
    private let isSearchPresentedSet: (Bool) -> Void
    private let _showLastWeather: () -> Void
    private let _select: (WeatherModel) -> Void
    private let _fetchWeather: () -> Void
    
    private var objectWillChangeCancellable: AnyCancellable?
    
    init<T: HomeViewModel>(_ viewModel: T) {
        viewStateGet = { viewModel.viewState }
        searchTextGet = { viewModel.searchText }
        searchTextSet = { viewModel.searchText = $0 }
        isSearchPresentedGet = { viewModel.isSearchPresented }
        isSearchPresentedSet = { viewModel.isSearchPresented = $0 }
        _showLastWeather = { viewModel.showLastWeather() }
        _select = { viewModel.select(weather: $0) }
        _fetchWeather = { viewModel.fetchWeather() }
        
        objectWillChangeCancellable = viewModel.objectWillChange
            .sink{ [weak self] _ in
                self?.objectWillChange.send()
            }
    }
    
    func showLastWeather() {
        _showLastWeather()
    }
    
    func select(weather: WeatherModel) {
        _select(weather)
    }
    
    func fetchWeather() {
        _fetchWeather()
    }
    
    
}

class RealHomeViewModel: HomeViewModel {
    // Public properties
    @Published var searchText = ""
    @Published var isSearchPresented = false
    @Published var viewState = HomeViewState.initial
    
    // Dependencies
    private var weatherService: WeatherService
    private var persistenceService: PersistenceService
    
    private var cancellables = Set<AnyCancellable>()
    private var cachedCurrentWeather: WeatherModel?
    private var currentSearchTask: Task<Void, Error>?
    
    init(
        weatherService: WeatherService = RealWeatherService(),
        persistenceService: PersistenceService = RealPersistenceService()
    ) {
        self.weatherService = weatherService
        self.persistenceService = persistenceService
        
        setupSubscriptions()
    }
    
    func fetchWeather() {
        guard let city = persistenceService.fetchLastCity() else {
            viewState = .cityIsNotSelected
            return
        }
        
        Task { [weak self] in
            let possibleWeatherResponse = try? await self?.weatherService.fetchWeather(for: city)
            
            await MainActor.run { [weak self] in
                guard let weatherResponse = possibleWeatherResponse else {
                    self?.viewState = .error("Unable to fetch weather. Please try again.")
                    return
                }
                let weather = WeatherModel(weather: weatherResponse)
                
                self?.cachedCurrentWeather = weather
                self?.viewState = .currentWeather(weather)
            }
        }
    }
    
    @MainActor func showLastWeather() {
        guard let cachedCurrentWeather else {
            viewState = .cityIsNotSelected
            return
        }
        
        select(weather: cachedCurrentWeather)
    }
    
    @MainActor func select(weather: WeatherModel) {
        persistenceService.saveLastCity(weather.cityName)
        cachedCurrentWeather = weather
        viewState = .currentWeather(weather)
        searchText = ""
        isSearchPresented = false
    }
}

private extension RealHomeViewModel {
    func setupSubscriptions() {
        $searchText
            .combineLatest($isSearchPresented)
            .dropFirst()
            .filter { searchText, isSearchPresented in isSearchPresented && searchText.count >= 3 }
            .map { searchText, _ in searchText }
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                self?.currentSearchTask?.cancel()
                self?.currentSearchTask = Task { [weak self] in
                    guard let self else { return }
                    
                    let locations = try await self.weatherService.search(city: searchText)
                    let results = try await fetchWeather(locations: locations)
                    
                    try Task.checkCancellation()
                    
                    await MainActor.run { [weak self] in
                        self?.viewState = .search(results)
                        self?.currentSearchTask = nil
                    }
                }
            }
            .store(in: &cancellables)
        
        $isSearchPresented
            .dropFirst()
            .sink { [weak self] isSearchPresented in
                if isSearchPresented {
                    self?.viewState = .searchInitiated
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchWeather(locations: [LocationAPIResponse]) async throws -> [WeatherModel] {
        try await withThrowingTaskGroup(of: WeatherAPIResponse?.self) { [weak self] group in
            for location in locations {
                try Task.checkCancellation()
                group.addTask { [weak self] in
                    try await self?.weatherService.fetchWeather(lat: location.lat, lon: location.lon)
                }
            }
            
            var results = [WeatherModel]()
            for try await result in group {
                result.map { results.append(WeatherModel(weather: $0)) }
            }
            
            return results
        }
    }
}

class MockHomeViewModel: HomeViewModel {
    var viewState: HomeViewState
    var searchText: String = ""
    var isSearchPresented: Bool = false
    
    init(viewState: HomeViewState) {
        self.viewState = viewState
    }
    
    func showLastWeather() { }
    
    func select(weather: WeatherModel) { }
    
    func fetchWeather() { }
}
