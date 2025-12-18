import SwiftUI
import MapKit

struct FarmMapView: UIViewRepresentable {

    @Binding var region: MKCoordinateRegion
    @Binding var fields: [MoistureMapView.FieldPolygon]
    @Binding var isTracingField: Bool
    @Binding var tracedCoordinates: [CLLocationCoordinate2D]

    // NEW: color of the live trace line
    var traceColor: Color

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.setRegion(region, animated: false)

        let capture = TraceCaptureView()
        capture.coordinator = context.coordinator
        capture.backgroundColor = .clear
        capture.isUserInteractionEnabled = false

        map.addSubview(capture)
        capture.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            capture.topAnchor.constraint(equalTo: map.topAnchor),
            capture.bottomAnchor.constraint(equalTo: map.bottomAnchor),
            capture.leadingAnchor.constraint(equalTo: map.leadingAnchor),
            capture.trailingAnchor.constraint(equalTo: map.trailingAnchor)
        ])

        context.coordinator.mapView = map
        context.coordinator.captureView = capture

        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.captureView?.isUserInteractionEnabled = isTracingField

        map.removeOverlays(map.overlays)
        context.coordinator.polygonColors.removeAll()

        // Field polygons with per-field colors
        for field in fields {
            let polygon = MKPolygon(coordinates: field.coordinates, count: field.coordinates.count)
            context.coordinator.polygonColors[polygon] = UIColor(field.color)
            map.addOverlay(polygon)
        }

        // Live trace line with selected status color
        if tracedCoordinates.count > 1 {
            let line = MKPolyline(coordinates: tracedCoordinates, count: tracedCoordinates.count)
            context.coordinator.traceLineColor = UIColor(traceColor)
            map.addOverlay(line)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: FarmMapView
        weak var mapView: MKMapView?
        weak var captureView: TraceCaptureView?

        var polygonColors: [MKPolygon: UIColor] = [:]
        var traceLineColor: UIColor = .systemBlue

        init(_ parent: FarmMapView) {
            self.parent = parent
        }

        func addTracePoint(from point: CGPoint) {
            guard parent.isTracingField, let map = mapView else { return }
            let coord = map.convert(point, toCoordinateFrom: map)
            parent.tracedCoordinates.append(coord)
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

            if let polyline = overlay as? MKPolyline {
                let r = MKPolylineRenderer(polyline: polyline)
                r.strokeColor = traceLineColor.withAlphaComponent(0.95)
                r.lineWidth = 3
                return r
            }

            if let polygon = overlay as? MKPolygon {
                let r = MKPolygonRenderer(polygon: polygon)
                let c = polygonColors[polygon] ?? .systemGreen
                r.fillColor = c.withAlphaComponent(0.18)
                r.strokeColor = c.withAlphaComponent(0.8)
                r.lineWidth = 2
                return r
            }

            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

final class TraceCaptureView: UIView {
    weak var coordinator: FarmMapView.Coordinator?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        coordinator?.addTracePoint(from: t.location(in: self))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        coordinator?.addTracePoint(from: t.location(in: self))
    }
}
