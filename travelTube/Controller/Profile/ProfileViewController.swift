//
//  ProfileViewController.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/8.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import FirebaseStorage
import SDWebImage
import Firebase
import CodableFirebase

class ProfileViewController: UIViewController, HistoryScrollDelegate, PreseveScrollDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userProfileView: UIView!
    @IBOutlet weak var historyArticleContainer: UIView!
    @IBOutlet weak var preserveArticleContainer: UIView!

    var historyViewController: HistoryArticleViewController?
    var preserveViewController: PreservedArticleViewController?
    var statusBarAndNavbarHeight: CGFloat = 65.0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarItems()
        userImageView.isUserInteractionEnabled = true
        let touch = UITapGestureRecognizer(target: self, action: #selector(bottomAlert))
        userImageView.addGestureRecognizer(touch)
        setUserProfile()
        swipeRightToLogout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let navigationbarHight = self.navigationController?.navigationBar.frame.size.height {
            let statusbarHeight = UIApplication.shared.statusBarFrame.height
            self.statusBarAndNavbarHeight = navigationbarHight + statusbarHeight
        }

        historyViewController?.profileViewHeight =  userProfileView.frame.size.height
        historyViewController?.setupCollectionView()

        preserveViewController?.profileViewHeight =  userProfileView.frame.size.height
        preserveViewController?.setupCollectionView()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toHistory" {
            let historyArticleViewController = segue.destination as? HistoryArticleViewController
            historyArticleViewController?.delegate = self
            historyViewController = historyArticleViewController
        } else if segue.identifier == "toPreserve" {
            let preserveArticleViewController = segue.destination as? PreservedArticleViewController
            preserveArticleViewController?.delegate = self
            preserveViewController = preserveArticleViewController
        }
    }

    func moveAccordingTo(collectionView: UICollectionView, scrollY: CGFloat) {
        userProfileView.frame = CGRect(origin: CGPoint(x: 0, y: statusBarAndNavbarHeight - userProfileView.frame.size.height - scrollY), size: userProfileView.frame.size)
        preserveViewController?.collectionView.contentOffset.y = scrollY
    }

    func moveAccordingToPreserve(collectionView: UICollectionView, scrollY: CGFloat) {
        userProfileView.frame = CGRect(origin: CGPoint(x: 0, y: statusBarAndNavbarHeight - userProfileView.frame.size.height - scrollY), size: userProfileView.frame.size)
        historyViewController?.collectionView.contentOffset.y = scrollY
    }

    func swipeRightToLogout() {
        let leftSwipe = UISwipeGestureRecognizer(target: self.revealViewController(), action: #selector(SWRevealViewController.rightRevealToggle(_:)))
        leftSwipe.direction = .left
        self.view.addGestureRecognizer(leftSwipe)
    }

    private func setupNavigationBarItems() {
        let menuButton = UIButton(type: .system)
        menuButton.setImage(#imageLiteral(resourceName: "menu").withRenderingMode(.automatic), for: .normal)
        menuButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: menuButton)
        menuButton.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
    }

    private func setUserProfile() {
        // set profile image
        guard let uid = UserManager.shared.uid else { return }
        FirebaseManager.shared.ref.child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? NSDictionary, let image = value["image"] as? String else { return }
            self.userImageView.sd_setImage(with: URL(string: image), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        }

        // set profile name
        nameLabel.text = UserManager.shared.userName
    }

    @IBAction func toggleSegment(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            historyArticleContainer.alpha = 0
            preserveArticleContainer.alpha = 1
        default:
            historyArticleContainer.alpha = 1
            preserveArticleContainer.alpha = 0
        }
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func bottomAlert() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let photoAction = UIAlertAction(title: "Photo", style: .default) { _ in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            self.present(picker, animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(photoAction)
        alertController.addAction(cameraAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        if picker.sourceType == .camera {
            UIImageWriteToSavedPhotosAlbum(image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        userImageView.image = image
        FirebaseManager.shared.updateProfilePhoto(uploadImage: image)
        dismiss(animated: true, completion: nil)
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let alertController = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            present(alertController, animated: true)
        }
    }
}
