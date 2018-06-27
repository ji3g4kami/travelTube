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
import CodableFirebase
import CoreData

class DetailViewController: UIViewController, DetailVideoDelegate {
    func resize(_ contentsize: CGSize) {
        videoContainerView.frame = CGRect(origin: videoContainerView.frame.origin, size: contentsize)
        videoContainerHeightConstraint.constant = contentsize.height
        tableView.layoutIfNeeded()
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextView: GrowingTextView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var videoContainerHeightConstraint: NSLayoutConstraint!

    var articleInfo: Article?
    var comments = [Comment]()
    var annotations = [MKPointAnnotation]()
    var destination: MKAnnotation?
    weak var mapController: DetailMapViewController?
    weak var videoController: DetailVideoViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let articleId = articleInfo?.articleId else { return }
        syncWithFirebase(of: articleId)
        hideKeyboardWhenTappedAround()
        setupTableView()
        setupNavigationBar()
        getComments(of: articleId, goToBottom: false)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateFromEdit(_:)), name: NSNotification.Name(rawValue: "updateFromEdit"), object: nil)
    }

    func syncWithFirebase(of articleId: String) {
        FirebaseManager.shared.getArticleInfo(of: articleId) { (article, error) in
            if error == nil {
                self.articleInfo = article
                self.setupNavigationBar()
                self.mapController?.articleInfo = article
                self.mapController?.setupMap()
                self.videoController?.articleInfo = article
                self.videoController?.collectionView.reloadData()
            } else {
                let alert = UIAlertController(title: "找不到此文章", message: nil, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                    guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Preserved")
                    do {
                        guard let result = try managedContext.fetch(fetchRequest) as? [Preserved] else { return }
                        for record in result {
                            if record.articleId == articleId {
                                managedContext.delete(record)
                                print("Deleted: \(String(describing: record.youtubeTitle))")
                                CoreDataManager.shared.getArticlesFromCoreData()
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateFromCoreData"), object: nil)
                            }
                        }
                    } catch {
                        debugPrint("Could not delete: \(error.localizedDescription)")
                    }
                    do {
                        try managedContext.save()
                        print("\nSuccessfully deleted data\n")
                        self.dismiss(animated: true, completion: nil)
                    } catch {
                        debugPrint("\nCould not delete: \(error.localizedDescription)\n")
                        self.dismiss(animated: true, completion: nil)
                    }
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    @IBAction func toggleSegment(_ sender: AnyObject) {
        switch segmentControl.selectedSegmentIndex {
        case 1:
            videoContainerView.alpha = 0
            mapContainerView.alpha = 1
        default:
            videoContainerView.alpha = 1
            mapContainerView.alpha = 0
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let headerView = self.tableView.tableHeaderView else { return }
        let size = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        if headerView.frame.size.height != size.height {
            headerView.frame.size.height = size.height
            tableView.tableHeaderView = headerView
            tableView.layoutIfNeeded()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEdit" {
            guard let controller = segue.destination as? EditArticleViewController else { return }
            controller.articleInfo = self.articleInfo
            controller.detailController = self
        } else if segue.identifier == "toVideo" {
            guard let controller = segue.destination as? DetailVideoViewController else { return }
            controller.articleInfo = self.articleInfo
            controller.delegate = self
            videoController = controller
        } else if segue.identifier == "toMap" {
            guard let controller = segue.destination as? DetailMapViewController else { return }
            controller.articleInfo = self.articleInfo
            mapController = controller
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func setupNavigationBar() {
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backToRootView))
        self.navigationItem.leftBarButtonItem = newBackButton
        if articleInfo?.uid == UserManager.shared.uid {
            editButton.isHidden = false
            likeButton.isHidden = true
        } else {
            editButton.isHidden = true
            likeButton.isHidden = false
            setupLikeButton()
        }
    }

    func setupLikeButton() {
        guard let articleId = articleInfo?.articleId else { return }
        if CoreDataManager.shared.preservedArticleId.contains(articleId) {
            likeButton.setImage(#imageLiteral(resourceName: "like_btn_selected"), for: .normal)
        } else {
            likeButton.setImage(#imageLiteral(resourceName: "like_btn_unselected"), for: .normal)
        }
    }

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        let xib = UINib(nibName: String(describing: CommentCell.self), bundle: nil)
        tableView.register(xib, forCellReuseIdentifier: String(describing: CommentCell.self))
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    func getComments(of articleId: String, goToBottom: Bool) {
        FirebaseManager.shared.ref.child("comments").child(articleId).queryOrdered(byChild: "createdTime").queryStarting(atValue: 0).observe(.value) { (snapshot) in
            self.comments.removeAll()
            if let data = snapshot.value as? [String: [String: Any]] {
                self.comments.removeAll()
                for (key, value) in data {
                    if let comment = value["comment"] as? String, let createdTime = value["createdTime"] as? TimeInterval, let userName = value["userName"] as? String, let userImage = value["userImage"] as? String, let userId = value["userId"] as? String {
                        let comment = Comment(commentId: key, comment: comment, createdTime: createdTime, userId: userId, userName: userName, userImage: userImage)
                        self.comments.append(comment)
                    }
                }
                CoreDataManager.shared.blackList.forEach({ (blackListUser) in
                    self.comments = self.comments.filter { $0.userId != blackListUser.uid }
                })
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

    @objc func updateFromEdit(_ notification: NSNotification) {
        if let annotations = notification.userInfo?["annotations"] as? [Annotation] {
            articleInfo?.annotations = annotations
        }
        if let tags = notification.userInfo?["tags"] as? [String] {
            articleInfo?.tag = tags
        }
    }

    @IBAction func sendCommentPressed(_ sender: Any) {
        guard let articleId = articleInfo?.articleId else { return }
        guard let comment = commentTextView.text else { return }
        commentTextView.text = nil
        FirebaseManager.shared.ref.child("comments").child(articleId).childByAutoId().setValue([
            "userId": UserManager.shared.uid,
            "userName": UserManager.shared.userName,
            "userImage": UserManager.shared.userImage ?? "https://image.flaticon.com/icons/svg/17/17004.svg",
            "comment": comment,
            "createdTime": Firebase.ServerValue.timestamp()
            ])
        getComments(of: articleId, goToBottom: true)
    }

    @IBAction func leaveButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func preservePressed(_ sender: UIButton) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        guard let articleInfo = articleInfo else { return }
        if !CoreDataManager.shared.preservedArticleId.contains(articleInfo.articleId) {
            likeButton.setImage(#imageLiteral(resourceName: "like_btn_selected"), for: .normal)
            let preserved = Preserved(context: managedContext)
            preserved.articleId = articleInfo.articleId
            preserved.youtubeId = articleInfo.youtubeId
            preserved.tags = articleInfo.tag
            preserved.youtubeImage = articleInfo.youtubeImage
            preserved.youtubeTitle = articleInfo.youtubeTitle
            do {
                try managedContext.save()
                print("\nSuccessfully saved data\n")
                CoreDataManager.shared.getArticlesFromCoreData()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateFromCoreData"), object: nil)
            } catch {
                debugPrint("\nCould not save: \(error.localizedDescription)\n")
            }
        } else {
            likeButton.setImage(#imageLiteral(resourceName: "like_btn_unselected"), for: .normal)
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Preserved")
            do {
                guard let result = try managedContext.fetch(fetchRequest) as? [Preserved] else { return }
                for record in result {
                    if record.articleId == articleInfo.articleId {
                        managedContext.delete(record)
                        print("Deleted: \(String(describing: record.youtubeTitle))")
                        CoreDataManager.shared.getArticlesFromCoreData()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateFromCoreData"), object: nil)
                    }
                }
            } catch {
                debugPrint("Could not delete: \(error.localizedDescription)")
            }
            do {
                try managedContext.save()
                print("\nSuccessfully deleted data\n")
            } catch {
                debugPrint("\nCould not delete: \(error.localizedDescription)\n")
            }
        }
    }
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource, CommentCellDelegate {
    func commentCellDidTapProfile(_ sender: CommentCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        if comments[tappedIndexPath.row].userId == UserManager.shared.uid {
            return
        }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let banAction = UIAlertAction(title: "把 \(comments[tappedIndexPath.row].userName) 加入黑名單", style: .destructive, handler: { _ in
            CoreDataManager.shared.addToBlackList(uid: self.comments[tappedIndexPath.row].userId, userName: self.comments[tappedIndexPath.row].userName, userImage: self.comments[tappedIndexPath.row].userImage)
            CoreDataManager.shared.getBlackList()
            guard let articleId = self.articleInfo?.articleId else { return }
            self.getComments(of: articleId, goToBottom: false)
        })
        alertController.addAction(cancelAction)
        alertController.addAction(banAction)
        self.present(alertController, animated: true, completion: nil)
    }

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
            cell.delegate = self
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
                controller.articleId = self.articleInfo?.articleId
                self.present(controller, animated: true, completion: nil)
            }
            completion(true)
        }
        action.image = #imageLiteral(resourceName: "pencil")
        return action
    }

    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completion) in
            guard let articleId = self.articleInfo?.articleId else { return }
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
