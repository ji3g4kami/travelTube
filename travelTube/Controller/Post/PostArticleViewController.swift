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

class PostArticleViewController: UIViewController {

    var video: Video?
    var storedTags = [String]()
    var annotations: [MKPointAnnotation] = []
    var keyboardHight = 300

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var youtubePlayer: YouTubePlayerView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapSearchBar: UISearchBar!
    @IBOutlet weak var annotationTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapSearchBar.delegate = self

        setupYoutubePlayer()

        setKeyboardObserver()

        queryTags()

        setupAnnotationTableView()
    }

    func setupYoutubePlayer() {
        youtubePlayer.playerVars = ["playsinline": "1"] as YouTubePlayerView.YouTubePlayerParameters
        if let youtubeId = video?.youtubeId {
            youtubePlayer.loadVideoID(youtubeId)
        }
    }

    func setupAnnotationTableView() {
        annotationTableView.delegate = self
        annotationTableView.dataSource = self
        let xib = UINib(nibName: "AnnotationCell", bundle: nil)
        annotationTableView.register(xib, forCellReuseIdentifier: "AnnotationCell")
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
                title: "Invalid input",
                message: "Cannot insert whitespace or special characters in annotation title",
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
            annotationTableView.reloadData()
        }
    }

    @IBAction func discardArticle(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func postArticle(_ sender: Any) {
        // Annotations cannot be empty
        if annotations.count < 1 {
            let alertController = UIAlertController(title: "Lack of information", message: "Please at least share one location about the clip", preferredStyle: .alert)
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

//        var tags: [String] = tokenView.text.components(separatedBy: ", ")
//        if tags[0].count < 2 {
//            tags.removeAll()
//        } else {
//            var tag0 = Array(tags[0])
//            tag0.remove(at: 0)
//            tags[0] = String(tag0)
//        }

        FirebaseManager.shared.ref.child("articles").child(video.youtubeId).setValue([
            "youtubeId": video.youtubeId,
            "youtubeTitle": video.title,
            "youtubeImage": video.image,
            "youtubePublishDate": video.publishDate,
            "updateTime": Date().timeIntervalSince1970,
            "uid": UserManager.shared.uid,
            "annotations": markers
//            "tag": tags
        ])
         // Making tags
//        for tag in tags {
//            var tempArticleIdArray = [String]()
//            let ref = FirebaseManager.shared.ref.child("tags").child("\(tag)")
//            // new tag
//            if !storedTags.contains(tag) {
//                tempArticleIdArray.append(video.youtubeId)
//                ref.setValue(tempArticleIdArray)
//            } else {
//                ref.observeSingleEvent(of: .value, with: { (snapshot) in
//                    if let value = snapshot.value as? NSArray {
//                        for articleId in value {
//                            
//                            tempArticleIdArray.append(articleId as! String)
//                        }
//                        tempArticleIdArray.append(video.youtubeId)
//                        ref.setValue(tempArticleIdArray)
//                    }
//                })
//            }
//        }

        guard let controller = UIStoryboard.detailStoryboard().instantiateViewController(
            withIdentifier: String(describing: DetailViewController.self)
            ) as? DetailViewController else { return }
        controller.youtubeId = self.video?.youtubeId
        controller.hidesBottomBarWhenPushed = true
        self.present(controller, animated: true, completion: nil)
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

extension PostArticleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return annotations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = annotationTableView.dequeueReusableCell(withIdentifier: "AnnotationCell") as? AnnotationCell else {
            return UITableViewCell()
        }
        cell.annotationTitleLabel.text = annotations[indexPath.row].title
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(deleteAnnotation), for: .touchUpInside)
        return cell
    }

    @objc func deleteAnnotation(_ sender: UIButton) {
        mapView.removeAnnotation(annotations[sender.tag])
        annotations.remove(at: sender.tag)
        annotationTableView.reloadData()
    }
}
