import SwiftUI
import MapKit

struct MoistureMapView: View {

    // MARK: - Models

    struct FieldPolygon: Identifiable {
        let id = UUID()
        let name: String
        let moistureStatus: String
        let coordinates: [CLLocationCoordinate2D]
        let color: Color
    }

    struct Farm: Identifiable {
        let id = UUID()
        var name: String
        var region: MKCoordinateRegion
        var fields: [FieldPolygon]
    }

    // MARK: - Farms State (starts with 2 sample farms)

    @State private var farms: [Farm] = [
        Farm(
            name: "Home Farm",
            region: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 34.0100, longitude: -84.3600),
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            ),
            fields: []
        ),
        Farm(
            name: "North Farm",
            region: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 34.0300, longitude: -84.3800),
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            ),
            fields: []
        )
    ]

    @State private var selectedFarmIndex: Int = 0
    @State private var region: MKCoordinateRegion

    // MARK: - Add Field Sheet State

    @State private var showingAddFieldSheet = false
    @State private var newFieldName: String = ""
    @State private var newFieldStatus: String = "Good"
    @State private var rawCoordinatesText: String = ""

    let statusOptions = ["Good", "Low", "Critical"]

    // MARK: - Add Farm Sheet State

    @State private var showingAddFarmSheet = false
    @State private var newFarmName: String = ""

    // MARK: - Init

    init() {
        let initialRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 34.0100, longitude: -84.3600),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
        _region = State(initialValue: initialRegion)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {

                // ✅ Farm Dropdown + Add Farm button
                HStack {
                    Picker("Farm", selection: $selectedFarmIndex) {
                        ForEach(farms.indices, id: \.self) { index in
                            Text(farms[index].name).tag(index)
                        }
                    }
                    .pickerStyle(.menu)

                    Spacer()

                    Button {
                        newFarmName = ""
                        showingAddFarmSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .accessibilityLabel("Add Farm")
                }
                .padding(.horizontal)
                // ✅ iOS 17+ onChange syntax (no warning)
                .onChange(of: selectedFarmIndex) { oldValue, newValue in
                    withAnimation {
                        region = farms[newValue].region
                    }
                }

                Text("Live Moisture Map")
                    .font(.headline)

                // ✅ Real MKMapView with polygons for selected farm
                FarmMapView(
                    region: $region,
                    fields: Binding(
                        get: { farms[selectedFarmIndex].fields },
                        set: { farms[selectedFarmIndex].fields = $0 }
                    )
                )
                .frame(height: 320)
                .cornerRadius(16)
                .padding(.horizontal)

                // Legend
                HStack(spacing: 16) {
                    legendDot(color: .green, label: "Good")
                    legendDot(color: .yellow, label: "Low")
                    legendDot(color: .red, label: "Critical")
                }
                .font(.caption)

                // Add Field by Coordinates button
                Button {
                    newFieldName = ""
                    newFieldStatus = "Good"
                    rawCoordinatesText = ""
                    showingAddFieldSheet = true
                } label: {
                    Text("Add Field by Coordinates")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                Button {
                    print("Refresh Data tapped")
                } label: {
                    Text("Refresh Data")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddFieldSheet) {
                addFieldSheet
            }
            .sheet(isPresented: $showingAddFarmSheet) {
                addFarmSheet
            }
        }
        .onAppear {
            region = farms[selectedFarmIndex].region
        }
    }

    // MARK: - Add Field Sheet

    private var addFieldSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("Field Info")) {
                    TextField("Field Name", text: $newFieldName)

                    Picker("Moisture Status", selection: $newFieldStatus) {
                        ForEach(statusOptions, id: \.self) { status in
                            Text(status)
                        }
                    }
                }

                Section(
                    header: Text("Coordinates"),
                    footer: Text(
                        "Enter one coordinate per line:\nlatitude, longitude\n\nExample:\n34.0150, -84.3650\n34.0150, -84.3550\n34.0120, -84.3550\n34.0120, -84.3650"
                    )
                    .font(.footnote)
                ) {
                    TextEditor(text: $rawCoordinatesText)
                        .frame(minHeight: 120)
                        .font(.system(.body, design: .monospaced))
                }

                Section {
                    Button("Save Field") {
                        addFieldFromCoordinates()
                    }
                    .disabled(
                        newFieldName.trimmingCharacters(in: .whitespaces).isEmpty ||
                        rawCoordinatesText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )

                    Button("Cancel", role: .cancel) {
                        showingAddFieldSheet = false
                    }
                }
            }
            .navigationTitle("Add Field")
        }
    }

    // MARK: - Add Farm Sheet

    private var addFarmSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("Farm Info")) {
                    TextField("Farm Name", text: $newFarmName)
                }

                Section(
                    footer: Text("This farm will be centered on your current map view. You can add fields to it right away.")
                        .font(.footnote)
                ) {
                    Button("Save Farm") {
                        addNewFarm()
                    }
                    .disabled(newFarmName.trimmingCharacters(in: .whitespaces).isEmpty)

                    Button("Cancel", role: .cancel) {
                        showingAddFarmSheet = false
                    }
                }
            }
            .navigationTitle("Add Farm")
        }
    }

    // MARK: - Helpers

    private func colorForStatus(_ status: String) -> Color {
        switch status {
        case "Good": return .green
        case "Low": return .yellow
        case "Critical": return .red
        default: return .gray
        }
    }

    private func addFieldFromCoordinates() {
        let lines = rawCoordinatesText
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        var coords: [CLLocationCoordinate2D] = []

        for line in lines {
            let parts = line.split(separator: ",")
            if parts.count >= 2 {
                let latString = parts[0].trimmingCharacters(in: .whitespaces)
                let lonString = parts[1].trimmingCharacters(in: .whitespaces)

                if let lat = Double(latString),
                   let lon = Double(lonString) {
                    coords.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
                }
            }
        }

        guard coords.count >= 3 else {
            print("Need at least 3 valid coordinate points.")
            return
        }

        let field = FieldPolygon(
            name: newFieldName,
            moistureStatus: newFieldStatus,
            coordinates: coords,
            color: colorForStatus(newFieldStatus)
        )

        farms[selectedFarmIndex].fields.append(field)

        if let center = centroid(of: coords) {
            region.center = center
        }

        showingAddFieldSheet = false
    }

    private func addNewFarm() {
        let center = region.center

        let newFarm = Farm(
            name: newFarmName,
            region: MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            ),
            fields: []
        )

        farms.append(newFarm)

        selectedFarmIndex = farms.count - 1
        region = newFarm.region

        showingAddFarmSheet = false
    }

    private func centroid(of coordinates: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D? {
        guard !coordinates.isEmpty else { return nil }
        let sumLat = coordinates.reduce(0.0) { $0 + $1.latitude }
        let sumLon = coordinates.reduce(0.0) { $0 + $1.longitude }
        return CLLocationCoordinate2D(
            latitude: sumLat / Double(coordinates.count),
            longitude: sumLon / Double(coordinates.count)
        )
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color.opacity(0.7))
                .frame(width: 10, height: 10)
            Text(label)
        }
    }
}



