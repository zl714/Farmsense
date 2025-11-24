import SwiftUI

enum MetricStatus {
    case good, low, critical, neutral
    
    var color: Color {
        switch self {
        case .good: return .green
        case .low: return .yellow
        case .critical: return .red
        case .neutral: return .gray
        }
    }
    
    var label: String {
        switch self {
        case .good: return "Good"
        case .low: return "Low"
        case .critical: return "Critical"
        case .neutral: return "Neutral"
        }
    }
}

struct MetricTile: View {
    let title: String
    let value: String
    let status: MetricStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(value)
                .font(.title3.bold())

            Text(status.label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 90, alignment: .leading)
        .padding()
        // soft color fill like your map fields
        .background(status.color.opacity(0.18))
        // crisp outline like the map polygons
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(status.color.opacity(0.85), lineWidth: 2)
        )
        .cornerRadius(12)
    }
}

#Preview {
    VStack {
        MetricTile(title: "Moisture", value: "31%", status: .low)
        MetricTile(title: "Soil pH", value: "6.2", status: .good)
        MetricTile(title: "Stress Level", value: "High", status: .critical)
    }
    .padding()
}
