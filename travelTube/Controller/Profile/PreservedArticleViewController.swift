//
//  PreservedArticleViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/6/5.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import CoreData

protocol PreseveScrollDelegate: class {
    func moveAccordingToPreserve(collectionView: UICollectionView, scrollY: CGFloat)
}

class PreservedArticleViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    weak var delegate: PreseveScrollDelegate?
    var profileViewHeight: CGFloat = 300

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateFromCoreData(_:)), name: NSNotification.Name(rawValue: "updateFromCoreData"), object: nil)
    }

    @objc func updateFromCoreData(_ notification: NSNotification) {
        self.collectionView.reloadData()
    }

    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let xib = UINib(nibName: "ArticleCollectionViewCell", bundle: nil)
        collectionView.register(xib, forCellWithReuseIdentifier: "articleCell")

        collectionView.contentInset = UIEdgeInsets(top: profileViewHeight, left: 0, bottom: 0, right: 0)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.moveAccordingToPreserve(collectionView: collectionView, scrollY: scrollView.contentOffset.y)
    }

}

extension PreservedArticleViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CoreDataManager.shared.preservedArticle.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell: ArticleCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "articleCell", for: indexPath) as? ArticleCollectionViewCell {
            cell.youtubeImage.sd_setImage(with: URL(string: CoreDataManager.shared.preservedArticle[indexPath.row].youtubeImage), placeholderImage: #imageLiteral(resourceName: "lantern"))
            cell.titleLabel.text = CoreDataManager.shared.preservedArticle[indexPath.row].youtubeTitle
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let controller = UIStoryboard.detailStoryboard().instantiateViewController(
            withIdentifier: String(describing: DetailViewController.self)
            ) as? DetailViewController else { return }
        let article = CoreDataManager.shared.preservedArticle[indexPath.row]
        controller.articleInfo = Article(annotations: [Annotation](), tag: article.tags, uid: "", articleId: article.articleId, updateTime: Date(timeIntervalSince1970: 0), youtubeId: article.youtubeId, youtubeImage: article.youtubeImage, youtubePublishDate: Date(timeIntervalSince1970: 0), youtubeTitle: article.youtubeTitle)
        controller.hidesBottomBarWhenPushed = true
        self.present(controller, animated: true, completion: nil)
    }
}

extension PreservedArticleViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = Double(collectionView.frame.size.width)/2 - 15

        let height = width*27/32

        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}
