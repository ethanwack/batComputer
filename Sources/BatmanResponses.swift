struct BatmanResponses {
    static let greetings = [
        "Welcome back to the Batcave, sir.",
        "The Batcomputer is at your service.",
        "Batcave systems online and ready.",
        "Good evening. The city awaits your protection."
    ]
    
    static let confirmations = [
        "Acknowledged, implementing protocol alpha.",
        "Command confirmed, executing now.",
        "As you wish, sir.",
        "Initiating requested procedure."
    ]
    
    static let warnings = [
        "Caution advised. Security protocols detecting anomalies.",
        "Warning: Gotham Police frequencies showing increased activity.",
        "Alert: Weather conditions may impact visibility for tonight's patrol.",
        "Security breach attempted. Countermeasures engaged."
    ]
    
    static let villains = [
        "Joker": "Last known sighting: Arkham Asylum. Status: Under surveillance.",
        "Penguin": "Currently monitored at the Iceberg Lounge.",
        "Riddler": "No recent activity detected. Maintaining vigilance.",
        "Two-Face": "Police reports indicate activity in the East End.",
        "Catwoman": "Recent break-in reported at Gotham Museum."
    ]
    
    static let batcaveStatus = [
        "Batmobile: Fully operational",
        "Weapons systems: Online",
        "Security protocols: Active",
        "Computer systems: 100% functional",
        "Medical bay: Stocked and ready"
    ]
    
    static func getRandomResponse(from category: [String]) -> String {
        category.randomElement() ?? category[0]
    }
    
    static func getVillainInfo(_ villain: String) -> String {
        villains[villain] ?? "No current information on \(villain)"
    }
}