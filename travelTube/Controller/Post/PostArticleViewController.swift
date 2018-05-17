//
//  PostArticleViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/3.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import YouTubePlayer
import KSTokenView
import MapKit
import FirebaseDatabase
import AMScrollingNavbar

class PostArticleViewController: UIViewController {

    var youtube: Video?
    var storedTags = [String]()
    var annotations: [MKPointAnnotation] = []
    var keyboardHight = 300

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var youtubePlayer: YouTubePlayerView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapSearchBar: UISearchBar!
    @IBOutlet weak var tokenView: KSTokenView!
    @IBOutlet weak var annotationTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tokenView.delegate = self
        tokenView.layer.cornerRadius = 10

        youtubePlayer.playerVars = ["playsinline": "1"] as YouTubePlayerView.YouTubePlayerParameters
        if let youtubeId = youtube?.youtubeId {
            youtubePlayer.loadVideoID(youtubeId)
        }
        mapSearchBar.delegate = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )

        queryTags()
        setupTokenView()
        annotationTableView.delegate = self
        annotationTableView.dataSource = self
        let xib = UINib(nibName: "AnnotationCell", bundle: nil)
        annotationTableView.register(xib, forCellReuseIdentifier: "AnnotationCell")
    }

    @objc func keyboardWillShow(_ notification: Notification) {
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(tableView, delay: 0.0)
        }
    }

    @IBAction func discardArticle(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
//        navigationController?.popViewController(animated: true)
    }

    @IBAction func postArticle(_ sender: Any) {
        guard let video = youtube else {
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
            tags.removeAll()
        } else {
            var tag0 = Array(tags[0])
            tag0.remove(at: 0)
            tags[0] = String(tag0)
        }
        tags.append("New")

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
         // Making tags
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
                            // swiftlint:disable force_cast
                            tempArticleIdArray.append(articleId as! String)
                        }
                        tempArticleIdArray.append(video.youtubeId)
                        ref.setValue(tempArticleIdArray)
                    }
                })
            }
        }
        guard let controller = UIStoryboard.detailStoryboard().instantiateViewController(
            withIdentifier: String(describing: DetailViewController.self)
            ) as? DetailViewController else { return }
        controller.youtubeId = self.youtube?.youtubeId
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
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

extension PostArticleViewController: KSTokenViewDelegate {

    func tokenViewDidBeginEditing(_ tokenView: KSTokenView) {
        let offset = CGPoint.init(x: 0, y: self.keyboardHight+120)
        self.tableView.setContentOffset(offset, animated: true)
    }

    func setupTokenView() {
        tokenView.delegate = self
        tokenView.promptText = " Tags: "
        tokenView.placeholder = " 3 tags at most"
        tokenView.maxTokenLimit = 3
        tokenView.minimumCharactersToSearch = 0 // Show all results without without typing anything
        tokenView.style = .squared
        tokenView.direction = .vertical
        tokenView.cursorColor = .black
        tokenView.paddingY = 10
        tokenView.marginY = tokenView.paddingY
        tokenView.searchResultHeight = 120
    }

    func tokenView(_ tokenView: KSTokenView, performSearchWithString string: String, completion: ((_ results: [AnyObject]) -> Void)?) {

        if string.isEmpty {
            completion!(storedTags.filter({ $0 != "New" }) as [AnyObject])
            return
        }

        var data: [String] = []
        for value: String in storedTags.filter({ $0 != "New" }) {
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
