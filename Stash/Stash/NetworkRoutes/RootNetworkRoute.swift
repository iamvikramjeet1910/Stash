//
//  RootNetworkRoute.swift
//  Stash
//
//  Created by Vikram Kumar on 10/06/26.
//

import Foundation
import Supabase

final class SupabaseManager {
    static let shared = SupabaseManager()
    
    private init() { }
    
    let client = SupabaseClient(
        supabaseURL: URL(string: "https://your-project-id.supabase.co")!,
        supabaseKey: "YOUR_PUBLIC_ANON_KEY"
    )
}
