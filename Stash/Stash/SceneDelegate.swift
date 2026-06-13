//
//  SceneDelegate.swift
//  Stash
//
//  Created by Vikram Kumar on 08/06/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var sessionTimer: Timer?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        if APIService.shared.isLoggedIn {
            if APIService.shared.isSessionExpired {
                APIService.shared.logout()
                showLoginFlow()
            } else {
                showMainFlow()
            }
        } else {
            showLoginFlow()
        }

        window.makeKeyAndVisible()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        if APIService.shared.isLoggedIn && APIService.shared.isSessionExpired {
            performLogout()
        }
    }

    // MARK: - Flow Switchers

    func showMainFlow() {
        let viewModel = RootViewModel()
        let rootVC = RootViewController(dataSource: viewModel)
        setRootViewController(rootVC)
        startSessionTimer()
        NotificationCenter.default.addObserver(self,
            selector: #selector(handleForceLogout),
            name: NSNotification.Name("ForceLogoutNotification"),
            object: nil)
    }

    func showLoginFlow() {
        sessionTimer?.invalidate()
        sessionTimer = nil
        NotificationCenter.default.removeObserver(self,
            name: NSNotification.Name("ForceLogoutNotification"),
            object: nil)
        let loginVC = PhoneLoginViewController()
        let navigationWrapper = UINavigationController(rootViewController: loginVC)
        setRootViewController(navigationWrapper)
    }

    // MARK: - Session Timer

    private func startSessionTimer() {
        sessionTimer?.invalidate()
        let sessionDuration: TimeInterval = 55 * 60
        let remaining: TimeInterval
        if let start = UserDefaults(suiteName: "group.Vikram.Stash.Stash")?.double(forKey: "supabase_session_start_time"),
           start > 0 {
            remaining = max(1, sessionDuration - (Date().timeIntervalSince1970 - start))
        } else {
            remaining = sessionDuration
        }
        sessionTimer = Timer.scheduledTimer(withTimeInterval: remaining, repeats: false) { [weak self] _ in
            self?.performLogout()
        }
    }

    private func performLogout() {
        sessionTimer?.invalidate()
        sessionTimer = nil
        APIService.shared.logout()
        showLoginFlow()
    }

    @objc private func handleForceLogout() {
        performLogout()
    }

    // MARK: - Helpers

    private func setRootViewController(_ viewController: UIViewController) {
        guard let window = window else { return }
        window.rootViewController = viewController
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
}
