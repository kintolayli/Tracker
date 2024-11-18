//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Ilya Lotnik on 02.08.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        let tabBarController = TabBarController()
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        let onboardingViewController = OnboardingViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        onboardingViewController.modalPresentationStyle = .fullScreen
        tabBarController.present(onboardingViewController, animated: true, completion: nil)
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
        delegate.saveContext()
    }
}

