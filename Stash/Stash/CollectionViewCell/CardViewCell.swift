//
//  CardCell.swift
//  Stash
//
//  Created by Vikram Kumar on 12/06/26.
//

import UIKit
import ImageIO

final class CardViewCell: UICollectionViewCell {

    static let identifier = "GridCell"

    // Public property to hold the URL for click-handling in your ViewController
    private(set) var urlString: String?

    // MARK: - Subviews
    private let customImageView = CustomImageView()

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = StashTheme.cardSeparator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCardStyle()
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        contentView.layer.borderColor = StashTheme.cardBorder.cgColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        customImageView.cancelAllLoads()
        urlString = nil
    }

    // MARK: - Configuration
    func configure(with item: SharedDataObject) {
        customImageView.loadImage(from: item.imageUrlString)

        customImageView.configureTag(
            iconURLString: item.videoName,
            text: "Video"
        )

        titleLabel.text = item.title
        
        // Save the subtitle URL string to handle cell selection later
        self.urlString = item.subtitle
    }
}

// MARK: - Cell Setup
private extension CardViewCell {

    func setupCardStyle() {
        contentView.backgroundColor = StashTheme.cardSurface
        contentView.layer.cornerRadius = 16
        contentView.layer.cornerCurve = .continuous
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = StashTheme.cardBorder.cgColor
        contentView.clipsToBounds = true
    }

    func setupViews() {
        customImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(customImageView)
        contentView.addSubview(separatorView)
        contentView.addSubview(titleLabel)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            // Image fills the top portion of the card, height = 62% of total cell height
            customImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            customImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            customImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            customImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.62),

            // Hair-line separator between image and title
            separatorView.topAnchor.constraint(equalTo: customImageView.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),

            // Title: padded, 2 lines max
            titleLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),
        ])
    }
}

// MARK: - CustomImageView
final class CustomImageView: UIView {

    let imageView = UIImageView()

    private let tagView = UIView()
    private let tagIconView = UIImageView()
    private let tagLabel = UILabel()
    
    private var mainImageDownloadTask: URLSessionDataTask?
    private var tagIconDownloadTask: URLSessionDataTask?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureTag(iconURLString: String?, text: String) {
        tagIconDownloadTask?.cancel()
        tagIconDownloadTask = nil
        tagIconView.image = nil
        tagLabel.text = text
        
        guard let iconURLString = iconURLString, let url = URL(string: iconURLString) else {
            tagView.isHidden = true
            return
        }
        
        tagView.isHidden = false
        
        tagIconDownloadTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard error == nil, let data = data,
                  let downsampledIcon = self?.downsample(imageData: data, to: CGSize(width: 24, height: 24)) else {
                DispatchQueue.main.async {
                    self?.tagView.isHidden = true
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.tagIconView.image = downsampledIcon
            }
        }
        tagIconDownloadTask?.resume()
    }
    
    func loadImage(from urlString: String?) {
        mainImageDownloadTask?.cancel()
        mainImageDownloadTask = nil
        imageView.image = nil
        
        guard let urlString = urlString, !urlString.isEmpty else {
            imageView.image = UIImage(systemName: "photo")
            return
        }
        
        if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
            guard let url = URL(string: urlString) else { return }
            
            mainImageDownloadTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard error == nil, let data = data,
                      let downsampledImage = self?.downsample(imageData: data, to: CGSize(width: 150, height: 180)) else { return }
                
                DispatchQueue.main.async { self?.imageView.image = downsampledImage }
            }
            mainImageDownloadTask?.resume()
        }
        else {
            if let sharedDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.Vikram.Stash.Stash") {
                let fileURL = sharedDirectory.appendingPathComponent(urlString)
                if let data = try? Data(contentsOf: fileURL),
                   let downsampledImage = downsample(imageData: data, to: CGSize(width: 150, height: 180)) {
                    imageView.image = downsampledImage
                } else {
                    imageView.image = UIImage(systemName: "photo")
                }
            }
        }
    }
    
    func cancelAllLoads() {
        mainImageDownloadTask?.cancel()
        mainImageDownloadTask = nil
        imageView.image = nil
        
        tagIconDownloadTask?.cancel()
        tagIconDownloadTask = nil
        tagIconView.image = nil
    }
    
    private func downsample(imageData: Data, to pointSize: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions) else { return nil }
        
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else { return nil }
        return UIImage(cgImage: downsampledImage)
    }
}

// MARK: - CustomImageView Setup
private extension CustomImageView {

    func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false

        // REMOVED: Internal corner radius, border lines, and gray backgrounds
        // to blend seamlessly within the master crystal cell container frame boundaries.
        layer.cornerRadius = 0
        layer.borderWidth = 0
        clipsToBounds = true
        backgroundColor = .clear

        imageView.contentMode = .scaleAspectFill // Changed to aspectFill to fill the top-card space correctly
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
