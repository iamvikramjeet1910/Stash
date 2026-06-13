//
//  APIService.swift
//  Stash
//
//  Created by Vikram Kumar on 11/06/26.
//

import UIKit

final class APIService {
    
    public static let shared = APIService()
    
    // MARK: - Environment Configurations (Safely loaded via Info.plist / Configs)
    private var supabaseURLString: String {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "SupabaseUrl") as? String else {
            fatalError("❌ 'SupabaseUrl' configuration entry missing from Info.plist")
        }
        return url
    }
    
    private var anonKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "SupabaseAnonKey") as? String else {
            fatalError("❌ 'SupabaseAnonKey' configuration entry missing from Info.plist")
        }
        return key
    }
    
    // 1. ⚠️ App Group Suite Identifier (Must match the checkbox checked in Xcode Capabilities exactly)
    private let appGroupId = "group.Vikram.Stash.Stash"
    
    // 2. Shared container instance accessor
    private var sharedDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupId)
    }
    
    private var userAccessToken: String?
    
    // 3. ✅ Dynamic computed property reading from the shared App Group sandbox container on demand
    private var currentUserId: String? {
        return sharedDefaults?.string(forKey: "supabase_user_id")
    }
    
    // Public check to determine authentication status across targets using App Group data
    public var isLoggedIn: Bool {
        return sharedDefaults?.string(forKey: "supabase_user_access_token") != nil
    }

    public var loggedInPhoneNumber: String? {
        return sharedDefaults?.string(forKey: "supabase_user_id")
    }

    public var isSessionExpired: Bool {
        guard let startTime = sharedDefaults?.double(forKey: "supabase_session_start_time"),
              startTime > 0 else { return false }
        return Date().timeIntervalSince1970 - startTime > 55 * 60
    }

    func logout() {
        sharedDefaults?.removeObject(forKey: "supabase_user_access_token")
        sharedDefaults?.removeObject(forKey: "supabase_user_id")
        sharedDefaults?.removeObject(forKey: "supabase_session_start_time")
        userAccessToken = nil
    }
    
    private init() {
        // Hydrate the network layer access token from the shared container suite on initialization
        if let savedToken = sharedDefaults?.string(forKey: "supabase_user_access_token") {
            self.userAccessToken = savedToken
        }
    }
    
    // MARK: - AUTH: Send OTP
    /// Sends a 6-digit verification code to the specified phone number via Supabase GoTrue
    func sendOTP(to phoneNumber: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(supabaseURLString)/auth/v1/otp") else {
            completion(false)
            return
        }
        
        let bodyPayload: [String: String] = ["phone": phoneNumber]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: bodyPayload, options: [])
        } catch {
            print("❌ Failed to serialize OTP payload: \(error.localizedDescription)")
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ OTP Network Error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                print("✅ OTP successfully dispatched to \(phoneNumber)!")
                DispatchQueue.main.async { completion(true) }
            } else {
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("❌ Supabase OTP Error: \(responseString)")
                }
                DispatchQueue.main.async { completion(false) }
            }
        }.resume()
    }
    
    // MARK: - AUTH: Verify OTP
    /// Verifies the 6-digit SMS code and updates local tracking tokens on success
    func verifyOTP(phoneNumber: String, tokenCode: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(supabaseURLString)/auth/v1/verify") else {
            completion(false)
            return
        }
        
        let bodyPayload: [String: String] = [
            "type": "sms",
            "phone": phoneNumber,
            "token": tokenCode
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: bodyPayload, options: [])
        } catch {
            print("❌ Failed to serialize verification payload")
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Verification Network Error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let accessToken = json["access_token"] as? String {
                            self.userAccessToken = accessToken
                            // Save access token securely to the shared App Group suite container
                            self.sharedDefaults?.set(accessToken, forKey: "supabase_user_access_token")
                        }
                        
                        // Save the formatted phone number text string into the shared App Group sandbox container
                        self.sharedDefaults?.set(phoneNumber, forKey: "supabase_user_id")
                        self.sharedDefaults?.set(Date().timeIntervalSince1970, forKey: "supabase_session_start_time")
                        print("👤 Session Verified! App Group stored phone number: \(phoneNumber)")
                    }
                    DispatchQueue.main.async { completion(true) }
                } catch {
                    print("❌ Session serialization error: \(error.localizedDescription)")
                    DispatchQueue.main.async { completion(false) }
                }
            } else {
                let serverErrorMessage = String(data: data, encoding: .utf8) ?? "Unknown Auth Error"
                print("❌ Verification Refused: \(serverErrorMessage)")
                DispatchQueue.main.async { completion(false) }
            }
        }.resume()
    }
    
    // MARK: - GET Request
    func fetchData(tabId: TabId, query: String? = nil, completion: @escaping ([SharedDataObject]) -> Void) {
        guard let userId = currentUserId else {
            print("❌ Fetch canceled: No authenticated user identity string found.")
            completion([])
            return
        }

        guard var components = URLComponents(string: "\(supabaseURLString)/rest/v1/stash_items") else { return }

        // 1. Build query parameters
        var queryItems = [
            URLQueryItem(name: "select", value: "image,video,title,subtitle,user_id,tab_id"),
            URLQueryItem(name: "user_id", value: "eq.\(userId)"),
            URLQueryItem(name: "tab_id", value: "eq.\(tabId.rawValue)"),
            URLQueryItem(name: "order", value: "created_at.desc")
        ]
        if let q = query, !q.isEmpty {
            queryItems.append(URLQueryItem(name: "title", value: "ilike.*\(q)*"))
        }
        
        // 2. ✅ FORCE ENCODING: Converts '+' into '%2B' so the server reads it as a literal plus sign
        components.percentEncodedQueryItems = queryItems.map { item in
            let encodedValue = item.value?
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?
                .replacingOccurrences(of: "+", with: "%2B")
            return URLQueryItem(name: item.name, value: encodedValue)
        }
        
        guard let url = components.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        
        let finalAuthorizationToken = userAccessToken != nil ? "Bearer \(userAccessToken!)" : "Bearer \(anonKey)"
        request.setValue(finalAuthorizationToken, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decodedItems = try JSONDecoder().decode([SharedDataObject].self, from: data)
                print("📦 Successfully decoded \(decodedItems.count) items!")
                DispatchQueue.main.async {
                    completion(decodedItems)
                }
            } catch {
                let serverRawString = String(data: data, encoding: .utf8) ?? "Empty body"
                print("❌ Decoding error: \(error.localizedDescription)")
                print("📄 Server response text: \(serverRawString)")
                
                // ✅ SELF-HEALING ACTION: If the token is expired, wipe the session so the app routes back to login
                if serverRawString.contains("JWT expired") {
                    print("🔄 Expired session detected. Clearing invalid local tracking references...")
                    
                    // Clear out the corrupted tokens from the App Group suite container
                    let appGroupId = "group.Vikram.Stash.Stash"
                    if let defaults = UserDefaults(suiteName: appGroupId) {
                        defaults.removeObject(forKey: "supabase_user_access_token")
                        defaults.removeObject(forKey: "supabase_user_id")
                    }
                    
                    // Optional: Post a local notification to tell your SceneDelegate to swap back to the login screen
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name("ForceLogoutNotification"), object: nil)
                    }
                }
                
                DispatchQueue.main.async { completion([]) }
            }
        }.resume()
    }
    
    // MARK: - POST Request
    func postData(imageUrl: String?, videoUrl: String?, title: String?, subtitle: String?, tabId: String, completion: @escaping (Bool) -> Void) {
        // Safely evaluate computed dynamic property value before assembling model objects
        guard let userId = currentUserId else {
            print("❌ Post canceled: No authenticated user identity string found.")
            completion(false)
            return
        }
        
        guard let url = URL(string: "\(supabaseURLString)/rest/v1/stash_items") else {
            completion(false)
            return
        }
        
        let newItem = SharedDataObject(
            imageUrlString: imageUrl,
            videoName: videoUrl,
            title: title,
            subtitle: subtitle,
            userId: userId, // Pass the clean phone number string data representation
            tabId: tabId
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        
        let finalAuthorizationToken = userAccessToken != nil ? "Bearer \(userAccessToken!)" : "Bearer \(anonKey)"
        request.setValue(finalAuthorizationToken, forHTTPHeaderField: "Authorization")
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        
        do {
            let jsonData = try JSONEncoder().encode(newItem)
            request.httpBody = jsonData
        } catch {
            print("❌ Encoding failed: \(error.localizedDescription)")
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network Error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Supabase Response Status Code: \(httpResponse.statusCode)")
                if !(200...299).contains(httpResponse.statusCode), let data = data {
                    let serverErrorMessage = String(data: data, encoding: .utf8) ?? "Unknown Error Body"
                    print("❌ Supabase Error Message: \(serverErrorMessage)")
                }
            }
            
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                print("✅ Data successfully posted to Supabase!")
                DispatchQueue.main.async { completion(true) }
            } else {
                DispatchQueue.main.async { completion(false) }
            }
        }.resume()
    }
}
