//
//  HistoryArticleViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/6/4.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import CodableFirebase

protocol HistoryScrollDelegate: class {

    func moveAccordingTo(collectionView: UICollectionView, scrollY: CGFloat)
}

class HistoryArticleViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var articleArray = [Article]()
    weak var delegate: HistoryScrollDelegate?
    var profileViewHeight: CGFloat = 300

    override func viewDidLoad() {
        super.viewDidLoad()
        requestUserArticle()
    }

    func requestUserArticle() {
        guard let uid = UserManager.shared.uid else { return }
        FirebaseManager.shared.ref.child("articles").queryOrdered(byChild: "uid").queryEqual(toValue: uid).observe(.value) { (snapshot) in
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else { return }
            self.articleArray.removeAll()
            for child in children {
                guard let value = child.value else { return }
                do {
                    let article = try FirebaseDecoder().decode(Article.self, from: value)
                    self.articleArray.append(article)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                } catch {
                    print(error)
                }
            }
        }
    }

    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let xib = UINib(nibName: "ArticleCollectionViewCell", bundle: nil)
        collectionView.register(xib, forCellWithReuseIdentifier: "articleCell")

        collectionView.contentInset = UIEdgeInsets(top: profileViewHeight, left: 0, bottom: 0, right: 0)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.moveAccordingTo(collectionView: collectionView, scrollY: scrollView.contentOffset.y)
    }
}

extension HistoryArticleViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articleArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell: ArticleCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "articleCell", for: indexPath) as? ArticleCollectionViewCell {
            cell.youtubeImage.sd_setImage(with: URL(string: articleArray[indexPath.row].youtubeImage), placeholderImage: #imageLiteral(resourceName: "lantern"))
            cell.titleLabel.text = articleArray[indexPath.row].youtubeTitle
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let controller = UIStoryboard.detailStoryboard().instantiateViewController(
            withIdentifier: String(describing: DetailViewController.self)
            ) as? DetailViewController else { return }
        controller.youtubeId = articleArray[indexPath.row].youtubeId
        controller.articleId = articleArray[indexPath.row].articleId
        controller.hidesBottomBarWhenPushed = true
        self.present(controller, animated: true, completion: nil)
    }
}

extension HistoryArticleViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = Double(collectionView.frame.size.width)/2 - 15

        let height = width*27/32

        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}
