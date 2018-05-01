//
//  CategoryCell.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/4/30.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var articleCollectionView: UICollectionView!
    let taipeiVideo: [String] = ["R_QzFdQp4_4", "kPFQCpzLTME", "CRq3hOFqlgI"]
    let taichungVideo: [String] = ["LKbQDq6Q9eI", "Xn8VB0CQFUw"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let xib = UINib(nibName: "ArticleCollectionViewCell", bundle: nil)
        articleCollectionView.register(xib, forCellWithReuseIdentifier: "articleCell")
        
        articleCollectionView.delegate = self
        articleCollectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return taipeiVideo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell: ArticleCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "articleCell", for: indexPath) as? ArticleCollectionViewCell{
            cell.videoPlayer.loadVideoID(taipeiVideo[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let size = CGSize(width: 150, height: 120)
        return size
    }
    
    
}
