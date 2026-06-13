//
//  PhoneLoginViewModel.swift
//  Stash
//
//  Created by Vikram Kumar on 12/06/26.
//

import Foundation

// MARK: - Delegate Protocol
protocol PhoneLoginViewModelDelegate: AnyObject {
    func viewModelDidSendOTP(_ viewModel: PhoneLoginViewModel)
    func viewModelDidFailSendOTP(_ viewModel: PhoneLoginViewModel, error: String)
    func viewModelDidLoginSuccess(_ viewModel: PhoneLoginViewModel)
    func viewModelDidFailLogin(_ viewModel: PhoneLoginViewModel, error: String)
    func viewModelDidUpdateLoadingState(_ viewModel: PhoneLoginViewModel, isLoading: Bool)
}

// MARK: - ViewModel
final class PhoneLoginViewModel {

    // MARK: - Public State
    weak var delegate: PhoneLoginViewModelDelegate?

    private(set) var selectedCountry: Country = Country.all[0]  // Default: India
    private(set) var phoneNumber: String = ""
    private(set) var otpCode: String = ""
    private(set) var isOTPSent: Bool = false
    private(set) var isLoading: Bool = false

    /// Compiles number matching E.164 standard format required by Supabase (e.g., +919876543210)
    var fullPhoneNumber: String {
        "\(selectedCountry.dialCode)\(phoneNumber)"
    }

    // MARK: - Input Handlers
    func selectCountry(_ country: Country) {
        selectedCountry = country
    }

    func updatePhoneNumber(_ number: String) {
        phoneNumber = number.filter { $0.isNumber }
    }

    func updateOTP(_ otp: String) {
        otpCode = otp.filter { $0.isNumber }
    }

    // MARK: - Validation
    func validatePhoneNumber() -> String? {
        if phoneNumber.isEmpty {
            return "Please enter your phone number."
        }
        guard phoneNumber.count >= 7 && phoneNumber.count <= 15 else {
            return "Enter a valid phone number."
        }
        return nil
    }

    func validateOTP() -> String? {
        guard otpCode.count == 6 else {
            return "Please enter the 6-digit OTP."
        }
        return nil
    }

    // MARK: - Core API Intersections

    /// Dispatches the compiled phone entry to the Supabase endpoint
    func sendOTP() {
        if let error = validatePhoneNumber() {
            delegate?.viewModelDidFailSendOTP(self, error: error)
            return
        }

        setLoading(true)

        // CONNECTED: Replaced the simulated timer loop with your native APIService client pipeline
        APIService.shared.sendOTP(to: fullPhoneNumber) { [weak self] success in
            guard let self = self else { return }
            self.setLoading(false)
            
            if success {
                self.isOTPSent = true
                self.delegate?.viewModelDidSendOTP(self)
            } else {
                self.delegate?.viewModelDidFailSendOTP(
                    self,
                    error: "Could not send verification code. Please check your network or entry configuration."
                )
            }
        }
    }

    /// Submits the 6-digit SMS text code for user session verification
    func verifyOTPAndLogin() {
        if let error = validateOTP() {
            delegate?.viewModelDidFailLogin(self, error: error)
            return
        }

        setLoading(true)

        // CONNECTED: Swapped static string check with live Supabase endpoint validation framework
        APIService.shared.verifyOTP(phoneNumber: fullPhoneNumber, tokenCode: otpCode) { [weak self] success in
            guard let self = self else { return }
            self.setLoading(false)
            
            if success {
                self.delegate?.viewModelDidLoginSuccess(self)
            } else {
                self.delegate?.viewModelDidFailLogin(
                    self,
                    error: "The security token entered is incorrect or expired. Please check and try again."
                )
            }
        }
    }

    func resendOTP() {
        otpCode = ""
        isOTPSent = false
        sendOTP()
    }

    // MARK: - Private Helper
    private func setLoading(_ loading: Bool) {
        isLoading = loading
        delegate?.viewModelDidUpdateLoadingState(self, isLoading: loading)
    }
}


// MARK: - Country Model
struct Country {
    let name: String
    let dialCode: String
    let flag: String

    static let all: [Country] = [
        Country(name: "India",          dialCode: "+91",  flag: "🇮🇳"),
        Country(name: "United States",  dialCode: "+1",   flag: "🇺🇸"),
        Country(name: "United Kingdom", dialCode: "+44",  flag: "🇬🇧"),
        Country(name: "UAE",            dialCode: "+971", flag: "🇦🇪"),
        Country(name: "Canada",         dialCode: "+1",   flag: "🇨🇦"),
        Country(name: "Australia",      dialCode: "+61",  flag: "🇦🇺"),
        Country(name: "Germany",        dialCode: "+49",  flag: "🇩🇪"),
        Country(name: "France",         dialCode: "+33",  flag: "🇫🇷"),
        Country(name: "Singapore",      dialCode: "+65",  flag: "🇸🇬"),
        Country(name: "Japan",          dialCode: "+81",  flag: "🇯🇵"),
    ]
}
