//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Vikram Kumar on 09/06/26.
//

import UIKit
import Social
import UniformTypeIdentifiers

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        // Validation logic: The "Post" button will be enabled only if this returns true.
        // You can check 'contentText' length here if you want to require user typing.
        return true
    }

    override func didSelectPost() {
        // 1. Ensure we have items to unpack
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = extensionItem.attachments else {
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            return
        }
        
        // 2. Define standard type identifiers matching your Info.plist
        let urlType = UTType.url.identifier
        let textType = UTType.text.identifier
        let imageType = UTType.image.identifier
        
        // Setup async tracking and thread safety
        let extractionGroup = DispatchGroup()
        let synchronizationQueue = DispatchQueue(label: "com.Vikram.Stash.ShareSyncQueue")
        var localStashedItems: [[String: String]] = []
        
        // 3. Process every shared item found in the attachment payload
        for provider in attachments {
            
            // Check for Web Links / URLs
            if provider.hasItemConformingToTypeIdentifier(urlType) {
                extractionGroup.enter()
                provider.loadItem(forTypeIdentifier: urlType, options: nil) { (item, error) in
                    if let url = item as? URL {
                        synchronizationQueue.async {
                            localStashedItems.append(["type": "url", "value": url.absoluteString])
                            extractionGroup.leave()
                        }
                    } else {
                        extractionGroup.leave()
                    }
                }
            }
            
            // Check for Text Snippets / Copied Clipboard Text
            else if provider.hasItemConformingToTypeIdentifier(textType) {
                extractionGroup.enter()
                provider.loadItem(forTypeIdentifier: textType, options: nil) { (item, error) in
                    if let text = item as? String {
                        synchronizationQueue.async {
                            localStashedItems.append(["type": "text", "value": text])
                            extractionGroup.leave()
                        }
                    } else {
                        extractionGroup.leave()
                    }
                }
            }
            
            // Check for Images (Supports up to 5 as configured in your plist)
            else if provider.hasItemConformingToTypeIdentifier(imageType) {
                extractionGroup.enter()
                provider.loadItem(forTypeIdentifier: imageType, options: nil) { (item, error) in
                    // System images often load as a URL referencing a local cached file path
                    if let fileURL = item as? URL {
                        synchronizationQueue.async {
                            localStashedItems.append(["type": "image_path", "value": fileURL.path])
                            extractionGroup.leave()
                        }
                    } else if let image = item as? UIImage {
                        // Fallback fallback if the system passes a raw image object instead
                        if let imageData = image.jpegData(compressionQuality: 0.8),
                           let sharedDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.Vikram.Stash.Stash") {
                            
                            let filename = "shared_\(UUID().uuidString).jpg"
                            let fileURL = sharedDirectory.appendingPathComponent(filename)
                            
                            try? imageData.write(to: fileURL)
                            synchronizationQueue.async {
                                localStashedItems.append(["type": "image_path", "value": fileURL.path])
                                extractionGroup.leave()
                            }
                        } else {
                            extractionGroup.leave()
                        }
                    } else {
                        extractionGroup.leave()
                    }
                }
            }
        }
        
        // 4. Once all data elements finish background loading, save them and close out
        extractionGroup.notify(queue: .main) {
            if !localStashedItems.isEmpty {
                self.saveToSharedContainer(items: localStashedItems)
            }
            
            // Inform the host system that the transaction is done so the extension UI collapses smoothly
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        }
    }

    override func configurationItems() -> [Any]! {
        // Used if you ever want to append extra settings cells to the bottom of Apple's standard system sheet
        return []
    }
    
    // MARK: - App Group Persistence
    private func saveToSharedContainer(items: [[String: String]]) {
        if let sharedDefaults = UserDefaults(suiteName: "group.Vikram.Stash.Stash") {
            // Save the compiled array of item dictionaries
            sharedDefaults.set(items, forKey: "pending_stashed_items")
            // Include optional user comment typed in the sheet
            if let userComment = contentText, !userComment.isEmpty {
                sharedDefaults.set(userComment, forKey: "pending_stash_comment")
            }
            sharedDefaults.synchronize()
        }
    }
}
