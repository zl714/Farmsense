import SwiftUI

struct NewsAlertsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("News")) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Irrigation Best Practices for Dry Weeks")
                            .font(.headline)
                        Text("Learn how to optimize water during extended dry periods.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("Alerts")) {
                    AlertRow(title: "Field 5 – Low Moisture", color: .orange)
                    AlertRow(title: "Field 2 – Critical Moisture", color: .red)
                    AlertRow(title: "Field 7 – Moderate Moisture", color: .yellow)
                }
            }
            .navigationTitle("News & Alerts")
        }
    }
}

struct AlertRow: View {
    let title: String
    let color: Color

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(title)
        }
    }
}

#Preview {
    NewsAlertsView()
}
