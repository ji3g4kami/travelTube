//
//  MapViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/18.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var navigationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    var annotations = [MKPointAnnotation]()
    let locationManager = CLLocationManager()
    var destination: MKAnnotation?
    var locationOrder = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        showAllAnnotations()
        mapView.delegate = self
    }

    override func viewDidLayoutSubviews() {
        navigationButton.center.x = view.frame.width - 50
        navigationButton.center.y = view.frame.height + 50
    }

    func showAllAnnotations() {
        mapView.addAnnotations(self.annotations)
        mapView.showAnnotations(mapView.annotations, animated: true)
        navigationItem.title = "All"
    }

    func showNextAnnotation() {
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: annotations[locationOrder].coordinate, span: span)
        mapView.setRegion(region, animated: true)
        navigationItem.title = annotations[locationOrder].title
    }
    @IBAction func nextLocationPressed(_ sender: Any) {
        locationOrder = (locationOrder+1) % annotations.count
        showNextAnnotation()
    }

    @IBAction func allLocationPressed(_ sender: Any) {
        showAllAnnotations()
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        destination = view.annotation
        UIView.animate(withDuration: 0.1) {
            self.navigationButton.center.x = self.view.frame.width - 50
            self.navigationButton.center.y = self.view.frame.height - 50
        }
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        UIView.animate(withDuration: 0.1) {
            self.navigationButton.center.x = self.view.frame.width - 50
            self.navigationButton.center.y = self.view.frame.height + 50
        }
    }

    @IBAction func drawRoutePressed(_ sender: Any) {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true

        guard let startCoordinate = locationManager.location?.coordinate else { return }
        guard let destinationCoordinate = destination?.coordinate else { return }
        let sourcePlaceMark = MKPlacemark(coordinate: startCoordinate)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationCoordinate)

        let directionRequest = MKDirectionsRequest()
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        directionRequest.transportType = .any

        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResponse = response else {
                if let error = error {
                    print(error.localizedDescription)
                }
                return
            }

            self.mapView.removeOverlays(self.mapView.overlays)
            let route = directionResponse.routes[0]
            self.distanceLabel.text = "\(route.distance*0.001) km"
            self.durationLabel.text = "\(route.expectedTravelTime/60) min"
            self.mapView.add(route.polyline, level: .aboveRoads)

            // resize rect to make it look better
            var rect = route.polyline.boundingMapRect
            let widthPadding = rect.size.width*0.2
            let heightPadding = rect.size.height*0.2
            rect.size.width += widthPadding
            rect.size.height += heightPadding
            rect.origin.x -= widthPadding/2
            rect.origin.y -= heightPadding/2
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        return renderer
    }
}
