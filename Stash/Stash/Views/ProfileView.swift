//
//  ProfileView.swift
//  Stash
//
//  Created by Vikram Kumar on 12/06/26.
//
import UIKit

// MARK: - ProfileView Delegate Protocol
protocol ProfileViewDelegate: AnyObject {
    func profileViewDidTapLogout(_ profileView: ProfileView)
}

final class ProfileView: UIView {
    
    // MARK: - Properties
    weak var delegate: ProfileViewDelegate?
    
    // MARK: - UI Components
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Default placeholder fallback
        let config = UIImage.SymbolConfiguration(pointSize: 100, weight: .regular)
        imageView.image = UIImage(systemName: "person.crop.circle.fill", withConfiguration: config)
        imageView.tintColor = .systemGray3
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let phoneNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        var config = UIButton.Configuration.filled()
        config.title = "Log Out"
        config.baseBackgroundColor = .systemRed
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 32, bottom: 12, trailing: 32)
        
        button.configuration = config
        return button
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .systemBackground
        createViews()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Keeps the profile photo perfectly circular if a square custom image is provided
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
    }
    
    // MARK: - Public Configuration Function
    /// Call this function to update the UI with real user data.
    /// - Parameters:
    ///   - phoneNumber: The user's logged-in phone number string.
    ///   - customImage: An optional UIImage. Pass `nil` to keep the default person placeholder.
    func configure(with phoneNumber: String, customImage: UIImage? = nil) {
        phoneNumberLabel.text = phoneNumber
        
        if let image = customImage {
            profileImageView.image = image
            profileImageView.tintColor = .clear // Remove tint for actual user photos
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: 100, weight: .regular)
            profileImageView.image = UIImage(systemName: "person.crop.circle.fill", withConfiguration: config)
            profileImageView.tintColor = .systemGray3
        }
    }
    
    // MARK: - Layout Setup
    private func createViews() {
        let containerStack = UIStackView(arrangedSubviews: [profileImageView, phoneNumberLabel, logoutButton])
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        containerStack.axis = .vertical
        containerStack.alignment = .center
        containerStack.distribution = .fill
        containerStack.spacing = 16
        containerStack.setCustomSpacing(32, after: phoneNumberLabel)
        
        addSubview(containerStack)
        
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            containerStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            containerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40)
        ])
    }
    
    // MARK: - Action Handling
    private func setupActions() {
        // Modern UIAction pattern to forward the tap event to the delegate
        logoutButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.profileViewDidTapLogout(self)
        }, for: .touchUpInside)
    }
}




final class ProfileBottomSheetViewController: UIViewController {
    
    // 1. Instantiate your custom view
    private let profileView = ProfileView()
    
    // Callback closure to notify the RootViewController when logout happens
    var onLogoutTapped: (() -> Void)?
    
    override func loadView() {
        // 2. Replace the controller's default view with your ProfileView
        self.view = profileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 3. Set the view's delegate to this controller
        profileView.delegate = self
    }
    
    // 4. Helper method to pass data into the profile view
    func configure(with phoneNumber: String, customImage: UIImage? = nil) {
        profileView.configure(with: phoneNumber, customImage: customImage)
    }
}

// MARK: - ProfileViewDelegate
extension ProfileBottomSheetViewController: ProfileViewDelegate {
    func profileViewDidTapLogout(_ profileView: ProfileView) {
        // Dismiss the bottom sheet first, then execute logout actions
        dismiss(animated: true) { [weak self] in
            self?.onLogoutTapped?()
        }
    }
}
