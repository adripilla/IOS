import SwiftUI
import MapKit

extension CLLocationCoordinate2D {
    static let bigBen = CLLocationCoordinate2D(latitude: 51.500685, longitude: -0.124570)
    static let towerBridge = CLLocationCoordinate2D(latitude: 51.505507, longitude: -0.075402)
    static let torreon = CLLocationCoordinate2D(latitude: 25.5397, longitude: -103.4395)
    static let eiffelTower = CLLocationCoordinate2D(latitude: 48.8584, longitude: 2.2945)
    static let statueOfLiberty = CLLocationCoordinate2D(latitude: 40.6892, longitude: -74.0445)
    static let colosseum = CLLocationCoordinate2D(latitude: 41.8902, longitude: 12.4922)
    static let machuPicchu = CLLocationCoordinate2D(latitude: -13.1631, longitude: -72.5450)
    static let sydneyOperaHouse = CLLocationCoordinate2D(latitude: -33.8568, longitude: 151.2153)
}

struct ContentView: View {
    @State private var region = MKCoordinateRegion(
        center: .torreon,
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var selectedPlace = "Torreón, Coahuila"
    
    let places = ["Torreón, Coahuila", "Big Ben", "Tower Bridge", "Eiffel Tower", "Statue of Liberty", "Colosseum", "Machu Picchu", "Sydney Opera House"]
    
    let coordinates: [String: CLLocationCoordinate2D] = [
        "Torreón, Coahuila": .torreon,
        "Big Ben": .bigBen,
        "Tower Bridge": .towerBridge,
        "Eiffel Tower": .eiffelTower,
        "Statue of Liberty": .statueOfLiberty,
        "Colosseum": .colosseum,
        "Machu Picchu": .machuPicchu,
        "Sydney Opera House": .sydneyOperaHouse
    ]
    
    func calculateDistance(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> CLLocationDistance {
        let sourceLocation = CLLocation(latitude: source.latitude, longitude: source.longitude)
        let destinationLocation = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        return sourceLocation.distance(from: destinationLocation) / 1000 // Converting to kilometers
    }
    
    var body: some View {
        VStack {
            Map(coordinateRegion: $region, showsUserLocation: true)
                .onAppear {
                    region.center = .torreon
                }
                .edgesIgnoringSafeArea(.all)
            
            Picker("Select a place", selection: $selectedPlace) {
                ForEach(places, id: \.self) { place in
                    Text(place).tag(place)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .onChange(of: selectedPlace) { newValue in
                if let coordinate = coordinates[newValue] {
                    let distance = calculateDistance(from: .torreon, to: coordinate)
                    let alertMessage = "Distance from Torreón to \(newValue): \(String(format: "%.2f", distance)) km"
                    let alert = UIAlertController(title: "Distance", message: alertMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                    
                    withAnimation {
                        region.center = coordinate
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
