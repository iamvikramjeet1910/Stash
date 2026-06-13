//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Vikram Kumar on 09/06/26.
//

import UIKit
import Social
import UniformTypeIdentifiers
import LinkPresentation
import ImageIO

class ShareViewController: SLComposeServiceViewController {

    // 1. Unify the active App Group ID across your expansion targets
    private let appGroupId = "group.Vikram.Stash.Stash"

    override func isContentValid() -> Bool {
        return true
    }

    // MANDATORY FIX: Completely disables Apple's heavy automatic preview renderer
    // This blocks low-level CGSFillDRAM64 memory allocation crashes right at launch
    override func loadPreviewView() -> UIView! {
        let dummyView = UIView()
        dummyView.backgroundColor = .clear
        return dummyView
    }

    override func didSelectPost() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = extensionItem.attachments else {
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            return
        }
        
        let urlType = UTType.url.identifier
        let textType = UTType.text.identifier
        let imageType = UTType.image.identifier
        
        let extractionGroup = DispatchGroup()
        let synchronizationQueue = DispatchQueue(label: "com.Vikram.Stash.ShareSyncQueue")
        
        // Context storage placeholders
        var extractedTitle: String? = nil
        var extractedSubtitle: String? = nil
        var extractedImageUrl: String? = nil
        
        for provider in attachments {
            
            // 1. Handle Shared Web Links (Flipkart, Instagram, Safari, etc.)
            if provider.hasItemConformingToTypeIdentifier(urlType) {
                extractionGroup.enter()
                provider.loadItem(forTypeIdentifier: urlType, options: nil) { (item, error) in
                    guard let url = item as? URL else {
                        extractionGroup.leave()
                        return
                    }
                    
                    synchronizationQueue.async {
                        extractedSubtitle = url.absoluteString
                    }
                    
                    let metadataProvider = LPMetadataProvider()
                    metadataProvider.startFetchingMetadata(for: url) { metadata, error in
                        guard let metadata = metadata, error == nil else {
                            extractionGroup.leave()
                            return
                        }
                        
                        synchronizationQueue.async {
                            extractedTitle = metadata.title
                        }
                        
                        if let imageProvider = metadata.imageProvider {
                            // Fetch raw Data to avoid premature, uncompressed UIImage memory inflation
                            imageProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, _ in
                                autoreleasepool {
                                    if let data = data,
                                       let downsampledData = self.downsampleRawDataSecurely(data, maxPixelSize: 300),
                                       let sharedDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: self.appGroupId) {
                                        
                                        let filename = "scraped_\(UUID().uuidString).jpg"
                                        let fileURL = sharedDirectory.appendingPathComponent(filename)
                                        try? downsampledData.write(to: fileURL)
                                        
                                        synchronizationQueue.async {
                                            extractedImageUrl = filename
                                        }
                                    }
                                }
                                extractionGroup.leave()
                            }
                        } else {
                            extractionGroup.leave()
                        }
                    }
                }
            }
            
            // 2. Handle Plain Text Clipboard Snippets
            else if provider.hasItemConformingToTypeIdentifier(textType) {
                extractionGroup.enter()
                provider.loadItem(forTypeIdentifier: textType, options: nil) { (item, error) in
                    if let text = item as? String {
                        synchronizationQueue.async {
                            extractedSubtitle = text
                            if extractedTitle == nil { extractedTitle = text }
                        }
                    }
                    extractionGroup.leave()
                }
            }
            
            // 3. Handle System Photos / Direct Screenshots
            else if provider.hasItemConformingToTypeIdentifier(imageType) {
                extractionGroup.enter()
                provider.loadItem(forTypeIdentifier: imageType, options: nil) { (item, error) in
                    autoreleasepool {
                        var finalImageData: Data? = nil
                        
                        if let fileURL = item as? URL {
                            finalImageData = self.downsample(fileURL: fileURL, maxPixelSize: 800)
                        } else if let image = item as? UIImage {
                            finalImageData = self.convertUIImageSecurely(image, maxPixelSize: 800)
                        }
                        
                        if let finalImageData = finalImageData,
                           let sharedDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: self.appGroupId) {
                            
                            let filename = "shared_\(UUID().uuidString).jpg"
                            let targetURL = sharedDirectory.appendingPathComponent(filename)
                            try? finalImageData.write(to: targetURL)
                            
                            synchronizationQueue.async {
                                extractedImageUrl = filename
                            }
                        }
                    }
                    extractionGroup.leave()
                }
            }
        }
        
        // Execute upload when all thread extraction routines finish
        extractionGroup.notify(queue: .main, execute: { [weak self] in
            guard let self = self else { return }
            
            let finalTitle = extractedTitle ?? ((self.contentText != nil && !self.contentText!.isEmpty) ? self.contentText! : "Shared Link")
            let finalSubtitle = extractedSubtitle ?? "No description available"
            let finalImageUrl = extractedImageUrl ?? ""
            
            let targetTabId = self.classifyURLAndGetTabId(finalSubtitle)
            
            // Fire data payload directly into your Supabase endpoint
            APIService.shared.postData(
                imageUrl: finalImageUrl,
                videoUrl: "",
                title: finalTitle,
                subtitle: finalSubtitle,
                tabId: targetTabId
            ) { [weak self] success in
                guard let self = self else { return }
                
                // ✅ CRITICAL FIX: Always bounce back to the Main Thread to dismiss extensions safely.
                // This prevents the system watchdog from abruptly killing your XPC process connection.
                DispatchQueue.main.async {
                    self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                }
            }
        })
    }

    override func configurationItems() -> [Any]! {
        return []
    }
    
    // MARK: - Classification Routing Engine
    private func classifyURLAndGetTabId(_ urlString: String) -> String {
        guard let url = URL(string: urlString), let host = url.host?.lowercased() else {
            return "weblinks"
        }
        
        let shoppingDomains = ["flipkart.com", "amazon.in", "amazon.com", "myntra.com", "ajio.com", "meesho.com", "tataqliq.com"]
        if shoppingDomains.contains(where: { host.contains($0) }) {
            return "shopping"
        }
        
        let socialDomains = ["instagram.com", "facebook.com", "tiktok.com", "twitter.com", "x.com", "reddit.com", "youtube.com", "youtu.be"]
        if socialDomains.contains(where: { host.contains($0) }) {
            return "social"
        }
        
        return "weblinks"
    }
    
    // MARK: - CoreGraphics & ImageIO Memory Clamping Helpers
    private func downsampleRawDataSecurely(_ imageData: Data, maxPixelSize: CGFloat) -> Data? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions) else { return nil }
        
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ] as CFDictionary
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else { return nil }
        return UIImage(cgImage: downsampledImage).jpegData(compressionQuality: 0.7)
    }
    
    private func downsample(fileURL: URL, maxPixelSize: CGFloat) -> Data? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(fileURL as CFURL, imageSourceOptions) else { return nil }
        
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ] as CFDictionary
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else { return nil }
        return UIImage(cgImage: downsampledImage).jpegData(compressionQuality: 0.7)
    }
    
    private func convertUIImageSecurely(_ image: UIImage, maxPixelSize: CGFloat) -> Data? {
        let size = image.size
        let scale = min(maxPixelSize / size.width, maxPixelSize / size.height, 1.0)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1.0
        format.preferredRange = .standard
        
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        let downsampledImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return downsampledImage.jpegData(compressionQuality: 0.7)
    }
}
