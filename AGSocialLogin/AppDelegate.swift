//
//  AppDelegate.swift
//  AGSocialLogin
//
//  Created by Ashvin Gudaliya on 11/23/17.
//  Copyright © 2017 AshvinGudaliya. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import GoogleSignIn
import Firebase
import FirebaseMessaging
import FirebaseInvites
import TwitterKit
import UserNotifications
import UserNotificationsUI
import LinkedinSwift
import Branch

let USER_ID_KEY = "UserIdKey"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let branch: Branch = Branch.getInstance()
    var presentingController: UIViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        FirebaseApp.configure()
        
        AGTwitterLogin.configure()
        
        //firbase notification
        self.registerNotification(application: application)

        branch.initSession(launchOptions: launchOptions, isReferrable: true) { (params, error) in
            
            if error == nil {
                // params are the deep linked params associated with the link that the user clicked -> was re-directed to this app
                print("params: %@", params?.description as Any)
                if let sessionParams = Branch.getInstance().getLatestReferringParams() {
                    
                    print("getLatestReferringParams: %@", sessionParams.description)
                }
                
                if let sessionParams = Branch.getInstance().getFirstReferringParams() {
                    print("getFirstReferringParams: %@", sessionParams.description)
                }
            }
        }
        
        Branch.getInstance().setIdentity("your_user_id")
        
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

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
     
        if FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation){
            return true
        }
        
        if GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation){
            return true
        }
        
        if LISDKCallbackHandler.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation){
            return true
        }
        
        if LinkedinSwiftHelper.shouldHandle(url) {
            return LinkedinSwiftHelper.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        
        if let invitesList = Invites.handle(url, sourceApplication: sourceApplication, annotation: annotation){
            debugPrint(invitesList)
            return true
        }
        
        if Branch.getInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        }
        
        return false
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        return self.application(app, open: url, sourceApplication: options[.sourceApplication] as? String, annotation: options[.annotation] ?? "")
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        Branch.getInstance().continue(userActivity)
        
        return true
    }

    func showAlertView(withInvite invite: ReceivedInvite) {
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        let matchType = invite.matchType == .weak ? "weak" : "strong"
        let message = "Invite ID: \(invite.inviteId)\nDeep-link: \(invite.deepLink)\nMatch Type: \(matchType)"
        let alertController = UIAlertController(title: "Invite", message: message, preferredStyle: .alert)
        alertController.addAction(okAction)
        self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
}

extension AppDelegate: MessagingDelegate, UNUserNotificationCenterDelegate{
    
    func applicationReceivedRemoteMessage(_ remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage)
    }
    
    func registerNotification(application: UIApplication){
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        InstanceID.instanceID().instanceID(handler: { (result, error) in
            if let r = result {
                print("FCM token: \(r.token)")
            }
        })
        
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        NotificationCenter.default.post(name: NSNotification.Name.init("refreshCheckInAndCheckOutData"), object: nil, userInfo: nil)
        print(userInfo)
        Branch.getInstance().handlePushNotification(userInfo)
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        NotificationCenter.default.post(name: NSNotification.Name.init("refreshCheckInAndCheckOutData"), object: nil, userInfo: nil)
        print(response.notification.request.content.userInfo)
    }
}
