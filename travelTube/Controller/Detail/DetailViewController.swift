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
import TagListView

class DetailViewController: UIViewController {

    @IBOutlet weak var youtubePlayer: YouTubePlayerView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var tagsView: TagListView!

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
                    if let comment = value["comment"] as? String, let createdTime = value["createdTime"] as? TimeInterval, let userName = value["userName"] as? String, let userImage = value["userImage"] as? String, let userId = value["userId"] as? String {
                        let comment = Comment(commentId: key, comment: comment, createdTime: createdTime, userId: userId, userName: userName, userImage: userImage)
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
                self.setupInfo()
                self.setupTags()
            } catch {
                print(error)
            }
        })
    }

    func setupTags() {
        guard var articleTags = articleInfo?.tag else { return }
        articleTags = articleTags.filter { $0 != "New" }
        self.tagsView.addTags(articleTags)
        tagsView.textFont = UIFont.systemFont(ofSize: 18)
        tagsView.alignment = .left
    }

    func setupInfo() {
        guard let article = articleInfo else { return }
        titleLabel.text = article.youtubeTitle
        DispatchQueue.main.async {
            guard let headerView = self.tableView.tableHeaderView else { return }
            headerView.frame.size.height = self.youtubePlayer.frame.size.height + self.mapView.frame.size.height + self.infoView.frame.height
            self.tableView.reloadData()
        }
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
            "userId": UserManager.shared.uid,
            "userName": UserManager.shared.userName,
            "userImage": UserManager.shared.userImage ?? "https://image.flaticon.com/icons/svg/17/17004.svg",
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
        if comments[indexPath.row].userId == UserManager.shared.uid {
            let edit = editAction(at: indexPath)
            let delete = deleteAction(at: indexPath)
            return UISwipeActionsConfiguration(actions: [edit, delete])
        } else {
            let report = reportAction(at: indexPath)
            return UISwipeActionsConfiguration(actions: [report])
        }
    }

    func editAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Edit") { (_, _, completion) in
            let storyboard = UIStoryboard(name: "Detail", bundle: nil)
            if let controller = storyboard.instantiateViewController(withIdentifier: "CommentViewController") as? CommentViewController {
                controller.comment = self.comments[indexPath.row]
                controller.articleId = self.youtubeId
                self.present(controller, animated: true, completion: nil)
            }
            completion(true)
        }
        action.image = #imageLiteral(resourceName: "pencil")
        return action
    }

    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completion) in
            guard let articleId = self.youtubeId else { return }
            FirebaseManager.shared.ref.child("comments/\(articleId)").child(self.comments[indexPath.row].commentId).removeValue()
            completion(true)
        }
        action.image = #imageLiteral(resourceName: "trash")
        return action
    }

    func reportAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Report") { (_, _, completion) in
            let alert = UIAlertController(title: "Dislike report", message: "You've just reported an controvertial content.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            FirebaseManager.shared.ref.child("reports").child("comments").setValue(self.comments[indexPath.row].commentId)
        }
        action.image = #imageLiteral(resourceName: "ban")
        return action
    }
}

struct Comment {
    let commentId: String
    var comment: String
    let createdTime: TimeInterval
    let userId: String
    let userName: String
    let userImage: String
}
