//
//  PreviewYoutbeViewController.swift
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

class PreviewYoutbeViewController: UIViewController {

    var youtube: Video?
    var storedTags = [String]()
    var annotations: [MKPointAnnotation] = []

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var youtubePlayer: YouTubePlayerView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tokenView: KSTokenView!
    @IBOutlet weak var annotationTextField: UITextField!
    @IBOutlet weak var annotationTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        youtubePlayer.playerVars = ["playsinline": "1"] as YouTubePlayerView.YouTubePlayerParameters
        if let youtubeId = youtube?.youtubeId {
            youtubePlayer.loadVideoID(youtubeId)
        }
        queryTags()
        setupTokenView()
        annotationTableView.delegate = self
        annotationTableView.dataSource = self
        let xib = UINib(nibName: "AnnotationCell", bundle: nil)
        annotationTableView.register(xib, forCellReuseIdentifier: "AnnotationCell")
    }

    func queryTags() {
        FirebaseManager.shared.ref.child("tages").observeSingleEvent(of: .value) { (snapshot) in
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
        if let title = annotationTextField.text {
            annotation.title = title
            mapView.addAnnotation(annotation)
            annotations.append(annotation)
            annotationTableView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
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
        let tags: [String] = tokenView.text.components(separatedBy: ", ")
        let newArticleId = FirebaseManager.shared.ref.childByAutoId().key
        FirebaseManager.shared.ref.child("articles").child(newArticleId).setValue([
            "youtubeTitle": video.title,
            "youtubeImage": video.image,
            "youtubePublishDate": video.publishDate,
            "youtubeId": video.youtubeId,
            "postTime": Date().timeIntervalSince1970,
            "uid": UserManager.shared.uid,
            "annotations": markers,
            "status": "post",
            "tag": tags
        ])
        // Making tags
        for tag in tags {
            var tempArticleIdArray = [String]()
            let ref = FirebaseManager.shared.ref.child("tages").child("\(tag)")
            // new tag
            if !storedTags.contains(tag) {
                tempArticleIdArray.append(newArticleId)
                ref.setValue(tempArticleIdArray)
            } else {
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let value = snapshot.value as? NSArray {
                        for articleId in value {
                            // swiftlint:disable force_cast
                            tempArticleIdArray.append(articleId as! String)
                        }
                        tempArticleIdArray.append(newArticleId)
                        ref.setValue(tempArticleIdArray)
                    }
                })
            }
        }
    }

}

extension PreviewYoutbeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return annotations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = annotationTableView.dequeueReusableCell(withIdentifier: "AnnotationCell") as? AnnotationCell else {
            return UITableViewCell()
        }
        cell.textField.text = annotations[indexPath.row].title
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

extension PreviewYoutbeViewController: KSTokenViewDelegate {

    func setupTokenView() {
        tokenView.delegate = self
        tokenView.promptText = " Tags: "
        tokenView.placeholder = " 3 tags at most"
        tokenView.maxTokenLimit = 3
        tokenView.minimumCharactersToSearch = 0 // Show all results without without typing anything
        tokenView.style = .rounded
        tokenView.direction = .vertical
        tokenView.cursorColor = .black
        tokenView.paddingY = 10
        tokenView.marginY = tokenView.paddingY
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
