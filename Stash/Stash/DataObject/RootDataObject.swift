//
//  RootDataObject.swift
//  Stash
//
//  Created by Vikram Kumar on 08/06/26.
//

import Foundation
import UIKit

enum TabId: String {
    case shopping
    case social
    case weblinks
}

public struct RootDataObject {

    let tabs: [TabObject]
    let tabBgColor: UIColor

    init(
        tabs: [TabObject],
        tabBgColor: UIColor
    ) {
        self.tabs = tabs
        self.tabBgColor = tabBgColor
    }
}

public struct TabObject {

    let tabId: TabId?
    let icon: UIImage
    let title: String

    let selectedBgColor: UIColor
    let unselectedBgColor: UIColor

    let selectedTextColor: UIColor
    let unselectedTextColor: UIColor

    var result: [SharedDataObject]
    let header: HeaderObject

    init(
        tabId: TabId?,
        icon: UIImage,
        title: String,
        selectedBgColor: UIColor,
        unselectedBgColor: UIColor,
        selectedTextColor: UIColor,
        unselectedTextColor: UIColor,
        header: HeaderObject,
        result: [SharedDataObject]
    ) {
        self.tabId = tabId
        self.icon = icon
        self.title = title
        self.selectedBgColor = selectedBgColor
        self.unselectedBgColor = unselectedBgColor
        self.selectedTextColor = selectedTextColor
        self.unselectedTextColor = unselectedTextColor
        self.header = header
        self.result = result
    }
}

struct HeaderObject {

    let title: String
    let leftImage: UIImage
    let rightImage: UIImage

    init(
        title: String,
        leftImage: UIImage,
        rightImage: UIImage
    ) {
        self.title = title
        self.leftImage = leftImage
        self.rightImage = rightImage
    }
}

struct SharedDataObject: Codable {
    let imageUrlString: String?
    let videoName: String?
    let title: String?
    let subtitle: String?
    let userId: String?
    let tabId: String?

    enum CodingKeys: String, CodingKey {
        case imageUrlString = "image"    // Maps to 'image' column in Supabase
        case videoName = "video"         // Maps to 'video' column in Supabase
        case title
        case subtitle
        case userId = "user_id"          // Maps to 'user_id' column in Supabase
        case tabId = "tab_id"            // Maps to 'tab_id' column in Supabase
    }
}

extension RootDataObject {

    static func mockData() -> RootDataObject {

        let selectedBgColor    = StashTheme.tabSelectedBg
        let unselectedBgColor  = CrystalColor.clear.color
        let selectedTextColor  = StashTheme.tabSelectedFg
        let unselectedTextColor = StashTheme.tabUnselectedFg

        let tabs: [TabObject] = [

            TabObject(
                tabId: .shopping,
                icon: UIImage(systemName: "bag.fill")!,
                title: "Shopping",
                selectedBgColor: selectedBgColor,
                unselectedBgColor: unselectedBgColor,
                selectedTextColor: selectedTextColor,
                unselectedTextColor: unselectedTextColor,
                header: HeaderObject(
                    title: "Home",
                    leftImage: UIImage(systemName: "house.fill")!,
                    rightImage: UIImage(systemName: "bell.fill")!
                ),
                result: []
            ),

            TabObject(
                tabId: .social,
                icon: UIImage(systemName: "play.rectangle.fill")!,
                title: "Social Media",
                selectedBgColor: selectedBgColor,
                unselectedBgColor: unselectedBgColor,
                selectedTextColor: selectedTextColor,
                unselectedTextColor: unselectedTextColor,
                header: HeaderObject(
                    title: "Social",
                    leftImage: UIImage(systemName: "message.fill")!,
                    rightImage: UIImage(systemName: "paperplane.fill")!
                ),
                result: []
            ),

            TabObject(
                tabId: .weblinks,
                icon: UIImage(systemName: "link.circle.fill")!,
                title: "Links",
                selectedBgColor: selectedBgColor,
                unselectedBgColor: unselectedBgColor,
                selectedTextColor: selectedTextColor,
                unselectedTextColor: unselectedTextColor,
                header: HeaderObject(
                    title: "Profile",
                    leftImage: UIImage(systemName: "person.fill")!,
                    rightImage: UIImage(systemName: "gearshape.fill")!
                ),
                result: []
            )
        ]

        return RootDataObject(
            tabs: tabs,
            tabBgColor: CrystalColor.obsidianBlack.color
        )
    }
}
