//
//  DetailMapViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/6/26.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import MapKit

class DetailMapViewController: UIViewController {

    @IBOutlet weak var openInMapButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!

    var articleInfo: Article?
    var annotations = [MKPointAnnotation]()
    var destination: MKAnnotation?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func setupMap() {
        mapView.delegate = self
        let allAnnotations = self.mapView.annotations
        mapView.removeAnnotations(allAnnotations)
        guard let annotaions = articleInfo?.annotations else { return }
        for annotaion in annotaions {
            let marker = MKPointAnnotation()
            marker.title = annotaion.title
            marker.coordinate = CLLocationCoordinate2DMake(annotaion.latitude, annotaion.logitutde)
            self.annotations.append(marker)
        }
        mapView.addAnnotations(self.annotations)
        mapView.showAnnotations(mapView.annotations, animated: true)

        // resize rect to make it look better MKMapRect
        let resizedSpan = MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta*1.1, longitudeDelta: mapView.region.span.longitudeDelta*1.1)
        let resizedRegion = MKCoordinateRegion(center: mapView.region.center, span: resizedSpan)
        mapView.setRegion(resizedRegion, animated: true)

        destination = self.annotations[0]
        guard let titleOptional = destination?.title, let title = titleOptional else { return }
        openInMapButton.setTitle("前往 \(title)", for: .normal)
    }

    @IBAction func openMapPressed(_ sender: Any) {
        let regionDistance: CLLocationDistance = 10000
        guard let coordinates = self.destination?.coordinate else { return }
        guard let title = self.destination?.title else { return }
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        mapItem.openInMaps(launchOptions: options)
    }

}

extension DetailMapViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.destination = view.annotation
        guard let destination = view.annotation?.title, let title = destination else { return }
        openInMapButton.setTitle("前往 \(title)", for: .normal)
    }
}
