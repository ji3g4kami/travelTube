//
//  DetailViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/15.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import MapKit
import YouTubePlayer
import CodableFirebase
import AMScrollingNavbar

class DetailViewController: UIViewController {

    @IBOutlet weak var youtubePlayer: YouTubePlayerView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    var youtubeId: String?
    var articleInfo: Article?

    override func viewDidLoad() {
        super.viewDidLoad()
        youtubePlayer.playerVars = ["playsinline": "1"] as YouTubePlayerView.YouTubePlayerParameters
        guard let youtubeId = youtubeId else { return }
        youtubePlayer.loadVideoID(youtubeId)
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backToSearch))
        self.navigationItem.leftBarButtonItem = newBackButton
        getArticleInfo(of: youtubeId)
    }

    @objc func backToSearch() {
        self.navigationController?.popToRootViewController(animated: true)
    }

    func getArticleInfo(of youtubeId: String) {
        FirebaseManager.shared.ref.child("articles").child(youtubeId).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value else { return }
            do {
                self.articleInfo = try FirebaseDecoder().decode(Article.self, from: value)
                self.setupMap()
            } catch {
                print(error)
            }
        })
    }

    func setupMap() {
        guard let annotaions = articleInfo?.annotations else { return }
        let marker = MKPointAnnotation()
        marker.title = annotaions[0].title
        marker.coordinate = CLLocationCoordinate2DMake(annotaions[0].latitude, annotaions[0].logitutde)
        mapView.addAnnotation(marker)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(tableView, delay: 0.0)
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func exitButtonPressed(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
