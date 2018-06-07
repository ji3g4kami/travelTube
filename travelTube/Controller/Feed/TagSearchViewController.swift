//
//  TagSearchViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/6/7.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import Firebase

class TagSearchViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var storedTags = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        queryTags()
        setupCollectionView()
    }

    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self

        let xib = UINib(nibName: "TagCell", bundle: nil)
        collectionView.register(xib, forCellWithReuseIdentifier: "TagCell")
    }

    func queryTags() {
        FirebaseManager.shared.ref.child("tags").queryOrdered(byChild: "tag").observeSingleEvent(of: .value) { (snapshot) in
            if let articleTag = snapshot.value as? [String: Any] {
                for (_, value) in articleTag {
                    guard let valueDict = value as? [String: String], let tagName = valueDict["tag"] else { return }
                    self.storedTags.append(tagName)
                    self.storedTags = Array(Set(self.storedTags))
                }
                self.collectionView.reloadData()
            }
        }
    }

    @IBAction func dismissButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension TagSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storedTags.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as? TagCell {
            cell.tagButton.setTitle(storedTags[indexPath.row], for: .normal)
            return cell
        }
        return UICollectionViewCell()
    }
}

extension TagSearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let font = UIFont(name: "Helvetica", size: 23) else { return CGSize(width: 50, height: 30) }

        let attributes = [NSAttributedStringKey.font: font]
        let text = storedTags[indexPath.row]
        let width = text.size(withAttributes: attributes).width + 15
        let height = text.size(withAttributes: attributes).height + 10
        return CGSize(width: width, height: height)
    }
}

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }

            layoutAttribute.frame.origin.x = leftMargin

            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }

        return attributes
    }
}
