//
//  MapViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/18.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var annotations = [MKPointAnnotation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
    }

    func setupMap() {
        mapView.addAnnotations(self.annotations)
        // show the first annotation in center
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: annotations[0].coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}
