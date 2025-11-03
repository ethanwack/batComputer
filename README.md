# Bat Computer Voice Assistant

A sophisticated voice assistant inspired by Batman's computer system, offering advanced features and Batman-themed responses. This assistant is designed to work seamlessly across macOS and iOS devices, providing a more engaging alternative to Siri and Alexa.

## Features

- 🗣️ **Voice Activation**
  - Activate by saying "Computer" (similar to Siri/Alexa)
  - Natural language processing
  - Batman-themed responses
  - British accent voice output (Alfred-inspired)

- 🦇 **Batman Universe Integration**
  - Batcave systems monitoring
  - Villain tracking system
  - Batmobile status
  - Security protocols
  - Authentic Batman-themed responses

- 🏠 **Home Automation**
  - Light control
  - Security system management
  - System status monitoring
  - Temperature control
  - Custom device integration

- 🌤️ **Weather Integration**
  - Real-time weather updates
  - Weather forecasts for any city
  - Weather alerts
  - Environmental monitoring

- 🔒 **Security Features**
  - Voice authentication
  - Secure command authorization
  - Multi-level access control
  - Encrypted communications

## Requirements

- macOS 12.0 or later
- iOS 15.0 or later (for mobile functionality)
- Swift 5.7 or later
- Xcode 14.0 or later (for development)
- OpenWeatherMap API key (for weather features)

## Installation

1. Clone the repository:
```bash
git clone https://github.com/ethanwack/batComputer.git
cd batComputer
```

2. Make the installation script executable:
```bash
chmod +x install.sh
```

3. Run the installation script:
```bash
./install.sh
```

## Setting Up Voice Activation

### On macOS:
1. Open System Settings → Siri & Spotlight
2. Enable "Listen for 'Hey Siri'"
3. Open Shortcuts app
4. Create a new shortcut:
   - Add the "Activate Bat Computer" action
   - Add the phrase "Computer"
   - Enable "Use with Siri"

### On iPhone/iPad:
1. Open Settings → Siri & Search
2. Enable "Listen for 'Hey Siri'"
3. Open Shortcuts app
4. Create a new shortcut:
   - Add the "Activate Bat Computer" action
   - Add the phrase "Computer"
   - Enable "Use with Siri"

## Available Commands

- **System Control**
  - "Computer, what time is it?"
  - "Computer, status report"
  - "Computer, system status"
  - "Computer, activate security protocol"

- **Weather**
  - "Computer, what's the weather in [city]?"
  - "Computer, weather forecast"
  - "Computer, weather alerts"

- **Home Automation**
  - "Computer, lights on/off"
  - "Computer, arm/disarm security"
  - "Computer, Batcave entrance open/close"

- **Batcave Systems**
  - "Computer, Batmobile status"
  - "Computer, scan perimeter"
  - "Computer, activate defense systems"

- **Villain Tracking**
  - "Computer, locate [villain name]"
  - "Computer, threat assessment"
  - "Computer, criminal database search"

## Configuration

### Weather API Setup
1. Get an API key from [OpenWeatherMap](https://openweathermap.org/api)
2. Replace `YOUR_OPENWEATHER_API_KEY` in `WeatherService.swift` with your actual API key

### Voice Authentication
The system includes voice authentication for sensitive commands. To set up:
1. Launch the Bat Computer
2. Use the authentication phrase when prompted
3. The system will create and store your voice profile

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details

## Acknowledgments

- Inspired by Batman's computer system from DC Comics
- Uses SwiftUI for the user interface
- Integrates with Apple's Speech Recognition and Synthesis
- Weather data provided by OpenWeatherMap
- Special thanks to Alfred Pennyworth for the voice inspiration

## Support

For support, please open an issue in the GitHub repository or contact the maintainer.

## Disclaimer

This project is a fan creation and is not affiliated with DC Comics, Batman, or Warner Bros. Entertainment Inc. All Batman-related references are properties of their respective owners.