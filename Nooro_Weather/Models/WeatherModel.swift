//
//  WeatherModel.swift
//  Nooro_Weather
//
//  Created by Brian Novie on 12/17/24.
//
import Foundation

struct LocationModel: Decodable {
    let lat: Double
    let lon: Double
    let name: String
    let region: String?
    let country: String
}

struct WeatherModel: Decodable {
    let current: CurrentWeatherModel
    let location: LocationModel
}

struct CurrentWeatherModel: Decodable {
    let lastUpdated: String
    let lastUpdatedEpoch: Date
    let tempF: Double
    let feelslikeF: Double
    let humidity: Double
    let uv: Double
    let condition: WeatherCondition
}


struct WeatherCondition: Decodable {
    let text: String
    let icon: String
    let code: Int
}
