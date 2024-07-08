import SwiftUI

struct Athlete {
    let name: String
    let country: String
    let achievements: String
}

struct SportEmoji: Identifiable {
    let id = UUID()
    let emoji: String
    let name: String
    let description: String
    let equipment: String
    let venue: String
    let topAthletes: [Athlete] // Lista de los mejores deportistas
}

let footballAthletes = [
    Athlete(name: "Cristiano Ronaldo", country: "Portugal", achievements: "Five-time Ballon d'Or winner"),
    Athlete(name: "Lionel Messi", country: "Argentina", achievements: "Six-time Ballon d'Or winner"),
    Athlete(name: "Neymar Jr.", country: "Brazil", achievements: "Champions League winner")
]

let basketballAthletes = [
    Athlete(name: "LeBron James", country: "USA", achievements: "Four-time NBA champion"),
    Athlete(name: "Michael Jordan", country: "USA", achievements: "Six-time NBA champion"),
    Athlete(name: "Kobe Bryant", country: "USA", achievements: "Five-time NBA champion")
]

let tennisAthletes = [
    Athlete(name: "Roger Federer", country: "Switzerland", achievements: "20-time Grand Slam winner"),
    Athlete(name: "Rafael Nadal", country: "Spain", achievements: "20-time Grand Slam winner"),
    Athlete(name: "Novak Djokovic", country: "Serbia", achievements: "18-time Grand Slam winner")
]

private let sportList: [SportEmoji] = [
    SportEmoji(emoji: "⚽️", name: "Football", description: "A team sport played with a spherical ball between two teams of eleven players.", equipment: "Football, goalposts, football boots", venue: "Football field",  topAthletes: footballAthletes),
    SportEmoji(emoji: "🏀", name: "Basketball", description: "A team sport in which two teams, most commonly of five players each, opposing one another on a rectangular court, compete with the primary objective of shooting a basketball through the defender's hoop.", equipment: "Basketball, basketball hoop, basketball shoes", venue: "Basketball court", topAthletes: basketballAthletes),
    SportEmoji(emoji: "🎾", name: "Tennis", description: "A racket sport that can be played individually against a single opponent (singles) or between two teams of two players each (doubles).", equipment: "Tennis racket, tennis ball", venue: "Tennis court", topAthletes: tennisAthletes),
    // Add more sports here
]

struct ContentView: View {
    var body: some View {
        NavigationView {
            List(sportList) { sport in
                NavigationLink(destination: DetailsView(sport: sport)) {
                    HStack {
                        EmojiCircleView(sport: sport)
                        Text(sport.name).font(.headline)
                    }.padding(5)
                }
            }
            .navigationBarTitle("🏅Top 10 Sports🏅")
        }
    }
}

struct DetailsView: View {
    let sport: SportEmoji
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                EmojiCircleView(sport: sport).padding()
            }
            Text("Description").bold().italic()
            Text(sport.description)
            Text("Equipment").bold().italic()
            Text(sport.equipment)
            Text("Venue").bold().italic()
            Text(sport.venue)
            Text("Top Athletes").bold().italic()
            List(sport.topAthletes, id: \.name) { athlete in
                Text("\(athlete.name) - \(athlete.country)")
            }
        }
        .padding()
        .navigationBarTitle(Text(sport.name), displayMode: .large)
    }
}

struct EmojiCircleView: View {
    let sport: SportEmoji
    var body: some View {
        ZStack {
            Text(sport.emoji).shadow(radius: 5)
                .font(.largeTitle)
                .frame(width: 65, height: 65)
                .overlay(Circle().stroke(Color.green, lineWidth: 3))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
