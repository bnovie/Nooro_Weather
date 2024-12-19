//
//  WeatherView.swift
//  Nooro_Weather
//
//  Created by Brian Novie on 12/18/24.
//

import SwiftUI

struct WeatherView: View {
    @Environment(\.colorScheme) var colorScheme // used to change to dark mode
    @ScaledMetric(relativeTo: .largeTitle) var imageSize = 123.0 // used for dynamic type changes
    @ScaledMetric(relativeTo: .title) var stackHeight = 75.0
    @State var searchTerm: String = ""
    @State var selection: [String: Double]?

    @StateObject var weather: WeatherViewModel = WeatherViewModel()
    var body: some View {
        Group {
            switch weather.state {
            case .initial:
                noLocationView
            case .search(let weatherList):
                searchListView(cityWeatherList: weatherList)
            case .loading:
                Text("Loading")
            case .weatherLoaded(let currentWeather):
                cityWeatherView(cityWeather: currentWeather)
            case .error:
                Text("Something went wrong, try again")
            }
        }
        .searchable(text: $searchTerm, prompt: "Search Location")
        .onSubmit(of: .search) {
            Task {
                await weather.perform(action: .search(searchTerm))
            }
        }
        .task {
            await weather.perform(action: .firstAppear())
        }
    }
}

private extension WeatherView { //helper views
    func asyncImage(_ url: URL?, size: CGFloat = 40) -> some View {
        AsyncImage(url: url) { image in
            image.resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            EmptyView()
        }
        .frame(width: size, height: size)
    }

    var noLocationView: some View {
        VStack {
            Text("No City Selected")
                .font(.custom("Poppins", size: 30, relativeTo: .title))
                .fontWeight(.semibold)
            Text("Please Search For A City")
                .font(.custom("Poppins", size: 15, relativeTo: .body))
                .fontWeight(.semibold)
        }
        .foregroundColor(mainTextColor)
    }
    
    func searchListView(cityWeatherList: [WeatherModel]) -> some View {
        List(cityWeatherList, selection: $selection) { cityWeather in
            cityListItem(cityWeather: cityWeather)
        }
        .onChange(of: selection) {
            if let lat = selection?["lat"], let lon = selection?["lon"],
               let selectedCityWeather = cityWeatherList.first(where: {$0.location.lat == lat && $0.location.lon == lon}) {
                
                Task {
                    await weather.perform(action: .currentWeather(selectedCityWeather))
                }
            }
        }
    }
    func cityListItem(cityWeather: WeatherDisplayLogic) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(cityWeather.locationFullName)
                    .font(.custom("Poppins", size: 20, relativeTo: .title))
                    .fontWeight(.semibold)
                Text(cityWeather.tempString)
                    .font(.custom("Poppins", size: 60, relativeTo: .title))
                    .fontWeight(.medium)
            }
            .foregroundColor(mainTextColor)
            Spacer()
            asyncImage(cityWeather.weatherURL, size: 80)
        }
        .cornerRadius(15)
        .foregroundStyle(mainTextColor)
        .listRowBackground(infoBackgroundColor)
    }

    func cityWeatherView(cityWeather: WeatherDisplayLogic) -> some View {
        VStack(spacing: 8) {
            asyncImage(cityWeather.weatherURL, size: imageSize)
            HStack {
                Text(cityWeather.locationName)
                Image(systemName: "location.fill")
            }
            .font(.custom("Poppins", size: 32, relativeTo: .title))
            .fontWeight(.semibold) // font weight 600
            Text(cityWeather.tempString)
                .font(.custom("Poppins", size: 70, relativeTo: .largeTitle))
                .fontWeight(.medium) // font weight 500
            HStack(alignment: .top, spacing: 0) {
                column(title: "Humidity", value: cityWeather.humidityString)
                column(title: "UV", value: cityWeather.uvString)
                column(title: "Feels Like", value: cityWeather.feelLikeString)
            }
            .padding(.horizontal, 20)
            .frame(height: stackHeight)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(infoBackgroundColor)
            )
            .padding(.horizontal, 20)
            Spacer()
        }
        .padding(.top, 40)
    }
    
    private func column(title: String, value: String) -> some View {
        VStack {
            Text(title)
                .font(.custom("Poppins", size: 12, relativeTo: .title2))
                .fontWeight(.medium) // font weight 500
                .lineLimit(0)
                .foregroundStyle(columnTitleTextColor)
            Text(value)
                .font(.custom("Poppins", size: 15, relativeTo: .body))
                .fontWeight(.medium) // font weight 500
                .foregroundStyle(columnTextColor)

        }
        .frame(maxWidth: .infinity)
    }



}

private extension WeatherView { // Let do some colors and sizing here
    private var infoBackgroundColor: Color {
        colorScheme == .light ?
        Color(red: 0xF2/256, green: 0xF2/256, blue: 0xF2/256) :
        Color(red: 0x2C/256, green: 0x2C/256, blue: 0x2C/256)
    }
    private var mainTextColor: Color {
        colorScheme == .light ?
        Color(red: 0x2C/256, green: 0x2C/256, blue: 0x2C/256) :
        Color(red: 0xF2/256, green: 0xF2/256, blue: 0xF2/256)
    }
    private var columnTextColor: Color {
        colorScheme == .light ?
        Color(red: 0x9A/256, green: 0x9A/256, blue: 0x9A/256) :
        Color(red: 0xC4/256, green: 0xC4/256, blue: 0xC4/256)
    }
    private var columnTitleTextColor: Color {
        colorScheme == .light ?
        Color(red: 0xC4/256, green: 0xC4/256, blue: 0xC4/256) :
        Color(red: 0x9A/256, green: 0x9A/256, blue: 0x9A/256)
    }

}

#Preview {
    WeatherView()
}
