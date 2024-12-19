//
//  WeatherViewModel.swift
//  Nooro_Weather
//
//  Created by Brian Novie on 12/17/24.
//

import Foundation

enum WeatherAction {
    case firstAppear(lat: Double? = nil, lon: Double? = nil)
    case search(String)
    case currentWeather(WeatherModel)
}

protocol ActionHandlerProtocol {
    @MainActor
    func perform(action: WeatherAction) async
}

final class WeatherViewModel: ObservableObject {
    enum State {
        case initial
        case search([WeatherModel])
        case loading
        case weatherLoaded(WeatherModel)
        case error(Error)
    }

    @Published private(set) var state: State = .initial
    private let service = WeatherService()

    @MainActor
    func fetchWeather(latitude: Double, longitude: Double) async {
        state = .loading
        do {
            let weather: WeatherModel = try await service.fetchCurrent(latitude: latitude, longitude: longitude)
            state = .weatherLoaded(weather)
        } catch {
            state = .error(error)
        }
    }
    
    @MainActor
    func search(_ searchTerm: String) async {
        state = .loading
        do {
            let locations = try await service.fetchLocation(term: searchTerm)
            
            var weatherLocations: [WeatherModel] = []
            
            for location in locations {
                if let weather = await fetchWeatherForSearch(latitude: location.lat, longitude: location.lon) {
                    weatherLocations.append(weather)
                }
            }
            state = .search(weatherLocations)
        } catch {
            state = .error(error)
        }
    }
    
    @MainActor
    private func fetchWeatherForSearch(latitude: Double, longitude: Double) async -> WeatherModel? {
        state = .loading
        do {
            let weather: WeatherModel = try await service.fetchCurrent(latitude: latitude, longitude: longitude)
            return weather
        } catch {
            return nil
        }
    }


}

extension WeatherViewModel: ActionHandlerProtocol {
    @MainActor
    func perform(action: WeatherAction) async {
        switch action {
        case .firstAppear:
            // read defaults for last lat and lon
            // Persistance could be its own class so we have an abstraction
            if let latObj = UserDefaults.standard.string(forKey: "last-lat"),
               let lonObj = UserDefaults.standard.string(forKey: "last-lon"),
               let lat = Double(latObj),
               let lon = Double(lonObj)
            {
                await fetchWeather(latitude: lat, longitude: lon)
            }
        case .currentWeather(let model):
            state = .weatherLoaded(model)
            UserDefaults.standard.set(model.location.lat, forKey: "last-lat")
            UserDefaults.standard.set(model.location.lon, forKey: "last-lon")
        case .search(let term):
            await search(term)
        }
    }    
}

extension WeatherModel: Identifiable, Hashable {
    static func == (lhs: WeatherModel, rhs: WeatherModel) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: [String: Double] {
        // lat and lon in a dictionary
        ["lat": location.lat, "lon": location.lon]
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(location.lat)
        hasher.combine(location.lon)
    }
}

protocol WeatherDisplayLogic {
    var weatherURL: URL? { get }
    var tempString: String { get }
    var humidityString: String { get }
    var uvString: String { get }
    var feelLikeString: String { get }
    var locationName: String { get }
    var locationFullName: String { get }
}

extension WeatherModel: WeatherDisplayLogic {
    var weatherURL: URL? {
        URL(string: "https:" + current.condition.icon)
    }
    
    var tempString: String {
        String(format: "%.0fº", current.tempF)
    }
    
    var humidityString: String {
        String(format: "%.0f%", current.humidity)
    }
    
    var uvString: String {
        String(format: "%.0f", current.uv)
    }
    
    var feelLikeString: String {
        String(format: "%.0fº", current.feelslikeF)
    }
    
    var locationName: String {
        location.name
    }
    
    // Use state is US, country elsewhere
    var locationFullName: String {
        isUSA ? "\(location.name), \(location.region ?? "")" : "\(location.name), \(location.country)"
    }
    
    private var isUSA: Bool {
        location.country == "United States of America"
    }
}
