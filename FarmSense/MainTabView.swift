import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            NewsAlertsView()
                .tabItem {
                    Image(systemName: "bell.badge.fill")
                    Text("Alerts")
                }

            MoistureMapView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Map")
                }

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
    }
}

#Preview {
    MainTabView()
}
