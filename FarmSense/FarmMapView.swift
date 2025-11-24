// FarmMapView.swift
import SwiftUI
import MapKit

struct FarmMapView: UIViewRepresentable {

    @Binding var region: MKCoordinateRegion
    @Binding var fields: [MoistureMapView.FieldPolygon]

    @Binding var isTracingField: Bool
    @Binding var tracedCoordinates: [CLLocationCoordinate2D]

    var traceColor: Color

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        context.coordinator.mapView = map

        map.delegate = context.coordinator
        map.setRegion(region, animated: false)
        map.mapType = .standard
        map.isRotateEnabled = false

        let capture = TraceCaptureView()
        capture.backgroundColor = .clear
        capture.isUserInteractionEnabled = false
        capture.coordinator = context.coordinator

        map.addSubview(capture)
        capture.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            capture.topAnchor.constraint(equalTo: map.topAnchor),
            capture.bottomAnchor.constraint(equalTo: map.bottomAnchor),
            capture.leadingAnchor.constraint(equalTo: map.leadingAnchor),
            capture.trailingAnchor.constraint(equalTo: map.trailingAnchor)
        ])

        context.coordinator.captureView = capture

        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.mapView = map

        if let capture = context.coordinator.captureView {
            map.bringSubviewToFront(capture)
            capture.isUserInteractionEnabled = isTracingField
        }

        if !isTracingField {
            let centerDiff =
                abs(map.region.center.latitude - region.center.latitude) > 0.000001 ||
                abs(map.region.center.longitude - region.center.longitude) > 0.000001
            if centerDiff {
                map.setRegion(region, animated: true)
            }
        }

        map.isScrollEnabled = !isTracingField
        map.isZoomEnabled = !isTracingField
        map.isRotateEnabled = !isTracingField
        map.isPitchEnabled = !isTracingField

        map.removeOverlays(map.overlays)
        map.removeAnnotations(map.annotations)
        context.coordinator.polygonColors.removeAll()

        for field in fields {
            let polygon = MKPolygon(
                coordinates: field.coordinates,
                count: field.coordinates.count
            )
            polygon.title = field.name
            polygon.subtitle = field.moistureStatus
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

        if tracedCoordinates.count > 1 {
            let line = MKPolyline(
                coordinates: tracedCoordinates,
                count: tracedCoordinates.count
            )
            context.coordinator.traceUIColor = UIColor(traceColor)
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
        var traceUIColor: UIColor = .systemBlue
        private var lastAddedCoord: CLLocationCoordinate2D?

        init(_ parent: FarmMapView) {
            self.parent = parent
        }

        func addTracePoint(fromScreenPoint point: CGPoint) {
            guard parent.isTracingField, let mapView = mapView else { return }

            let coord = mapView.convert(point, toCoordinateFrom: mapView)

            if let last = lastAddedCoord {
                let dLat = abs(coord.latitude - last.latitude)
                let dLon = abs(coord.longitude - last.longitude)
                if dLat < 0.00002 && dLon < 0.00002 { return }
            }

            parent.tracedCoordinates.append(coord)
            lastAddedCoord = coord
        }

        func endTraceStroke() {
            lastAddedCoord = nil
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

            if let polyline = overlay as? MKPolyline {
                let r = MKPolylineRenderer(polyline: polyline)
                r.strokeColor = traceUIColor.withAlphaComponent(0.9)
                r.lineWidth = 2
                return r
            }

            guard let polygon = overlay as? MKPolygon else {
                return MKOverlayRenderer(overlay: overlay)
            }

            let renderer = MKPolygonRenderer(polygon: polygon)
            let color = polygonColors[polygon] ?? .systemGreen
            renderer.strokeColor = color.withAlphaComponent(0.65)
            renderer.fillColor = color.withAlphaComponent(0.12)
            renderer.lineWidth = 3
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

final class TraceCaptureView: UIView {

    weak var coordinator: FarmMapView.Coordinator?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        let p = t.location(in: self)
        coordinator?.addTracePoint(fromScreenPoint: p)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        let p = t.location(in: self)
        coordinator?.addTracePoint(fromScreenPoint: p)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        coordinator?.endTraceStroke()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        coordinator?.endTraceStroke()
    }
}
