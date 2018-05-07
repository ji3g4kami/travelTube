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

class PreviewYoutbeViewController: UIViewController {

    var youtubeId: String = ""
    let names: [String] = ["Taiwan", "Delicacy", "History"]
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
        youtubePlayer.loadVideoID(youtubeId)

        setupTokenView()
        annotationTableView.delegate = self
        annotationTableView.dataSource = self
        let xib = UINib(nibName: "AnnotationCell", bundle: nil)
        annotationTableView.register(xib, forCellReuseIdentifier: "AnnotationCell")
    }

    @IBAction func postButtonPreesed(_ sender: UIButton) {
        let article = [
            "youtubeId": self.youtubeId,
            "annotations": self.annotations
            ] as [String: Any]
        print(article)
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
            completion!(names as [AnyObject])
            return
        }

        var data: [String] = []
        for value: String in names {
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
