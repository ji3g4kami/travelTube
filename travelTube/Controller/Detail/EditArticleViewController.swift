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
        hideKeyboardWhenTappedAround()
        setupMap()
        setupTokenView()
        queryTags()
        mapView.delegate = self
        mapSearchBar.delegate = self
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

    func queryTags() {
        FirebaseManager.shared.ref.child("tags").observeSingleEvent(of: .value) { (snapshot) in
            if let tagsDict = snapshot.value as? [String: AnyObject] {
                for tag in tagsDict.keys {
                    self.storedTags.append(tag)
                }
            }
        }
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func deleteAnnotationPressed(_ sender: Any) {
        guard let destination = destination else { return }
        mapView.removeAnnotation(destination)
    }

    @IBAction func addAnnotaion(_ sender: UIButton) {
        let annotation = MKPointAnnotation()
        let centerCoordinate = mapView.centerCoordinate
        annotation.coordinate = centerCoordinate
        if (mapSearchBar.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            let alertController = UIAlertController(
                title: "地理標籤命名問題",
                message: "不能輸入空白或是特殊字元",
                preferredStyle: .alert)

            let okAction = UIAlertAction(
                title: "OK",
                style: .default,
                handler: nil)
            alertController.addAction(okAction)

            self.present(
                alertController,
                animated: true,
                completion: nil)
            return
        }
        if let title = mapSearchBar.text {
            annotation.title = title
            mapView.addAnnotation(annotation)
            annotations.append(annotation)
        }
    }

    @IBAction func postArticle(_ sender: Any) {
        // Annotations cannot be empty
        if mapView.annotations.count < 1 {
            let alertController = UIAlertController(title: "缺少地標資訊", message: "請用Add在地圖上新增標籤", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            present(alertController, animated: true)
            return
        }

        guard let articleInfo = articleInfo else {
            print("failed unwrapping youtube")
            return
        }
        var markers = [Any]()
        for annotation in mapView.annotations {
            guard let title2 = annotation.title, let title = title2 else { return }
            let marker = [
                "title": title,
                "logitutde": annotation.coordinate.longitude,
                "latitude": annotation.coordinate.latitude
                ] as [String: Any]
            markers.append(marker)
        }

        var tags: [String] = tokenView.text.components(separatedBy: ", ")
        if tags[0].count < 2 {
            let alertController = UIAlertController(title: "請新增tag", message: "請在post按鈕的上方選擇tag標籤", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            present(alertController, animated: true)
            return
        } else {
            var tag0 = Array(tags[0])
            tag0.remove(at: 0)
            tags[0] = String(tag0)
        }

        let childUpdates = ["annotations": markers, "tag": tags]
        FirebaseManager.shared.ref.child("articles").child(articleInfo.articleId).updateChildValues(childUpdates)
        //          Making tags
        for tag in tags {
            var tempArticleIdArray = [String]()
            let ref = FirebaseManager.shared.ref.child("tags").child("\(tag)")
            // new tag
            if !storedTags.contains(tag) {
                tempArticleIdArray.append(articleInfo.articleId)
                ref.setValue(tempArticleIdArray)
            } else {
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let value = snapshot.value as? NSArray {
                        for articleId in value {
                            guard let articleID = articleId as? String else { return }
                            tempArticleIdArray.append(articleID)
                        }
                        tempArticleIdArray.append(articleInfo.articleId)
                        ref.setValue(tempArticleIdArray)
                    }
                })
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateFromEdit"), object: nil, userInfo: ["annotations": mapView.annotations, "tags": tags])
        dismiss(animated: true, completion: nil)
    }
}

extension EditArticleViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()

        // Activity Indicator
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.mapView.addSubview(activityIndicator)

        // Create Search Request
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = searchBar.text

        let activeSearch = MKLocalSearch(request: searchRequest)

        activeSearch.start { (response, _) in
            activityIndicator.stopAnimating()
            if response == nil {
                print("error")
            } else {
                // Getting Data
                if let longitutde = response?.boundingRegion.center.longitude, let latitude = response?.boundingRegion.center.latitude {

                    // Zooming in on annotation
                    let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitutde)
                    let span = MKCoordinateSpanMake(0.01, 0.01)
                    let region = MKCoordinateRegionMake(coordinate, span)
                    self.mapView.setRegion(region, animated: true)
                }
            }
        }

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

extension EditArticleViewController: KSTokenViewDelegate {

    func tokenViewDidBeginEditing(_ tokenView: KSTokenView) {
        let offset = CGPoint.init(x: 0, y: self.keyboardHight+120)
        self.scrollView.setContentOffset(offset, animated: true)
        removeAllGestures()
    }

    func tokenViewDidEndEditing(_ tokenView: KSTokenView) {
        hideKeyboardWhenTappedAround()
    }

    func setupTokenView() {
        guard let tokens = articleInfo?.tag else { return }
        for token in tokens {
            tokenView.addToken(KSToken(title: token))
        }
        tokenView.layer.cornerRadius = 10
        tokenView.delegate = self
        tokenView.promptText = " Tags: "
        tokenView.placeholder = " 3 tags at most"
        tokenView.maxTokenLimit = 3
        tokenView.minimumCharactersToSearch = 0 // Show all results without without typing anything
        tokenView.style = .squared
        tokenView.direction = .vertical
        tokenView.cursorColor = .gray
        tokenView.paddingY = 5
        tokenView.marginY = 10
        tokenView.font = UIFont.systemFont(ofSize: 18)
        tokenView.searchResultHeight = 120
    }

    func tokenView(_ tokenView: KSTokenView, performSearchWithString string: String, completion: ((_ results: [AnyObject]) -> Void)?) {

        if string.isEmpty {
            completion!(storedTags as [AnyObject])
            return
        }

        var data: [String] = []
        for value: String in storedTags {
            if value.lowercased().range(of: string.lowercased()) != nil {
                data.append(value)
            }
        }
        completion!(data as [AnyObject])
    }

    func tokenView(_ tokenView: KSTokenView, displayTitleForObject object: AnyObject) -> String {
        guard let obj = object as? String else {
            return ""
        }
        return obj
    }
}
