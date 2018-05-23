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
    var annotations = [MKPointAnnotation]()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let youtubeId = youtubeId else { return }
        setupTableView()
        setupNavigationBar()
        setupYoutubePlayer(of: youtubeId)
        getArticleInfo(of: youtubeId)
        getComments(of: youtubeId)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let mapViewController = segue.destination as? MapViewController
        mapViewController?.annotations = self.annotations
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("Detail")
        guard let headerView = tableView.tableHeaderView else { return }
        headerView.frame.size.height = youtubePlayer.frame.size.height + mapView.frame.size.height + 50
    }

    func setupNavigationBar() {
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backToRootView))
        self.navigationItem.leftBarButtonItem = newBackButton
    }

    func setupYoutubePlayer(of youtubeId: String) {
        youtubePlayer.playerVars = ["playsinline": "1"] as YouTubePlayerView.YouTubePlayerParameters
        youtubePlayer.loadVideoID(youtubeId)
    }

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        let xib = UINib(nibName: String(describing: CommentCell.self), bundle: nil)
        tableView.register(xib, forCellReuseIdentifier: String(describing: CommentCell.self))
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    func getComments(of youtubeId: String) {
        FirebaseManager.shared.ref.child("comments").child(youtubeId).queryOrdered(byChild: "createdTime").queryStarting(atValue: 0).observe(.value) { (snapshot) in
            self.comments.removeAll()
            if let data = snapshot.value as? [String: [String: Any]] {
                self.comments.removeAll()
                for (key, value) in data {
                    if let comment = value["comment"] as? String, let createdTime = value["createdTime"] as? TimeInterval, let userName = value["userName"] as? String, let userImage = value["userImage"] as? String {
                        let comment = Comment(commentId: key, comment: comment, createdTime: createdTime, userName: userName, userImage: userImage)
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

    @objc func backToRootView() {
        self.navigationController?.popToRootViewController(animated: true)
    }

    // TODO: closure or delegate
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
            self.annotations.append(marker)
        }
        mapView.addAnnotations(self.annotations)
        mapView.showAnnotations(mapView.annotations, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(tableView, delay: 0.0)
        }
    }

    @IBAction func sendCommentPressed(_ sender: Any) {
        guard let youtubeId = youtubeId else { return }
        guard let comment = commentTextField.text else { return }
        commentTextField.text = nil
        FirebaseManager.shared.ref.child("comments").child(youtubeId).childByAutoId().setValue([
            "userName": UserManager.shared.userName,
            "userImage": UserManager.shared.userImage,
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
            cell.nameLabel.text = comments[indexPath.row].userName
            cell.userProfileImage.sd_setImage(with: URL(string: comments[indexPath.row].userImage), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = editAction(at: indexPath)
//        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [edit/*, delete*/])
    }

    func editAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            let storyboard = UIStoryboard(name: "Detail", bundle: nil)
            if let controller = storyboard.instantiateViewController(withIdentifier: "CommentViewController") as? CommentViewController {
                self.present(controller, animated: true, completion: nil)
            } 
//            self.commentTextField.text = self.comments[indexPath.row].comment
            completion(true)
        }
        action.image = #imageLiteral(resourceName: "pencil")
        return action
    }
}

struct Comment {
    let commentId: String
    var comment: String
    let createdTime: TimeInterval
    let userName: String
    let userImage: String
}
