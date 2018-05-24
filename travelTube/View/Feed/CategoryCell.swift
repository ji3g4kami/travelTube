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
    var articlesOfTag: ArticlesOfTag?
    weak var delegate: CategoryCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        let xib = UINib(nibName: "ArticleCollectionViewCell", bundle: nil)
        articleCollectionView.register(xib, forCellWithReuseIdentifier: "articleCell")

        articleCollectionView.delegate = self
        articleCollectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print(articleIdArray[indexPath.row])
//        delegate?.colCategorySelected(youtubeId: articlesOfTag[indexPath.row])
//    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let numbersOfArticle = articlesOfTag?.articles.count else { return 1}
        return numbersOfArticle
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell: ArticleCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "articleCell", for: indexPath) as? ArticleCollectionViewCell {
            guard let youtubeImage = articlesOfTag?.articles[indexPath.row].youtubeImage else { return cell }
            guard let youtubeTitle = articlesOfTag?.articles[indexPath.row].youtubeTitle else { return cell }
            cell.youtubeImage.sd_setImage(with: URL(string: youtubeImage), placeholderImage: #imageLiteral(resourceName: "youtube"))
            cell.titleLabel.text = youtubeTitle
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height*5/4, height: collectionView.frame.height)
    }

}
