//
//  AppDelegate.swift
//  gimme
//
//  Created by Stan Gutev on 10.02.18.
//  Copyright © 2018 lepookey. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var activeUser:User!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        // check user status then set initial Viewcontroller
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard =  UIStoryboard(name: "Main", bundle: nil)
        let startMainVC = storyboard.instantiateViewController(withIdentifier: "MainVC")
        let startIntroVC = storyboard.instantiateViewController(withIdentifier: "LoginVC")
        
        Auth.auth().addStateDidChangeListener({ (auth:Auth, user:User?) in
            if let user = user {
                if(self.activeUser != user){
                    self.activeUser = user
                    print("-> LOGGED IN AS \(String(describing: user.email))")
                    self.window?.rootViewController = startMainVC
                }
            } else {
                print("-> NOT LOGGED IN")
                self.window?.rootViewController = startIntroVC
            }
        })
        
        let user = Auth.auth().currentUser;
        
        if ((user) != nil) {
            print("-> LLOGGED IN AS \(String(describing: user?.email))")
            self.window?.rootViewController = startMainVC
        } else {
           print("-> NOT LLOGGED IN")
            self.window?.rootViewController = startIntroVC
        }
        return true
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

