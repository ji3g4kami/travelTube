//
//  DetailViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/15.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import YouTubePlayer
import CodableFirebase
import AMScrollingNavbar

class DetailViewController: UIViewController {

    @IBOutlet weak var youtubePlayer: YouTubePlayerView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var commentTextField: UITextField!
    var youtubeId: String?
    var articleInfo: Article?
    var comments = [Comment]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        youtubePlayer.playerVars = ["playsinline": "1"] as YouTubePlayerView.YouTubePlayerParameters
        guard let youtubeId = youtubeId else { return }
        youtubePlayer.loadVideoID(youtubeId)
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backToSearch))
        self.navigationItem.leftBarButtonItem = newBackButton
        getArticleInfo(of: youtubeId)
        getComments(of: youtubeId)
    }

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        let xib = UINib(nibName: String(describing: CommentCell.self), bundle: nil)
        tableView.register(xib, forCellReuseIdentifier: String(describing: CommentCell.self))
    }

    func getComments(of youtubeId: String) {
        FirebaseManager.shared.ref.child("comments").child(youtubeId).queryOrdered(byChild: "createdTime").queryStarting(atValue: 0).observe(.value) { (snapshot) in
            self.comments.removeAll()
            if let data = snapshot.value as? [String: [String: Any]] {
                self.comments.removeAll()
                for (key, value) in data {
                    if let comment = value["comment"] as? String, let createdTime = value["createdTime"] as? TimeInterval, let userName = value["userName"] as? String {
                        let comment = Comment(commentId: key, comment: comment, createdTime: createdTime, userName: userName)
                        self.comments.append(comment)
                    }
                }
                self.comments.sort(by: { (comment1, comment2) -> Bool in
                    comment1.createdTime < comment2.createdTime
                })
                self.tableView.reloadData()
            }
        }
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
        for annotaion in annotaions {
            let marker = MKPointAnnotation()
            marker.title = annotaion.title
            marker.coordinate = CLLocationCoordinate2DMake(annotaion.latitude, annotaion.logitutde)
            mapView.addAnnotation(marker)
        }
        // show the first annotation in center
        let location = CLLocationCoordinate2D(latitude: annotaions[0].latitude, longitude: annotaions[0].logitutde)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
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

//    @IBAction func exitButtonPressed(_ sender: Any) {
//        self.navigationController?.popToRootViewController(animated: true)
//    }

    @IBAction func sendCommentPressed(_ sender: Any) {
        guard let youtubeId = youtubeId else { return }
        guard let comment = commentTextField.text else { return }
        FirebaseManager.shared.ref.child("comments").child(youtubeId).childByAutoId().setValue([
            "userName": UserManager.shared.userName,
            "comment": comment,
            "createdTime": Firebase.ServerValue.timestamp()
            ])
    }
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CommentCell.self), for: indexPath) as? CommentCell {
            cell.commentLabel.text = comments[indexPath.row].comment
            return cell
        }
        return UITableViewCell()
    }
}

struct Comment {
    let commentId: String
    var comment: String
    let createdTime: TimeInterval
    let userName: String
}
