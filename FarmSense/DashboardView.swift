import SwiftUI

struct DashboardView: View {

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {

                Text("FarmSense")
                    .font(.title.bold())
                    .padding(.top)

                // Overall Health Indicator
                let healthScore = 72
                let progress = Double(healthScore) / 100.0
                let ringColor = ringColor(for: healthScore)

                ZStack {
                    // background ring (full)
                    Circle()
                        .stroke(Color.gray.opacity(0.25), lineWidth: 10)
                        .frame(width: 150, height: 150)

                    // progress ring (dynamic color)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            ringColor,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 150, height: 150)

                    VStack {
                        Text("\(healthScore)%")
                            .font(.system(size: 40, weight: .bold))
                        Text("Overall Health")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }


                // 2x2 tiles with color health status
                LazyVGrid(columns: columns, spacing: 16) {
                    MetricTile(title: "Moisture", value: "31%", status: .low)
                    MetricTile(title: "Soil pH", value: "6.2", status: .good)
                    MetricTile(title: "Temperature", value: "70°F", status: .good)
                    MetricTile(title: "Stress Level", value: "High", status: .critical)
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    DashboardView()
}
