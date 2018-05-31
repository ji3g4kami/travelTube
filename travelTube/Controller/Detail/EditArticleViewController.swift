//
//  EditArticleViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/31.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import MapKit

class EditArticleViewController: UIViewController {

    var articleInfo: Article?
    var annotations = [MKPointAnnotation]()

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
    }

    private func setupMap() {
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
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
