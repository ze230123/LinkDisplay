//
//  AppDelegate.swift
//  Topic
//
//  Created by youzy01 on 2019/11/4.
//  Copyright © 2019 youzy. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

//        let jsonPath = Bundle.main.url(forResource: "Directions.geojson", withExtension: nil)
////            .path(forResource: "Directions", ofType: "geojson") ?? ""
//        let jsonData = try! Data(contentsOf: jsonPath!)
//        let arr = try! JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? NSArray
//
//        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
//        let path = "\(documentDirectory)/profile.plist"
//        print(path)


//        arr?.write(toFile: path, atomically: false)
//        let items = EmojiManager.shared.items
//        print(items)

//        if let plistPath = Bundle.main.url(forResource: "EmojiInfo.plist", withExtension: nil) {
//            do {
//                let data = try Data(contentsOf: plistPath)
//                let decoder = try PropertyListDecoder().decode([Emoji].self, from: data)
//                print(decoder)
//            } catch {
//                print(error)
//            }
//        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

