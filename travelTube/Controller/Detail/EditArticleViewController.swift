//
//  EditArticleViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/31.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import MapKit
import KSTokenView

class EditArticleViewController: UIViewController {

    var articleInfo: Article?
    var storedTags = [String]()
    var annotations: [MKPointAnnotation] = []
    var destination: MKAnnotation?
    var keyboardHight = 300


    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tokenView: KSTokenView!
    @IBOutlet weak var removeButton: DesignableButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mapSearchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        mapView.delegate = self
//        mapSearchBar.delegate = self
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

    @IBAction func deleteAnnotationPressed(_ sender: Any) {
        guard let destination = destination else { return }
        mapView.removeAnnotation(destination)
    }
}

extension EditArticleViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        destination = view.annotation
        UIView.animate(withDuration: 0.5, animations: {
            self.removeButton.alpha =
                CGFloat(1)
        }, completion: { _ in
            print("Animation Alpha Complete")
        })
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        UIView.animate(withDuration: 0.5, animations: {
            self.removeButton.alpha =
                CGFloat(0)
        }, completion: { _ in
            print("Animation Alpha Complete")
        })
    }
}
