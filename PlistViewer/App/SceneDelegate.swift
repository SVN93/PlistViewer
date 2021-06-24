//
//  SceneDelegate.swift
//  PlistViewer
//
//  Created by Vladislav.S on 19.06.2021.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	private let flowCoordinator = FlowCoordinator(
		listViewBuilder: ListViewBuilder(),
		detailViewBuilder: DetailViewBuilder(),
		navigationControllerBuilder: UINavigationController.init(rootViewController:)
	)
	var window: UIWindow?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		if let windowScene = scene as? UIWindowScene {
		    let window = UIWindow(windowScene: windowScene)
			window.rootViewController = flowCoordinator.start()
		    self.window = window
		    window.makeKeyAndVisible()
		}
	}

}

