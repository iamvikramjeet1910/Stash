//
//  RootDataObject.swift
//  Stash
//
//  Created by Vikram Kumar on 08/06/26.
//

import Foundation
import UIKit

enum TabId: String {
    case home
    case social
    case profile
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

    let result: [SharedDataObject]
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

struct SharedDataObject {

    let image: UIImage
    let video: UIImage
    let title: String
    let subtitle: String
}

extension RootDataObject {

    static func mockData() -> RootDataObject {

        let selectedBgColor = CrystalColor.crystalSilver.color
        let unselectedBgColor = CrystalColor.clear.color

        let selectedTextColor = CrystalColor.crystalBlack.color
        let unselectedTextColor = CrystalColor.crystalWhite.color

        // MARK: - Home Mock Data

        let homeItems: [SharedDataObject] = (1...20).map { index in
            SharedDataObject(
                image: UIImage(systemName: "photo")!,
                video: UIImage(systemName: "play.rectangle.fill")!,
                title: "Home Item \(index)",
                subtitle: "Home Subtitle \(index)"
            )
        }

        // MARK: - Social Mock Data

        let socialItems: [SharedDataObject] = (1...20).map { index in
            SharedDataObject(
                image: UIImage(systemName: "person.2.fill")!,
                video: UIImage(systemName: "video.fill")!,
                title: "Social Item \(index)",
                subtitle: "Social Subtitle \(index)"
            )
        }

        // MARK: - Profile Mock Data

        let profileItems: [SharedDataObject] = (1...20).map { index in
            SharedDataObject(
                image: UIImage(systemName: "person.crop.circle.fill")!,
                video: UIImage(systemName: "play.rectangle.fill")!,
                title: "Profile Item \(index)",
                subtitle: "Profile Subtitle \(index)"
            )
        }

        let tabs: [TabObject] = [

            TabObject(
                tabId: .home,
                icon: UIImage(systemName: "house.fill")!,
                title: "Home",
                selectedBgColor: selectedBgColor,
                unselectedBgColor: unselectedBgColor,
                selectedTextColor: selectedTextColor,
                unselectedTextColor: unselectedTextColor,
                header: HeaderObject(
                    title: "Home",
                    leftImage: UIImage(systemName: "house.fill")!,
                    rightImage: UIImage(systemName: "bell.fill")!
                ),
                result: homeItems
            ),

            TabObject(
                tabId: .social,
                icon: UIImage(systemName: "message.fill")!,
                title: "Social",
                selectedBgColor: selectedBgColor,
                unselectedBgColor: unselectedBgColor,
                selectedTextColor: selectedTextColor,
                unselectedTextColor: unselectedTextColor,
                header: HeaderObject(
                    title: "Social",
                    leftImage: UIImage(systemName: "message.fill")!,
                    rightImage: UIImage(systemName: "paperplane.fill")!
                ),
                result: socialItems
            ),

            TabObject(
                tabId: .profile,
                icon: UIImage(systemName: "person.fill")!,
                title: "Profile",
                selectedBgColor: selectedBgColor,
                unselectedBgColor: unselectedBgColor,
                selectedTextColor: selectedTextColor,
                unselectedTextColor: unselectedTextColor,
                header: HeaderObject(
                    title: "Profile",
                    leftImage: UIImage(systemName: "person.fill")!,
                    rightImage: UIImage(systemName: "gearshape.fill")!
                ),
                result: profileItems
            )
        ]

        return RootDataObject(
            tabs: tabs,
            tabBgColor: CrystalColor.obsidianBlack.color
        )
    }
}
