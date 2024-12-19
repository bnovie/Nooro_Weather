//
//  ContentView.swift
//  Nooro_Weather
//
//  Created by Brian Novie on 12/17/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var weather: WeatherViewModel = WeatherViewModel()
    var body: some View {
        NavigationStack {
            WeatherView()
        }
    }
}

#Preview {
    ContentView()
}
