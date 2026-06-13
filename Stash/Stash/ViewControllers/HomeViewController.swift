//
//  HomeViewController.swift  →  StashGridViewController
//  Stash
//
//  Created by Vikram Kumar on 09/06/26.
//

import UIKit
import Lottie

// MARK: - StashGridViewController

final class StashGridViewController: UIViewController {

    // MARK: - Tab Config

    struct TabConfig {
        let tabId: TabId
        let emptyTitle: String
        let emptySubtitle: String
    }

    static func forTab(_ tabId: TabId) -> StashGridViewController {
        switch tabId {
        case .shopping:
            return StashGridViewController(config: TabConfig(
                tabId: .shopping,
                emptyTitle: "Your shopping stash is empty",
                emptySubtitle: "Save products from around the web to revisit them later."
            ))
        case .social:
            return StashGridViewController(config: TabConfig(
                tabId: .social,
                emptyTitle: "Nothing social saved yet",
                emptySubtitle: "Share posts and reels here to keep them in one place."
            ))
        case .weblinks:
            return StashGridViewController(config: TabConfig(
                tabId: .weblinks,
                emptyTitle: "No links stashed yet",
                emptySubtitle: "Save links from Safari or any app to find them here."
            ))
        }
    }

    // MARK: - Properties

    private let config: TabConfig
    private lazy var viewModel = StashGridViewModel(tabId: config.tabId)

    // MARK: - Collection View

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = false
        cv.alwaysBounceVertical = true
        cv.contentInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        cv.dataSource = self
        cv.delegate = self
        cv.register(CardViewCell.self, forCellWithReuseIdentifier: CardViewCell.identifier)
        return cv
    }()

    // MARK: - Lottie Loader

    private let loaderView: LottieAnimationView = {
        let av = LottieAnimationView(name: "Loader")
        av.contentMode = .scaleAspectFit
        av.loopMode = .loop
        av.isHidden = true
        av.translatesAutoresizingMaskIntoConstraints = false
        return av
    }()

    // MARK: - Empty State

    private lazy var emptyStateView: EmptyStateView = {
        let v = EmptyStateView(
            title: config.emptyTitle,
            subtitle: config.emptySubtitle
        )
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        return v
    }()

    // MARK: - Init

    init(config: TabConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = StashTheme.appBackground
        setupViews()

        viewModel.onStateChange = { [weak self] state in
            self?.apply(state: state)
        }
        viewModel.viewDidLoad()
    }

    // MARK: - Search

    func search(query: String) {
        viewModel.search(query: query)
    }

    // MARK: - Private

    private func setupViews() {
        view.addSubview(collectionView)
        view.addSubview(loaderView)
        view.addSubview(emptyStateView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loaderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loaderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loaderView.widthAnchor.constraint(equalToConstant: 120),
            loaderView.heightAnchor.constraint(equalToConstant: 120),

            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
        ])
    }

    private func apply(state: StashGridViewModel.ViewState) {
        switch state {
        case .loading:
            collectionView.isHidden = false
            emptyStateView.isHidden = true
            emptyStateView.stopAnimation()
            loaderView.isHidden = false
            loaderView.play()

        case .content:
            loaderView.stop()
            loaderView.isHidden = true
            emptyStateView.isHidden = true
            emptyStateView.stopAnimation()
            collectionView.isHidden = false
            collectionView.reloadData()

        case .empty:
            loaderView.stop()
            loaderView.isHidden = true
            collectionView.isHidden = true
            emptyStateView.isHidden = false
            emptyStateView.startAnimation()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension StashGridViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        viewModel.displayItems.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CardViewCell.identifier, for: indexPath
        ) as? CardViewCell else { return UICollectionViewCell() }
        cell.configure(with: viewModel.displayItems[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension StashGridViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let inset = collectionView.contentInset
        let availableWidth = collectionView.bounds.width - inset.left - inset.right
        let gap: CGFloat = 10 * 2  // 2 gaps between 3 columns
        let cellWidth = floor((availableWidth - gap) / 3)
        let cellHeight = ceil(cellWidth * 1.5)
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

// MARK: - UICollectionViewDelegate

extension StashGridViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let item = viewModel.displayItems[indexPath.item]
        guard let urlString = item.subtitle,
              let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - EmptyStateView

private final class EmptyStateView: UIView {

    private let animationView = LottieAnimationView(name: "EmptyState")
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    init(title: String, subtitle: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        subtitleLabel.text = subtitle
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    func startAnimation() { animationView.play() }
    func stopAnimation() { animationView.stop() }

    private func setup() {
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [animationView, titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.setCustomSpacing(20, after: animationView)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalToConstant: 160),
            animationView.heightAnchor.constraint(equalToConstant: 160),

            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
