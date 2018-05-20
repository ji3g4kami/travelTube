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

class MapViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var annotations = [MKPointAnnotation]()
    let locationManager = CLLocationManager()
    var locationOrder = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
    }

    func setupMap() {

        mapView.addAnnotations(self.annotations)
        // show the first annotation in center
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: annotations[locationOrder].coordinate, span: span)
        mapView.setRegion(region, animated: true)
        navigationItem.title = annotations[locationOrder].title

//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//        mapView.showsUserLocation = true
//        if let startLocation = locationManager.location?.coordinate {
//            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
//            let region = MKCoordinateRegion(center: startLocation, span: span)
//            mapView.setRegion(region, animated: true)
//        }
    }
    @IBAction func nextLocationPressed(_ sender: Any) {
        locationOrder = (locationOrder+1) % annotations.count
        setupMap()
    }
}
