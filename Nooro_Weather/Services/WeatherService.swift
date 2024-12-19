//
//  WeatherService.swift
//  Nooro_Weather
//
//  Created by Brian Novie on 12/17/24.
//

import Foundation

private let apiKey = "3ac438f7416749099df221107241712"
private let base = "https://api.weatherapi.com/v1"
private let currentPath = "/current.json"
private let searchPath = "/search.json"
private let forecastPath = "forecast.json" // not used

enum Endpoint {
    case search(term: String)
    case current(lat: Double, lon: Double)
    
    var url: URL? {
        var urlString: String
        switch self {
        case .search(let term):
            urlString = base + searchPath + "?key=\(apiKey)" + "&q=\(term)"
        case .current(let lat, let lon):
            urlString = base + currentPath + "?key=\(apiKey)" + "&q=\(lat),\(lon)"
        }
        return URL(string: urlString)
    }
}

final class WeatherService {
    func fetch<T: Decodable>(from endpoint: Endpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw NSError(domain: "Mine", code: 1001)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            print(response)
            if httpResponse.statusCode != 200 {
                // This is where we could handle error or throw it
            }
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(T.self, from: data)
    }

    func fetchCurrent(latitude: Double, longitude: Double) async throws -> WeatherModel {
        return try await fetch(from: .current(lat: latitude, lon: longitude))
    }
    
    func fetchLocation(term: String) async throws -> [LocationModel] {
        return try await fetch(from: .search(term: term))
    }
    
}

