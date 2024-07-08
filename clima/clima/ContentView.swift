import SwiftUI
import MapKit

struct ContentView: View {
    @State private var city = ""
    @State private var weatherData: WeatherData?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 25.5397, longitude: -103.4395),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var distanceToTorreon: Double = 0
    
    var body: some View {
        VStack {
            Map(coordinateRegion: $region, showsUserLocation: true)
                .onAppear {
                    if let data = weatherData {
                        region.center = CLLocationCoordinate2D(latitude: data.coord.lat, longitude: data.coord.lon)
                    }
                }
                .edgesIgnoringSafeArea(.all)
            
            TextField("Enter city name", text: $city, onCommit: fetchWeather)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if let weatherData = weatherData {
                Text("Weather in \(weatherData.name)")
                    .font(.title)
                Text("Temperature: \(weatherData.main.temp)°C")
                Text("Humidity: \(weatherData.main.humidity)%")
                Text("Distance to Torreón: \(String(format: "%.2f", distanceToTorreon)) km")
            }
        }
        .padding()
    }
    
    func fetchWeather() {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=f1fd1da488a75aa419d89811f73ab144&units=metric") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data:", error ?? "Unknown error")
                return
            }
            
            if let decodedResponse = try? JSONDecoder().decode(WeatherData.self, from: data) {
                DispatchQueue.main.async {
                    self.weatherData = decodedResponse
                    self.region.center = CLLocationCoordinate2D(latitude: decodedResponse.coord.lat, longitude: decodedResponse.coord.lon)
                    self.calculateDistanceToTorreon(from: decodedResponse.coord)
                }
            } else {
                print("Invalid response from server")
            }
        }.resume()
    }
    
    func calculateDistanceToTorreon(from coordinates: Coord) {
        let torreonCoordinates = CLLocationCoordinate2D(latitude: 25.5397, longitude: -103.4395)
        let cityCoordinates = CLLocationCoordinate2D(latitude: coordinates.lat, longitude: coordinates.lon)
        let torreonLocation = CLLocation(latitude: torreonCoordinates.latitude, longitude: torreonCoordinates.longitude)
        let cityLocation = CLLocation(latitude: cityCoordinates.latitude, longitude: cityCoordinates.longitude)
        distanceToTorreon = torreonLocation.distance(from: cityLocation) / 1000 // Converting to kilometers
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct WeatherData: Codable {
    let name: String
    let coord: Coord
    let main: Main
}

struct Coord: Codable {
    let lat: Double
    let lon: Double
}

struct Main: Codable {
    let temp: Double
    let humidity: Int
}
