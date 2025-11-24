import SwiftUI

struct SettingsView: View {
    @State private var moistureAlertsOn = true
    @State private var dailySummaryOn = true
    @State private var selectedUnits = "Fahrenheit"

    var body: some View {
        NavigationView {
            Form {

                // Notifications Section
                Section(header: Text("Notifications")) {
                    Toggle("Moisture Alerts", isOn: $moistureAlertsOn)
                    Toggle("Daily Summary", isOn: $dailySummaryOn)
                }

                // Units / Preferences Section
                Section(header: Text("Farm Preferences")) {
                    Picker("Temperature Units", selection: $selectedUnits) {
                        Text("Fahrenheit").tag("Fahrenheit")
                        Text("Celsius").tag("Celsius")
                    }
                }

                // System Section
                Section(header: Text("System")) {
                    Button("Sync Sensors") {
                        // later functionality
                    }
                    Button("Manage Farms") {
                        // later functionality
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
