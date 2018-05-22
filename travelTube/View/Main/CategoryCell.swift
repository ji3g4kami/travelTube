//
//  CategoryCell.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/4/30.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import SDWebImage
import CodableFirebase

protocol CategoryCellDelegate: class {
    func colCategorySelected(youtubeId: String)
}

class CategoryCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var articleCollectionView: UICollectionView!
    var articleIdArray = [String]()
    var articleArray = [Article]()
    weak var delegate: CategoryCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        let xib = UINib(nibName: "ArticleCollectionViewCell", bundle: nil)
        articleCollectionView.register(xib, forCellWithReuseIdentifier: "articleCell")

        articleCollectionView.delegate = self
        articleCollectionView.dataSource = self
    }

    func requstArticleData() {
        articleArray.removeAll()
        for articleId in self.articleIdArray {
            FirebaseManager.shared.ref.child("articles").child(articleId).observeSingleEvent(of: .value) { (snapshot) in
                guard let value = snapshot.value else { return }
                do {
                    let article = try FirebaseDecoder().decode(Article.self, from: value)
                    self.articleArray.append(article)
                    DispatchQueue.main.async {
                        self.articleCollectionView.reloadData()
                    }
                } catch {
                    print(error)
                }
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(articleIdArray[indexPath.row])
        delegate?.colCategorySelected(youtubeId: articleIdArray[indexPath.row])
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articleArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell: ArticleCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "articleCell", for: indexPath) as? ArticleCollectionViewCell {
            cell.youtubeImage.sd_setImage(with: URL(string: articleArray[indexPath.row].youtubeImage), placeholderImage: #imageLiteral(resourceName: "youtube"))
            cell.titleLabel.text = articleArray[indexPath.row].youtubeTitle
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height*5/4, height: collectionView.frame.height)
    }

}
