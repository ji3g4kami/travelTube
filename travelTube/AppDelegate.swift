//
//  AppDelegate.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/4/30.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import IQKeyboardManagerSwift
import SKActivityIndicatorView
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        IQKeyboardManager.shared.enable = true

        if UserManager.shared.isLoggedIn {
            print("LoggedIn with \(UserManager.shared.isLoggedIn)")
        } else {
            toLoginPage()
        }
        Fabric.with([Crashlytics.self])
        return true
    }

    func toMainPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let feedVC = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as? TabBarViewController
        window?.rootViewController = feedVC
    }

    func toLoginPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        window?.rootViewController = loginVC
    }

    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
    }

    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        }

        return Invites.handleUniversalLink(url) { _, error in
            if let err = error {
                print(err)
            }
        }
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error)
            return
        }
        guard let authentication = user.authentication else {return}
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (user, error) in
            SKActivityIndicator.show("Loading...")
            if let error = error {
                print(error)
                SKActivityIndicator.dismiss()
                UIApplication.shared.endIgnoringInteractionEvents()
                return
            }
            if let name = user?.displayName, let email = user?.email, let uid = user?.uid {
                print(name, email)
                UserManager.shared.userName = name
                UserManager.shared.uid = uid
                UserManager.shared.isLoggedIn = true
//                UserManager.shared.isAnonymous = false
                FirebaseManager.shared.ref.child("users").child(uid).child("image").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let userImage = snapshot.value as? String {
                        UserManager.shared.userImage = userImage
                    }
                })
                self.toMainPage()
            }
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}
