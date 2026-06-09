//
//  RootViewController.swift
//  Stash
//
//  Created by Vikram Kumar on 08/06/26.
//

import UIKit

public protocol RootViewControllerDelegate: AnyObject {
    func didSelectTab(index: String, tabId: String?)
}

public protocol RootViewControllerDataSource: AnyObject {
    func getTabData(index: Int) -> TabObject?
    func getTabs() -> RootDataObject
}

final class RootViewController: UIViewController {
    
    private let dataSource: RootViewControllerDataSource
    
    // Because lazy properties are initialized after self exists.
    private lazy var tabBar = TabBarView(delegate: self)
    
    private let contentView = UIView()
    
    // ViewControllers
    private lazy var homeVC: HomeViewController = {

        let homeItems = dataSource
            .getTabData(index: 0)?
            .result ?? []

        let vm = HomeViewModel(items: homeItems)

        return HomeViewController(dataSource: vm)

    }()

    private lazy var mediaVC: MediaViewController = {
        MediaViewController(dataSource: MediaViewModel())
    }()

    private lazy var profileVC: ProfileViewController = {
        ProfileViewController(dataSource: ProfileViewModel())
    }()
    
    private var currentViewController: UIViewController?
    
    init(dataSource: RootViewControllerDataSource){
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        super.viewDidLoad()
        createViews()
        setData(dataSource: dataSource)
        switchTo(homeVC)
    }
    
    private func createViews() {
        view.addSubview(contentView)
        view.addSubview(tabBar)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tabBar.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func setData(dataSource: RootViewControllerDataSource) {
        tabBar.configure(with: dataSource.getTabs().tabs)
    }
    
    // MARK: - Child VC Management
    private func switchTo(_ viewController: UIViewController) {

        if currentViewController === viewController {
            return
        }

        if let currentViewController {

            currentViewController.willMove(toParent: nil)
            currentViewController.view.removeFromSuperview()
            currentViewController.removeFromParent()
        }

        addChild(viewController)

        contentView.addSubview(viewController.view)

        viewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        viewController.didMove(toParent: self)

        currentViewController = viewController
    }
}

extension RootViewController: TabBarView.Delegate {

    func didSelectTab(index: Int, tabId: TabId?) {

        guard
            let tabId,
            let tab = TabId(rawValue: tabId.rawValue.lowercased())
        else {
            return
        }

        switch tab {

        case .home:
            switchTo(homeVC)

        case .social:
            switchTo(mediaVC)

        case .profile:
            switchTo(profileVC)
        }
    }
}
