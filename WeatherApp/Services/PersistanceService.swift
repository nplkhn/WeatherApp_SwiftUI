import Foundation

protocol PersistenceService {
    func fetchLastCity() -> String?
    func saveLastCity(_ city: String)
}

class RealPersistenceService: PersistenceService {
    private let cityKey = "savedCity"
    
    func fetchLastCity() -> String? {
        return UserDefaults.standard.string(forKey: cityKey)
    }
    
    func saveLastCity(_ city: String) {
        UserDefaults.standard.set(city, forKey: cityKey)
    }
}

class MockPersistenceService: PersistenceService {
    private var city: String?
    
    init(city: String?) {
        self.city = city
    }
    
    func fetchLastCity() -> String? {
        return city
    }
    
    func saveLastCity(_ city: String) {
        self.city = city
    }
}
