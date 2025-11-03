import Foundation
import BluetoothLinux

class HomeAutomation {
    private var devices: [String: String] = [
        "lights": "OFF",
        "security": "ARMED",
        "batcave_entrance": "CLOSED",
        "computer_systems": "ONLINE"
    ]
    
    func controlDevice(_ device: String, action: String) -> String {
        guard let currentState = devices[device.lowercased()] else {
            return "Device not found in the system."
        }
        
        devices[device.lowercased()] = action.uppercased()
        return "\(device) is now \(action)"
    }
    
    func getStatus() -> String {
        return devices.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
    }
}