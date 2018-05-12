//
//  CategoryCell.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/4/30.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import SDWebImage

class CategoryCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var articleCollectionView: UICollectionView!
    var articleIdArray = [String]()
    var articleImageArray = [String]()

    override func awakeFromNib() {
        super.awakeFromNib()
        let xib = UINib(nibName: "ArticleCollectionViewCell", bundle: nil)
        articleCollectionView.register(xib, forCellWithReuseIdentifier: "articleCell")

        articleCollectionView.delegate = self
        articleCollectionView.dataSource = self

//        NotificationCenter.default.addObserver(self, selector: #selector(requstArticleData), name: NSNotification.Name(rawValue: "Have AricleIds from FeedVC"), object: nil)

    }

    func requstArticleData() {
        articleImageArray.removeAll()
        for articleId in articleIdArray {
            FirebaseManager.shared.ref.child("articles").child(articleId).child("youtubeImage").observeSingleEvent(of: .value) { (snapshot) in
                if let url = snapshot.value as? String {
                    self.articleImageArray.append(url)
                }
                DispatchQueue.main.async {
                    self.articleCollectionView.reloadData()
                }
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articleImageArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell: ArticleCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "articleCell", for: indexPath) as? ArticleCollectionViewCell {
            cell.youtubeImage.sd_setImage(with: URL(string: articleImageArray[indexPath.row]), placeholderImage: #imageLiteral(resourceName: "youtube"))
            cell.layer.cornerRadius = cell.layer.frame.height*0.1
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height*5/4, height: collectionView.frame.height)
    }

}