// ======================================================
// MARK: - MKMapView Wrapper (real map + polygons)
// ======================================================

struct FarmMapView: UIViewRepresentable {

    @Binding var region: MKCoordinateRegion
    @Binding var fields: [MoistureMapView.FieldPolygon]

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.setRegion(region, animated: false)
        map.mapType = .standard
        map.isRotateEnabled = false
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        map.setRegion(region, animated: true)

        map.removeOverlays(map.overlays)
        map.removeAnnotations(map.annotations)

        for field in fields {
            let polygon = MKPolygon(
                coordinates: field.coordinates,
                count: field.coordinates.count
            )
            polygon.title = field.name
            polygon.subtitle = field.moistureStatus

            // store polygon color for renderer
            context.coordinator.polygonColors[polygon] = UIColor(field.color)

            map.addOverlay(polygon)

            if let center = context.coordinator.centroid(of: field.coordinates) {
                let pin = MKPointAnnotation()
                pin.title = field.name
                pin.subtitle = field.moistureStatus
                pin.coordinate = center
                map.addAnnotation(pin)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var polygonColors: [MKPolygon: UIColor] = [:]

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polygon = overlay as? MKPolygon else {
                return MKOverlayRenderer(overlay: overlay)
            }

            let renderer = MKPolygonRenderer(polygon: polygon)
            let baseColor = polygonColors[polygon] ?? .systemGreen

            // --------------------------------------
            // ✅ NEW COLORING LOGIC (requested fix)
            // --------------------------------------
            renderer.strokeColor = baseColor.withAlphaComponent(0.65)   // softer outline
            renderer.lineWidth = 3

            renderer.fillColor = baseColor.withAlphaComponent(0.12)     // very light fill
            // --------------------------------------

            return renderer
        }

        func centroid(of coords: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D? {
            guard !coords.isEmpty else { return nil }
            let sumLat = coords.reduce(0.0) { $0 + $1.latitude }
            let sumLon = coords.reduce(0.0) { $0 + $1.longitude }
            return CLLocationCoordinate2D(
                latitude: sumLat / Double(coords.count),
                longitude: sumLon / Double(coords.count)
            )
        }
    }
}
