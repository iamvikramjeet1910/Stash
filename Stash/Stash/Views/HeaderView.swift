//
//  HeaderView.swift
//  Stash
//
//  Created by Vikram Kumar on 09/06/26.
//

import UIKit

protocol HeaderViewDelegate: AnyObject {
    func didTapProfile()
}

final class HeaderView: UIView {

    weak var delegate: HeaderViewDelegate?

    // MARK: - Subviews

    // 1. Added the logo image view component
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        // Replace with your actual asset name from Assets.xcassets
        iv.image = UIImage(named: "AppLogo")
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let appNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Stash"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let searchButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        button.setImage(UIImage(systemName: "magnifyingglass", withConfiguration: config), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let profileButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        button.setImage(UIImage(systemName: "person.circle.fill", withConfiguration: config), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let topBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Search Bar

    private let searchBarContainer: UIView = {
        let view = UIView()
        view.backgroundColor = StashTheme.searchBarBackground
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        view.isHidden = true
        return view
    }()

    private let searchTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(
            string: "Search...",
            attributes: [.foregroundColor: UIColor.tertiaryLabel]
        )
        tf.textColor = .label
        tf.font = .systemFont(ofSize: 15)
        tf.returnKeyType = .search
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let searchBarIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        iv.tintColor = .secondaryLabel
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .secondaryLabel
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()

    // MARK: - State

    private var isSearchExpanded = false
    private var searchBarHeightConstraint: NSLayoutConstraint!

    // Fires every time the search text changes; empty string means search was cleared/closed.
    var onSearchChanged: ((String) -> Void)?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    // 1 pt separator pinned to the view's bottom edge
    private let bottomBorder: UIView = {
        let v = UIView()
        v.backgroundColor = StashTheme.headerSeparator
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private func setup() {
        backgroundColor = StashTheme.headerBackground

        addSubview(topBar)
        // 2. Added logoImageView to the hierarchy
        topBar.addSubview(logoImageView)
        topBar.addSubview(appNameLabel)
        topBar.addSubview(searchButton)
        topBar.addSubview(profileButton)

        addSubview(searchBarContainer)
        searchBarContainer.addSubview(searchBarIcon)
        searchBarContainer.addSubview(searchTextField)
        searchBarContainer.addSubview(clearButton)
        addSubview(bottomBorder)

        searchBarHeightConstraint = searchBarContainer.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: topAnchor),
            topBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 52),

            // 3. Setup constraints for logoImageView (positioned on the far left)
            logoImageView.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 16),
            logoImageView.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 28),
            logoImageView.heightAnchor.constraint(equalToConstant: 28),

            // 4. Shifted appNameLabel to trail directly behind logoImageView
            appNameLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 8),
            appNameLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),

            profileButton.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -16),
            profileButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            profileButton.widthAnchor.constraint(equalToConstant: 32),
            profileButton.heightAnchor.constraint(equalToConstant: 32),

            searchButton.trailingAnchor.constraint(equalTo: profileButton.leadingAnchor, constant: -12),
            searchButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            searchButton.widthAnchor.constraint(equalToConstant: 32),
            searchButton.heightAnchor.constraint(equalToConstant: 32),

            // Search bar container
            searchBarContainer.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 0),
            searchBarContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            searchBarContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            searchBarContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            searchBarHeightConstraint,

            searchBarIcon.leadingAnchor.constraint(equalTo: searchBarContainer.leadingAnchor, constant: 10),
            searchBarIcon.centerYAnchor.constraint(equalTo: searchBarContainer.centerYAnchor),
            searchBarIcon.widthAnchor.constraint(equalToConstant: 16),
            searchBarIcon.heightAnchor.constraint(equalToConstant: 16),

            clearButton.trailingAnchor.constraint(equalTo: searchBarContainer.trailingAnchor, constant: -10),
            clearButton.centerYAnchor.constraint(equalTo: searchBarContainer.centerYAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 20),
            clearButton.heightAnchor.constraint(equalToConstant: 20),

            searchTextField.leadingAnchor.constraint(equalTo: searchBarIcon.trailingAnchor, constant: 8),
            searchTextField.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -8),
            searchTextField.centerYAnchor.constraint(equalTo: searchBarContainer.centerYAnchor),

            // Bottom separator — 1 pt, full width, pinned to the very bottom edge
            bottomBorder.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomBorder.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomBorder.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomBorder.heightAnchor.constraint(equalToConstant: 1),
        ])

        searchButton.addTarget(self, action: #selector(toggleSearch), for: .touchUpInside)
        profileButton.addTarget(self, action: #selector(profileTapped), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearSearch), for: .touchUpInside)
        searchTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        searchTextField.delegate = self
    }

    // MARK: - Actions

    @objc private func toggleSearch() {
        isSearchExpanded.toggle()

        if isSearchExpanded {
            searchBarContainer.isHidden = false
            searchBarHeightConstraint.constant = 40
        } else {
            searchBarHeightConstraint.constant = 0
            searchTextField.text = ""
            searchTextField.resignFirstResponder()
            clearButton.isHidden = true
            onSearchChanged?("")
        }

        UIView.animate(withDuration: 0.28, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5) {
            self.searchBarContainer.alpha = self.isSearchExpanded ? 1 : 0
            self.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
        } completion: { _ in
            if !self.isSearchExpanded {
                self.searchBarContainer.isHidden = true
            } else {
                self.searchTextField.becomeFirstResponder()
            }
        }

        // Rotate search icon to indicate active state
        UIView.animate(withDuration: 0.2) {
            self.searchButton.transform = self.isSearchExpanded
                ? CGAffineTransform(rotationAngle: .pi / 8)
                : .identity
        }
    }

    @objc private func profileTapped() {
        delegate?.didTapProfile()
    }

    @objc private func clearSearch() {
        searchTextField.text = ""
        clearButton.isHidden = true
        onSearchChanged?("")
    }

    @objc private func textChanged() {
        let text = searchTextField.text ?? ""
        clearButton.isHidden = text.isEmpty
        onSearchChanged?(text)
    }

    /// Collapses the search bar and clears any query — call this when switching tabs.
    func collapseSearch() {
        guard isSearchExpanded else { return }
        toggleSearch()
    }
}

// MARK: - UITextFieldDelegate

extension HeaderView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
