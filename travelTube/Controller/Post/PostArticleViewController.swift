//
//  PostArticleViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/3.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import YouTubePlayer
import MapKit
import FirebaseDatabase
import KSTokenView

class PostArticleViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    var video: Video?
    var storedTags = [String]()
    var annotations: [MKPointAnnotation] = []
    var destination: MKAnnotation?
    var keyboardHight = 300

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapSearchBar: UISearchBar!
    @IBOutlet weak var removeButton: DesignableButton!
    @IBOutlet weak var tokenView: KSTokenView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var hintView: DesignableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.hideKeyboardWhenTappedAround()
        mapView.delegate = self
        mapSearchBar.delegate = self
        setKeyboardObserver()
        setupTokenView()
        queryTags()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMapHint" {
            let popOverViewController = segue.destination
            guard let rect = sender as? UIView else { return }
            segue.destination.popoverPresentationController?.sourceRect = rect.bounds
            popOverViewController.popoverPresentationController?.delegate = self
        } else if segue.identifier == "videoPopOver" {
            let popOverViewController = segue.destination as? VideoPopupViewController
            guard let youtubeId = video?.youtubeId else { return }
            popOverViewController?.youtubeId = youtubeId
            popOverViewController?.preferredContentSize = CGSize(width: 320, height: 180)
            popOverViewController?.popoverPresentationController?.delegate = self
        }
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    func setKeyboardObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(getKeyboardHeight),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
    }

    @objc func getKeyboardHeight(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.keyboardHight = Int(keyboardRectangle.height)
        }
    }

    @IBAction func dismissHintPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            self.hintView.alpha =
                CGFloat(0)
        }, completion: nil
    )}

    @IBAction func searchButtonPressed(_ sender: Any) {
        searchBar.resignFirstResponder()

        // Create Search Request
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = searchBar.text

        let activeSearch = MKLocalSearch(request: searchRequest)

        activeSearch.start { (response, _) in
            if response == nil {
                let alertController = UIAlertController(title: "找不到地點", message: "請嘗試其他地名", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alertController, animated: true)
                return
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

    @IBAction func deleteAnnotationPressed(_ sender: Any) {
        guard let destination = destination else { return }
        mapView.removeAnnotation(destination)
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
        if annotations.count < 1 {
            let alertController = UIAlertController(title: "缺少地標資訊", message: "請用Add在地圖上新增標籤", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            present(alertController, animated: true)
            return
        }

        guard let video = video else {
            print("failed unwrapping youtube")
            return
        }
        var markers = [Any]()
        for annotation in annotations {
            let marker = [
                "title": annotation.title!,
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

        FirebaseManager.shared.ref.child("articles").child(video.youtubeId).setValue([
            "youtubeId": video.youtubeId,
            "youtubeTitle": video.title,
            "youtubeImage": video.image,
            "youtubePublishDate": video.publishDate,
            "updateTime": Date().timeIntervalSince1970,
            "uid": UserManager.shared.uid,
            "annotations": markers,
            "tag": tags
        ])
//          Making tags
        for tag in tags {
            var tempArticleIdArray = [String]()
            let ref = FirebaseManager.shared.ref.child("tags").child("\(tag)")
            // new tag
            if !storedTags.contains(tag) {
                tempArticleIdArray.append(video.youtubeId)
                ref.setValue(tempArticleIdArray)
            } else {
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let value = snapshot.value as? NSArray {
                        for articleId in value {
                            guard let articleID = articleId as? String else { return }
                            tempArticleIdArray.append(articleID)
                        }
                        tempArticleIdArray.append(video.youtubeId)
                        ref.setValue(tempArticleIdArray)
                    }
                })
            }
        }

        navigationController?.popToRootViewController(animated: true)
    }

}

extension PostArticleViewController: CLLocationManagerDelegate, MKMapViewDelegate {
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

extension PostArticleViewController: UISearchBarDelegate {
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

extension PostArticleViewController: KSTokenViewDelegate {

    func tokenViewDidBeginEditing(_ tokenView: KSTokenView) {
        let offset = CGPoint.init(x: 0, y: self.keyboardHight+120)
        self.scrollView.setContentOffset(offset, animated: true)
    }

    func setupTokenView() {
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
