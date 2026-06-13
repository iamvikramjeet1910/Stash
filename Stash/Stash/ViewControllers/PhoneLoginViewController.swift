//
//  PhoneLoginViewController.swift
//  Stash
//
//  Created by Vikram Kumar on 12/06/26.
//

import UIKit
import Lottie

final class PhoneLoginViewController: UIViewController {

    // MARK: - ViewModel

    private let viewModel = PhoneLoginViewModel()

    // MARK: - UI Components

    // Scroll
    private let scrollView = UIScrollView()
    private let contentStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 0
        sv.alignment = .fill
        return sv
    }()

    // Lottie
    private let animationView: LottieAnimationView = {
        let av = LottieAnimationView(name: "phone_login")
        av.contentMode = .scaleAspectFit
        av.loopMode = .loop
        av.animationSpeed = 1.0
        av.translatesAutoresizingMaskIntoConstraints = false
        return av
    }()

    // Header info
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Welcome Back"
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.textColor = UIColor(named: "PrimaryText") ?? .label
        l.textAlignment = .center
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Enter your phone number to receive\na one-time password."
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.textColor = UIColor(named: "SecondaryText") ?? .secondaryLabel
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    // Phone input row
    private let phoneInputCard: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(named: "InputBackground") ?? .secondarySystemBackground
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.separator.cgColor
        v.clipsToBounds = true
        return v
    }()

    private lazy var countryButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "\(viewModel.selectedCountry.flag) \(viewModel.selectedCountry.dialCode)"
        config.baseForegroundColor = UIColor(named: "PrimaryText") ?? .label
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 8)
        let btn = UIButton(configuration: config)
        btn.addTarget(self, action: #selector(didTapCountry), for: .touchUpInside)
        return btn
    }()

    private let divider: UIView = {
        let v = UIView()
        v.backgroundColor = .separator
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let phoneTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Phone number"
        tf.keyboardType = .phonePad
        tf.font = .systemFont(ofSize: 17)
        tf.textColor = UIColor(named: "PrimaryText") ?? .label
        tf.clearButtonMode = .whileEditing
        return tf
    }()

    // Send OTP button
    private let sendOTPButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Send OTP"
        config.cornerStyle = .large
        config.baseBackgroundColor = UIColor(named: "AccentColor") ?? .systemIndigo
        config.baseForegroundColor = .white
        config.titleTextAttributesTransformer =
            UIConfigurationTextAttributesTransformer { attrs in
                var a = attrs
                a.font = .systemFont(ofSize: 17, weight: .semibold)
                return a
            }
        return UIButton(configuration: config)
    }()

    // OTP section (hidden initially)
    private let otpContainerView: UIView = {
        let v = UIView()
        v.alpha = 0
        v.isHidden = true
        return v
    }()

    private let otpLabel: UILabel = {
        let l = UILabel()
        l.text = "Enter OTP"
        l.font = .systemFont(ofSize: 17, weight: .semibold)
        l.textColor = UIColor(named: "PrimaryText") ?? .label
        return l
    }()

    private let otpHintLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        return l
    }()

    private let otpTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "• • • • • •"
        tf.keyboardType = .numberPad
        tf.font = .monospacedSystemFont(ofSize: 28, weight: .bold)
        tf.textAlignment = .center
        tf.textColor = UIColor(named: "PrimaryText") ?? .label
        tf.backgroundColor = UIColor(named: "InputBackground") ?? .secondarySystemBackground
        tf.layer.cornerRadius = 16
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.separator.cgColor
        tf.clipsToBounds = true
        return tf
    }()

    private let resendButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Resend OTP"
        config.baseForegroundColor = UIColor(named: "AccentColor") ?? .systemIndigo
        config.titleTextAttributesTransformer =
            UIConfigurationTextAttributesTransformer { attrs in
                var a = attrs
                a.font = .systemFont(ofSize: 14, weight: .medium)
                return a
            }
        return UIButton(configuration: config)
    }()

    private let loginButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Login"
        config.cornerStyle = .large
        config.baseBackgroundColor = UIColor(named: "AccentColor") ?? .systemIndigo
        config.baseForegroundColor = .white
        config.titleTextAttributesTransformer =
            UIConfigurationTextAttributesTransformer { attrs in
                var a = attrs
                a.font = .systemFont(ofSize: 17, weight: .semibold)
                return a
            }
        let btn = UIButton(configuration: config)
        return btn
    }()

    // Activity indicator
    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.hidesWhenStopped = true
        ai.color = .white
        return ai
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDelegatesAndTargets()
        viewModel.delegate = self
        animationView.play()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardObservers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = UIColor(named: "Background") ?? .systemBackground
        navigationController?.navigationBar.isHidden = true

        // ScrollView
        scrollView.keyboardDismissMode = .interactive
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -24),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -40),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -48),
        ])

        // --- Lottie ---
        let animationContainer = UIView()
        animationContainer.translatesAutoresizingMaskIntoConstraints = false
        animationContainer.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: animationContainer.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: animationContainer.bottomAnchor),
            animationView.centerXAnchor.constraint(equalTo: animationContainer.centerXAnchor),
            animationView.widthAnchor.constraint(equalTo: animationContainer.widthAnchor, multiplier: 0.65),
            animationView.heightAnchor.constraint(equalToConstant: 200),
        ])
        contentStack.addArrangedSubview(animationContainer)
        contentStack.setCustomSpacing(8, after: animationContainer)

        // --- Header info ---
        contentStack.addArrangedSubview(titleLabel)
        contentStack.setCustomSpacing(8, after: titleLabel)
        contentStack.addArrangedSubview(subtitleLabel)
        contentStack.setCustomSpacing(32, after: subtitleLabel)

        // --- Phone input card ---
        buildPhoneInputCard()
        contentStack.addArrangedSubview(phoneInputCard)
        phoneInputCard.heightAnchor.constraint(equalToConstant: 56).isActive = true
        contentStack.setCustomSpacing(20, after: phoneInputCard)

        // --- Send OTP button ---
        sendOTPButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        contentStack.addArrangedSubview(sendOTPButton)
        contentStack.setCustomSpacing(32, after: sendOTPButton)

        // --- OTP Section ---
        buildOTPSection()
        contentStack.addArrangedSubview(otpContainerView)
    }

    private func buildPhoneInputCard() {
        countryButton.translatesAutoresizingMaskIntoConstraints = false
        divider.translatesAutoresizingMaskIntoConstraints = false
        phoneTextField.translatesAutoresizingMaskIntoConstraints = false

        phoneInputCard.addSubview(countryButton)
        phoneInputCard.addSubview(divider)
        phoneInputCard.addSubview(phoneTextField)

        NSLayoutConstraint.activate([
            // Country button — left side
            countryButton.leadingAnchor.constraint(equalTo: phoneInputCard.leadingAnchor),
            countryButton.topAnchor.constraint(equalTo: phoneInputCard.topAnchor),
            countryButton.bottomAnchor.constraint(equalTo: phoneInputCard.bottomAnchor),
            countryButton.widthAnchor.constraint(equalToConstant: 100),

            // Divider
            divider.leadingAnchor.constraint(equalTo: countryButton.trailingAnchor),
            divider.centerYAnchor.constraint(equalTo: phoneInputCard.centerYAnchor),
            divider.widthAnchor.constraint(equalToConstant: 1),
            divider.heightAnchor.constraint(equalToConstant: 28),

            // Phone text field — fills rest
            phoneTextField.leadingAnchor.constraint(equalTo: divider.trailingAnchor, constant: 12),
            phoneTextField.trailingAnchor.constraint(equalTo: phoneInputCard.trailingAnchor, constant: -12),
            phoneTextField.topAnchor.constraint(equalTo: phoneInputCard.topAnchor),
            phoneTextField.bottomAnchor.constraint(equalTo: phoneInputCard.bottomAnchor),
        ])
    }

    private func buildOTPSection() {
        // Internal vertical stack inside the OTP container
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false

        otpContainerView.translatesAutoresizingMaskIntoConstraints = false
        otpContainerView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: otpContainerView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: otpContainerView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: otpContainerView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: otpContainerView.bottomAnchor),
        ])

        stack.addArrangedSubview(otpLabel)
        stack.setCustomSpacing(4, after: otpLabel)
        stack.addArrangedSubview(otpHintLabel)
        stack.setCustomSpacing(16, after: otpHintLabel)

        // OTP text field with padding
        let otpFieldWrapper = UIView()
        otpFieldWrapper.translatesAutoresizingMaskIntoConstraints = false
        otpTextField.translatesAutoresizingMaskIntoConstraints = false
        otpFieldWrapper.addSubview(otpTextField)
        NSLayoutConstraint.activate([
            otpTextField.topAnchor.constraint(equalTo: otpFieldWrapper.topAnchor, constant: 8),
            otpTextField.bottomAnchor.constraint(equalTo: otpFieldWrapper.bottomAnchor, constant: -8),
            otpTextField.centerXAnchor.constraint(equalTo: otpFieldWrapper.centerXAnchor),
            otpTextField.widthAnchor.constraint(equalTo: otpFieldWrapper.widthAnchor, multiplier: 0.7),
            otpTextField.heightAnchor.constraint(equalToConstant: 64),
        ])
        stack.addArrangedSubview(otpFieldWrapper)
        stack.setCustomSpacing(8, after: otpFieldWrapper)

        // Resend row
        let resendRow = UIStackView()
        resendRow.axis = .horizontal
        resendRow.alignment = .center
        resendRow.distribution = .equalSpacing
        let resendHint = UILabel()
        resendHint.text = "Didn't receive it?"
        resendHint.font = .systemFont(ofSize: 14)
        resendHint.textColor = .secondaryLabel
        resendRow.addArrangedSubview(resendHint)
        resendRow.addArrangedSubview(resendButton)
        stack.addArrangedSubview(resendRow)
        stack.setCustomSpacing(20, after: resendRow)

        // Login button
        loginButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        stack.addArrangedSubview(loginButton)
    }

    // MARK: - Delegates & Targets

    private func setupDelegatesAndTargets() {
        phoneTextField.delegate = self
        otpTextField.delegate = self

        sendOTPButton.addTarget(self, action: #selector(didTapSendOTP), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        resendButton.addTarget(self, action: #selector(didTapResend), for: .touchUpInside)

        phoneTextField.addTarget(self, action: #selector(phoneTextChanged(_:)), for: .editingChanged)
        otpTextField.addTarget(self, action: #selector(otpTextChanged(_:)), for: .editingChanged)
    }

    // MARK: - Actions

    @objc private func didTapCountry() {
        let picker = CountryPickerViewController(countries: Country.all,
                                                 selected: viewModel.selectedCountry)
        picker.onSelect = { [weak self] country in
            guard let self else { return }
            self.viewModel.selectCountry(country)
            var config = self.countryButton.configuration
            config?.title = "\(country.flag) \(country.dialCode)"
            self.countryButton.configuration = config
        }
        let nav = UINavigationController(rootViewController: picker)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

    @objc private func didTapSendOTP() {
        view.endEditing(true)
        viewModel.sendOTP()
    }

    @objc private func didTapLogin() {
        view.endEditing(true)
        viewModel.verifyOTPAndLogin()
    }

    @objc private func didTapResend() {
        viewModel.resendOTP()
    }

    @objc private func phoneTextChanged(_ tf: UITextField) {
        viewModel.updatePhoneNumber(tf.text ?? "")
    }

    @objc private func otpTextChanged(_ tf: UITextField) {
        let text = tf.text ?? ""
        let capped = String(text.prefix(6))
        if capped != text { tf.text = capped }
        viewModel.updateOTP(capped)
    }

    // MARK: - OTP Section Animation

    private func showOTPSection(animated: Bool) {
        otpContainerView.isHidden = false
        let animate = {
            self.otpContainerView.alpha = 1
        }
        if animated {
            UIView.animate(withDuration: 0.35, delay: 0,
                           usingSpringWithDamping: 0.85,
                           initialSpringVelocity: 0.5,
                           options: .curveEaseOut,
                           animations: animate)
        } else {
            animate()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.otpTextField.becomeFirstResponder()
        }
    }

    private func hideOTPSection() {
        UIView.animate(withDuration: 0.2) {
            self.otpContainerView.alpha = 0
        } completion: { _ in
            self.otpContainerView.isHidden = true
            self.otpTextField.text = nil
        }
    }

    // MARK: - Loading State

    private func setButtonLoading(_ loading: Bool, button: UIButton, originalTitle: String) {
        var config = button.configuration
        if loading {
            config?.title = ""
            config?.showsActivityIndicator = true
        } else {
            config?.title = originalTitle
            config?.showsActivityIndicator = false
        }
        button.configuration = config
        button.isEnabled = !loading
    }

    // MARK: - Keyboard

    private func registerKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self,
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self,
            name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let kbFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let inset = kbFrame.height - view.safeAreaInsets.bottom + 16
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: inset, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }

    // MARK: - Alerts

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - PhoneLoginViewModelDelegate

extension PhoneLoginViewController: PhoneLoginViewModelDelegate {

    func viewModelDidSendOTP(_ viewModel: PhoneLoginViewModel) {
        setButtonLoading(false, button: sendOTPButton, originalTitle: "Send OTP")
        otpHintLabel.text = "OTP sent to \(viewModel.selectedCountry.flag) \(viewModel.fullPhoneNumber)"
        showOTPSection(animated: true)

        // Visual feedback on the send button
        var config = sendOTPButton.configuration
        config?.title = "OTP Sent ✓"
        config?.baseBackgroundColor = .systemGreen
        sendOTPButton.configuration = config

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            guard let self else { return }
            var cfg = self.sendOTPButton.configuration
            cfg?.title = "Resend OTP"
            cfg?.baseBackgroundColor = UIColor(named: "AccentColor") ?? .systemIndigo
            self.sendOTPButton.configuration = cfg
            self.sendOTPButton.isEnabled = true
        }
    }

    func viewModelDidFailSendOTP(_ viewModel: PhoneLoginViewModel, error: String) {
        setButtonLoading(false, button: sendOTPButton, originalTitle: "Send OTP")
        showAlert(title: "Error", message: error)
    }

    func viewModelDidLoginSuccess(_ viewModel: PhoneLoginViewModel) {
        setButtonLoading(false, button: loginButton, originalTitle: "Login")
        
        // Access the SceneDelegate instance connected to this window session
        guard let windowScene = view.window?.windowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else {
            return
        }
        
        // Seamlessly swap the login flow view hierarchy for the dashboard
        sceneDelegate.showMainFlow()
    }

    func viewModelDidFailLogin(_ viewModel: PhoneLoginViewModel, error: String) {
        setButtonLoading(false, button: loginButton, originalTitle: "Login")
        // Shake OTP field
        shakeView(otpTextField)
        showAlert(title: "Invalid OTP", message: error)
    }

    func viewModelDidUpdateLoadingState(_ viewModel: PhoneLoginViewModel, isLoading: Bool) {
        if viewModel.isOTPSent {
            setButtonLoading(isLoading, button: loginButton, originalTitle: "Login")
        } else {
            setButtonLoading(isLoading, button: sendOTPButton, originalTitle: "Send OTP")
        }
    }

    // MARK: - Helper

    private func shakeView(_ view: UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.4
        animation.values = [-12, 12, -10, 10, -6, 6, -3, 3, 0]
        view.layer.add(animation, forKey: "shake")
    }
}

// MARK: - UITextFieldDelegate

extension PhoneLoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == phoneTextField {
            didTapSendOTP()
        }
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if textField == otpTextField {
            let current = textField.text ?? ""
            let updated = (current as NSString).replacingCharacters(in: range, with: string)
            return updated.count <= 6
        }
        return true
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - CountryPickerViewController
// ─────────────────────────────────────────────────────────────

final class CountryPickerViewController: UITableViewController {

    var onSelect: ((Country) -> Void)?

    private let countries: [Country]
    private var selectedCountry: Country
    private var filtered: [Country] = []

    private let searchController = UISearchController(searchResultsController: nil)

    init(countries: [Country], selected: Country) {
        self.countries = countries
        self.selectedCountry = selected
        self.filtered = countries
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Country"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close, target: self, action: #selector(dismiss_))

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search country"
        navigationItem.searchController = searchController
        definesPresentationContext = true

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    @objc private func dismiss_() {
        dismiss(animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filtered.count
    }

    override func tableView(_ tableView: UITableView,
                             cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let country = filtered[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = "\(country.flag)  \(country.name)"
        content.secondaryText = country.dialCode
        cell.contentConfiguration = content
        cell.accessoryType = (country.dialCode == selectedCountry.dialCode &&
                               country.name == selectedCountry.name) ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let country = filtered[indexPath.row]
        onSelect?(country)
        dismiss(animated: true)
    }
}

extension CountryPickerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text?.lowercased() ?? ""
        filtered = query.isEmpty ? countries :
            countries.filter { $0.name.lowercased().contains(query) ||
                               $0.dialCode.contains(query) }
        tableView.reloadData()
    }
}

