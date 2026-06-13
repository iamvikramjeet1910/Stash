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

protocol RootViewControllerDataSource: AnyObject {
    func getTabData(index: Int) -> TabObject?
    func getTabs() -> RootDataObject
    func viewDidLoad()
}

final class RootViewController: UIViewController {

    private let dataSource: RootViewControllerDataSource

    private lazy var tabBar = TabBarView(delegate: self)
    private let contentView = UIView()

    // MARK: - Header

    private let appHeaderView = HeaderView()

    // MARK: - Status bar accent strip

    // Fills the status-bar area above the header — must match headerBackground exactly
    private let emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = StashTheme.headerBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Child ViewControllers (one per tab, all StashGridViewController)

    private lazy var homeVC   = StashGridViewController.forTab(.shopping)
    private lazy var mediaVC  = StashGridViewController.forTab(.social)
    private lazy var linksVC  = StashGridViewController.forTab(.weblinks)

    private var currentViewController: UIViewController?

    // MARK: - Init

    init(dataSource: RootViewControllerDataSource) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        view.backgroundColor = StashTheme.appBackground
        super.viewDidLoad()
        createViews()
        dataSource.viewDidLoad()
        setData(dataSource: dataSource)
        switchTo(homeVC)
        wireSearch()
    }

    // MARK: - Layout

    private func createViews() {
        appHeaderView.translatesAutoresizingMaskIntoConstraints = false
        appHeaderView.delegate = self
        contentView.translatesAutoresizingMaskIntoConstraints = false
        tabBar.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(emptyView)
        view.addSubview(appHeaderView)
        view.addSubview(contentView)
        view.addSubview(tabBar)

        NSLayoutConstraint.activate([
            emptyView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

            appHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            appHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            appHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Content fills from header to screen bottom — floating tab bar overlays it
            contentView.topAnchor.constraint(equalTo: appHeaderView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Floating pill tab bar
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            tabBar.heightAnchor.constraint(equalToConstant: 62),
        ])
    }

    private func setData(dataSource: RootViewControllerDataSource) {
        tabBar.configure(with: dataSource.getTabs().tabs)
    }

    // MARK: - Search wiring

    private func wireSearch() {
        appHeaderView.onSearchChanged = { [weak self] query in
            guard let self else { return }
            (self.currentViewController as? StashGridViewController)?.search(query: query)
        }
    }

    // MARK: - Child VC Management

    private func switchTo(_ viewController: UIViewController) {
        if currentViewController === viewController { return }

        // Collapse search when changing tabs
        appHeaderView.collapseSearch()

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
            viewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])

        // Offset content so it scrolls above the floating tab bar (62pt bar + 8pt gap + 8pt buffer)
        viewController.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 78, right: 0)

        viewController.didMove(toParent: self)
        currentViewController = viewController
    }
}

// MARK: - TabBarView.Delegate

extension RootViewController: TabBarView.Delegate {
    func didSelectTab(index: Int, tabId: TabId?) {
        guard let tabId, let tab = TabId(rawValue: tabId.rawValue.lowercased()) else { return }

        switch tab {
        case .shopping:  switchTo(homeVC)
        case .social:    switchTo(mediaVC)
        case .weblinks:  switchTo(linksVC)
        }
    }
}

// MARK: - HeaderViewDelegate

extension RootViewController: HeaderViewDelegate {
    func didTapProfile() {
        let sheet = ProfileBottomSheetViewController()
        let phoneNumber = APIService.shared.loggedInPhoneNumber ?? "Unknown"
        sheet.configure(with: phoneNumber, customImage: nil)

        sheet.onLogoutTapped = { [weak self] in
            guard let self else { return }
            APIService.shared.logout()
            guard let windowScene = self.view.window?.windowScene,
                  let sceneDelegate = windowScene.delegate as? SceneDelegate else { return }
            sceneDelegate.showLoginFlow()
        }

        sheet.modalPresentationStyle = .pageSheet
        if let presenter = sheet.sheetPresentationController {
            presenter.detents = [.medium()]
            presenter.prefersGrabberVisible = true
            presenter.preferredCornerRadius = 24
        }
        present(sheet, animated: true)
    }
}
