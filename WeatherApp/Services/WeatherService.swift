import Foundation

enum WeatherServiceError: Error {
    case invalidURL
    case decodingError
    case networkError
}

protocol WeatherService {
    func search(city: String) async throws -> [LocationAPIResponse]
    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherAPIResponse
    func fetchWeather(for city: String) async throws -> WeatherAPIResponse
}

private enum WeatherAPI {
    case currentWithCity(city: String)
    case currentWithLatLon(lat: Double, lon: Double)
    case search(query: String)
    
    var path: String {
        switch self {
        case .currentWithCity, .currentWithLatLon:
            return "current.json"
        case .search:
            return "search.json"
        }
    }
    
    var urlParameters: String {
        switch self {
        case let .currentWithCity(city):
            return "q=\(city)"
        case let .currentWithLatLon(lat, lon):
            return "q=\(lat),\(lon)"
        case let .search(query):
            return "q=\(query)"
        }
    }
}

// MARK: - RealWeatherService
class RealWeatherService: WeatherService {
    private let apiKey = "API_KEY"
    private let baseURL = "https://api.weatherapi.com/v1/"
    private let session = URLSession.shared
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return decoder
    }()
    
    private func fetch<Output: Decodable>(endpoint: WeatherAPI) async throws -> Output {
        let urlString = "\(baseURL)\(endpoint.path)?key=\(apiKey)&\(endpoint.urlParameters)"
        guard let url = URL(string: urlString) else { throw WeatherServiceError.invalidURL }
        
        do {
            let (data, _) = try await session.data(from: url)
            return try decoder.decode(Output.self, from: data)
        } catch is DecodingError {
            throw WeatherServiceError.decodingError
        } catch  {
            throw WeatherServiceError.networkError
        }
    }
    
    func fetchWeather(for city: String) async throws -> WeatherAPIResponse {
        try await fetch(endpoint: .currentWithCity(city: city))
    }
    
    func search(city query: String) async throws -> [LocationAPIResponse] {
        try await fetch(endpoint: .search(query: query))
    }
    
    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherAPIResponse {
        try await fetch(endpoint: .currentWithLatLon(lat: lat, lon: lon))
    }
}

class MockWeatherService: WeatherService {
    func search(city: String) async throws -> [LocationAPIResponse] {
        [
            LocationAPIResponse(
                id: 1,
                name: "San Francisco",
                lat: 37.7749,
                lon: -122.4194
            ),
            LocationAPIResponse(
                id: 1,
                name: "New York",
                lat: 37.7749,
                lon: -122.4194
            ),
            LocationAPIResponse(
                id: 1,
                name: "Chicago",
                lat: 37.7749,
                lon: -122.4194
            )
        ]
    }
    
    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherAPIResponse {
        WeatherAPIResponse(
            location: WeatherAPIResponse.Location(
                name: "San Francisco",
                lat: 37.7749,
                lon: -122.4194
            ),
            current: WeatherAPIResponse.Current(
                tempC: 20.0,
                feelslikeC: 18.5,
                condition: WeatherAPIResponse.Current.Condition(
                    text: "Partly Cloudy",
                    icon: "//cdn.weatherapi.com/weather/64x64/day/116.png"
                ),
                humidity: 65,
                uv: 5.0
            )
        )
    }
    
    func fetchWeather(for city: String) async throws -> WeatherAPIResponse {
        WeatherAPIResponse(
            location: WeatherAPIResponse.Location(
                name: "San Francisco",
                lat: 37.7749,
                lon: -122.4194
            ),
            current: WeatherAPIResponse.Current(
                tempC: 20.0,
                feelslikeC: 18.5,
                condition: WeatherAPIResponse.Current.Condition(
                    text: "Partly Cloudy",
                    icon: "//cdn.weatherapi.com/weather/64x64/day/116.png"
                ),
                humidity: 65,
                uv: 5.0
            )
        )
    }
}

struct WeatherAPIResponse: Decodable {
    let location: Location
    let current: Current

    struct Current: Decodable {
        let tempC: Double
        let feelslikeC: Double
        let condition: Condition
        let humidity: Int
        let uv: Double

        struct Condition: Decodable {
            let text: String
            let icon: String
        }
    }
    
    struct Location: Decodable {
        let name: String
        let lat: Double
        let lon: Double
    }
}

struct LocationAPIResponse: Decodable {
    let id: UInt
    let name: String
    let lat: Double
    let lon: Double
}
