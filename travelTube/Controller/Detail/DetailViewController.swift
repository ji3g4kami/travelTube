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
import TagListView

class DetailViewController: UIViewController {

    @IBOutlet weak var youtubePlayer: YouTubePlayerView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextView: GrowingTextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var tagsView: TagListView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var openInMapButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var reportView: UIView!

    var youtubeId: String?
    var articleInfo: Article?
    var comments = [Comment]()
    var annotations = [MKPointAnnotation]()
    var destination: MKAnnotation?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let youtubeId = youtubeId else { return }
        setupTableView()
        setupNavigationBar()
        setupYoutubePlayer(of: youtubeId)
        getArticleInfo(of: youtubeId)
        getComments(of: youtubeId, goToBottom: false)
        mapView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateFromEdit(_:)), name: NSNotification.Name(rawValue: "updateFromEdit"), object: nil)
    }

    @objc func updateFromEdit(_ notification: NSNotification) {
        let allAnnotations = self.mapView.annotations
        mapView.removeAnnotations(allAnnotations)
        if let annotations = notification.userInfo?["annotations"] as? [MKAnnotation] {
            mapView.addAnnotations(annotations)
        }
        if let tags = notification.userInfo?["tags"] as? [String] {
            tagsView.removeAllTags()
            articleInfo?.tag = tags
            setupTags()
        }
    }

    @IBAction func toggleSegment(_ sender: AnyObject) {
        switch segmentControl.selectedSegmentIndex {
        case 1:
            mapViewContainer.alpha = 1
            youtubePlayer.alpha = 0
            infoView.alpha = 0
        default:
            mapViewContainer.alpha = 0
            youtubePlayer.alpha = 1
            infoView.alpha = 1
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let headerView = self.tableView.tableHeaderView else { return }
        headerView.frame.size.height = youtubePlayer.frame.size.height + infoView.frame.height + bannerView.frame.size.height
        mapViewContainer.frame.size.height = youtubePlayer.frame.size.height + infoView.frame.height
        mapView.frame.size.height = mapViewContainer.frame.size.height - 40
        openInMapButton.frame.origin.y = mapView.frame.origin.y + mapView.frame.size.height + 7
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEdit" {
            guard let controller = segue.destination as? EditArticleViewController else { return }
            controller.articleInfo = self.articleInfo
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func setupNavigationBar() {
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backToRootView))
        self.navigationItem.leftBarButtonItem = newBackButton
    }

    func setupYoutubePlayer(of youtubeId: String) {
        youtubePlayer.playerVars = ["playsinline": "1", "showinfo": "0", "modestbranding": "1"] as YouTubePlayerView.YouTubePlayerParameters
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

    func getComments(of youtubeId: String, goToBottom: Bool) {
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
                if goToBottom {
                    DispatchQueue.main.async {
                        let index = IndexPath(row: self.comments.count-1, section: 0) // use your index number or Indexpath
                        self.tableView.scrollToRow(at: index, at: .middle, animated: true) //here .middle is the scroll position can change it as per your need
                    }
                }
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
                if self.articleInfo?.uid != UserManager.shared.uid {
                    self.editButton.isUserInteractionEnabled = false
                    self.editButton.alpha = 0.3
                    self.deleteButton.alpha = 0
                } else {
                    self.reportView.alpha = 0
                }
            } catch {
                print(error)
            }
        })
    }

    func setupTags() {
        guard let articleTags = articleInfo?.tag else { return }
        self.tagsView.addTags(articleTags)
        tagsView.textFont = UIFont.systemFont(ofSize: 18)
        tagsView.alignment = .left
    }

    func setupInfo() {
        guard let article = articleInfo else { return }
        titleLabel.text = article.youtubeTitle
        DispatchQueue.main.async {
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

            // resize rect to make it look better MKMapRect
            let resizedSpan = MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta*1.1, longitudeDelta: mapView.region.span.longitudeDelta*1.1)
            let resizedRegion = MKCoordinateRegion(center: mapView.region.center, span: resizedSpan)
            mapView.setRegion(resizedRegion, animated: true)

            destination = self.annotations[0]
            guard let titleOptional = destination?.title, let title = titleOptional else { return }
            openInMapButton.setTitle("Open \(title) in Map", for: .normal)
        }

    @IBAction func sendCommentPressed(_ sender: Any) {
        guard let youtubeId = youtubeId else { return }
        guard let comment = commentTextView.text else { return }
        commentTextView.text = nil
        FirebaseManager.shared.ref.child("comments").child(youtubeId).childByAutoId().setValue([
            "userId": UserManager.shared.uid,
            "userName": UserManager.shared.userName,
            "userImage": UserManager.shared.userImage ?? "https://image.flaticon.com/icons/svg/17/17004.svg",
            "comment": comment,
            "createdTime": Firebase.ServerValue.timestamp()
            ])
        getComments(of: youtubeId, goToBottom: true)
    }

    @IBAction func reportButtonPressed(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Report",
            message: "Tell us why is this content inappropriate",
            preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)

        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil)
        alertController.addAction(cancelAction)

        let okAction = UIAlertAction(
            title: "Submit",
            style: UIAlertActionStyle.default) { (action: UIAlertAction!) -> Void in
                let acc = (alertController.textFields?.first)! as UITextField
                let alert = UIAlertController(title: "Report Sent", message: "We will see whether this content is inappropriate", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                print("\(acc.text)")
        }
        alertController.addAction(okAction)

        // 顯示提示框
        self.present(
            alertController,
            animated: true,
            completion: nil)
    }
    @IBAction func leaveButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func deleteArticlePressed(_ sender: Any) {
        let alert = UIAlertController(title: "刪除貼文", message: nil, preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "刪除", style: .destructive, handler: { _ in
            guard let article  = self.articleInfo else { return }
            guard let articleId = self.articleInfo?.youtubeId else { return }
            FirebaseManager.shared.ref.child("articles").child(articleId).removeValue()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "deleteArticle"), object: nil, userInfo: ["article": article])
            self.dismiss(animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

    @IBAction func openMapPressed(_ sender: Any) {
        let regionDistance: CLLocationDistance = 10000
        guard let coordinates = self.destination?.coordinate else { return }
        guard let title = self.destination?.title else { return }
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        mapItem.openInMaps(launchOptions: options)
    }
}

extension DetailViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.destination = view.annotation
        guard let destination = view.annotation?.title, let title = destination else { return }
        openInMapButton.setTitle("Open \(title) in Map", for: .normal)
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
    }

}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "留言"
    }

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
            completion(true)
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
