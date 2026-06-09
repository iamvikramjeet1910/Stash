
//
//  HomeViewController.swift
//  Stash
//
//  Created by Vikram Kumar on 09/06/26.
//

import UIKit

final class HomeViewController: UIViewController {

    private let headerView = HeaderView()

    private let dataSource: DataSource

    private lazy var collectionView: UICollectionView = {

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12

        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )

        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(
            CardViewCell.self,
            forCellWithReuseIdentifier: CardViewCell.identifier
        )

        return collectionView
    }()

    // MARK: - Init

    init(dataSource: DataSource) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupConstraints()
    }
}

// MARK: - Setup

private extension HomeViewController {

    func setupViews() {

        view.backgroundColor = .systemBackground

        view.addSubview(collectionView)
    }

    func setupConstraints() {

        NSLayoutConstraint.activate([

            collectionView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 16
            ),

            collectionView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),

            collectionView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),

            collectionView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ])
    }
}

// MARK: - UICollectionViewDataSource

extension HomeViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {

        dataSource.items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CardViewCell.identifier,
            for: indexPath
        ) as? CardViewCell else {
            return UICollectionViewCell()
        }

        let item = dataSource.items[indexPath.item]

        cell.configure(with: item)

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HomeViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let spacing: CGFloat = 12

        let totalSpacing = spacing * 2

        let width = (
            collectionView.bounds.width - totalSpacing
        ) / 3

        return CGSize(
            width: width,
            height: 260
        )
    }
}

// MARK: - Protocols

extension HomeViewController {

    protocol DataSource: AnyObject {

        var items: [SharedDataObject] { get }
    }

    protocol Delegate: AnyObject {

    }
}

final class CardViewCell: UICollectionViewCell {

    static let identifier = "GridCell"

    private let customImageView = CustomImageView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 2
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 3
        return label
    }()

    private lazy var stackView: UIStackView = {

        let stack = UIStackView(
            arrangedSubviews: [
                customImageView,
                titleLabel,
                descriptionLabel
            ]
        )

        stack.axis = .vertical
        stack.spacing = 8

        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: SharedDataObject) {

        customImageView.imageView.image = item.image

        customImageView.configureTag(
            icon: item.video,
            text: "Video"
        )

        titleLabel.text = item.title
        descriptionLabel.text = item.subtitle
    }
}

// MARK: - Setup
private extension CardViewCell {

    func setupViews() {

        contentView.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupConstraints() {

        NSLayoutConstraint.activate([

            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            customImageView.heightAnchor.constraint(equalToConstant: 180)
        ])
    }
}

final class CustomImageView: UIView {

    let imageView = UIImageView()

    private let tagView = UIView()
    private let tagIconView = UIImageView()
    private let tagLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureTag(
        icon: UIImage?,
        text: String
    ) {
        tagIconView.image = icon
        tagLabel.text = text
    }
}

// MARK: - Setup
private extension CustomImageView {

    func setupViews() {

        translatesAutoresizingMaskIntoConstraints = false

        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray4.cgColor
        clipsToBounds = true

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        tagView.backgroundColor = .black.withAlphaComponent(0.7)
        tagView.layer.cornerRadius = 12

        tagIconView.tintColor = .white
        tagIconView.contentMode = .scaleAspectFit

        tagLabel.font = .systemFont(ofSize: 12, weight: .medium)
        tagLabel.textColor = .white

        addSubview(imageView)
        addSubview(tagView)

        tagView.addSubview(tagIconView)
        tagView.addSubview(tagLabel)
    }

    func setupConstraints() {

        imageView.translatesAutoresizingMaskIntoConstraints = false
        tagView.translatesAutoresizingMaskIntoConstraints = false
        tagIconView.translatesAutoresizingMaskIntoConstraints = false
        tagLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            tagView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            tagView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),

            tagIconView.leadingAnchor.constraint(equalTo: tagView.leadingAnchor, constant: 8),
            tagIconView.centerYAnchor.constraint(equalTo: tagView.centerYAnchor),
            tagIconView.widthAnchor.constraint(equalToConstant: 14),
            tagIconView.heightAnchor.constraint(equalToConstant: 14),

            tagLabel.leadingAnchor.constraint(equalTo: tagIconView.trailingAnchor, constant: 4),
            tagLabel.trailingAnchor.constraint(equalTo: tagView.trailingAnchor, constant: -8),
            tagLabel.topAnchor.constraint(equalTo: tagView.topAnchor, constant: 6),
            tagLabel.bottomAnchor.constraint(equalTo: tagView.bottomAnchor, constant: -6)
        ])
    }
}
