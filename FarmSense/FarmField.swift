import Foundation
import CoreLocation
import SwiftUI

struct FarmField: Identifiable {
    let id = UUID()
    let name: String
    let moistureStatus: String
    let coordinate: CLLocationCoordinate2D
    let color: Color
}
func ringColor(for value: Int) -> Color {
    switch value {
    case 70...100: return .green
    case 40..<70:  return .yellow
    default:       return .red
    }
}
