//
//  DetailVideoViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/6/25.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import YouTubePlayer

protocol DetailVideoDelegate: class {
    func resize(_ contentsize: CGSize)
}

class DetailVideoViewController: UIViewController {

    @IBOutlet weak var blockRightYoutubeButton: UIView!
    @IBOutlet weak var youtubePlayer: YouTubePlayerView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!

    var articleInfo: Article?
    weak var delegate: DetailVideoDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let youtubeId = articleInfo?.youtubeId else { return }
        setupYoutubePlayer(of: youtubeId)
        setupInfoView()
    }

    func setupInfoView() {
        titleLabel.text = articleInfo?.youtubeTitle
        setupTagCollection()
        if UserManager.shared.uid == articleInfo?.uid {
            deleteButton.isHidden = false
            reportButton.isHidden = true
        } else {
            deleteButton.isHidden = true
            reportButton.isHidden = false
        }
    }

    func setupTagCollection() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let xib = UINib(nibName: String(describing: HashTagCell.self), bundle: nil)
        collectionView.register(xib, forCellWithReuseIdentifier: String(describing: HashTagCell.self))
    }

    func setupYoutubePlayer(of youtubeId: String) {
        youtubePlayer.delegate = self
        youtubePlayer.playerVars = ["playsinline": "1", "showinfo": "0", "modestbranding": "1"] as YouTubePlayerView.YouTubePlayerParameters
        youtubePlayer.loadVideoID(youtubeId)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.preferredContentSize = CGSize(
            width: view.frame.width,
            height: youtubePlayer.frame.height + infoView.frame.height)
        delegate?.resize(preferredContentSize)
    }

    @IBAction func deleteArticlePressed(_ sender: Any) {
        let alert = UIAlertController(title: "刪除貼文", message: nil, preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "刪除", style: .destructive, handler: { _ in
            guard let article  = self.articleInfo else { return }
            guard let articleId = self.articleInfo?.articleId else { return }
            FirebaseManager.shared.ref.child("articles").child(articleId).removeValue()
            FirebaseManager.shared.ref.child("comments").child(articleId).removeValue()
            FirebaseManager.shared.ref.child("tags").queryOrdered(byChild: "articleId").queryEqual(toValue: articleId).observeSingleEvent(of: .value) { (snapshot) in
                guard let valueDict = snapshot.value as? [String: Any] else { return }
                for (key, _) in valueDict {
                    FirebaseManager.shared.ref.child("tags").child(key).removeValue()
                }
            }

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "deleteArticle"), object: nil, userInfo: ["article": article])
            self.dismiss(animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

    @IBAction func reportButtonPressed(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let reportAction = UIAlertAction(title: "檢舉不良內容", style: .default) { _ in
            let reportController = UIAlertController(title: "檢舉", message: "請告訴我們為什麼要檢舉此篇", preferredStyle: .alert)
            reportController.addTextField(configurationHandler: nil)
            let cancelAct = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            let submitAct = UIAlertAction(title: "送出", style: .default) { (action: UIAlertAction!) in
                let alert = UIAlertController(title: "您的檢舉已送出", message: nil, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            reportController.addAction(cancelAct)
            reportController.addAction(submitAct)
            self.present(reportController, animated: true, completion: nil)
        }
        let hideAction = UIAlertAction(title: "我不想看到這個", style: .default) { _ in
            let alert = UIAlertController(title: "隱藏此貼文", message: "您將再也不會看到此貼文", preferredStyle: .alert)
            let confirm = UIAlertAction(title: "確認", style: .default) { _ in
                guard let articleId = self.articleInfo?.articleId else { return }
                CoreDataManager.shared.addToBlackArticle(articleId: articleId)
                CoreDataManager.shared.getBlackArticle()
                self.dismiss(animated: true, completion: nil)
            }
            let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alert.addAction(cancel)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
        }

        alertController.addAction(cancelAction)
        alertController.addAction(reportAction)
        alertController.addAction(hideAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension DetailVideoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let tagCount = articleInfo?.tag?.count else { return 1 }
        return tagCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: HashTagCell.self), for: indexPath) as? HashTagCell, let tags = articleInfo?.tag else { return UICollectionViewCell() }
        cell.tagLabel.text = "#" + tags[indexPath.row]
        return cell
    }
}

extension DetailVideoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let font = UIFont(name: "Helvetica", size: 23), let tags = articleInfo?.tag else { return CGSize(width: 50, height: 30) }
        let attributes = [NSAttributedStringKey.font: font]
        let text = tags[indexPath.row]
        let width = text.size(withAttributes: attributes).width
        let height = text.size(withAttributes: attributes).height
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
}

extension DetailVideoViewController: YouTubePlayerDelegate {
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
        if playerState.rawValue == "1" {
            blockRightYoutubeButton.isHidden = true
        }
    }
}
