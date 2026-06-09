//
//  RootViewModel.swift
//  Stash
//
//  Created by Vikram Kumar on 08/06/26.
//

import UIKit

final class RootViewModel: RootViewControllerDataSource {
    
    private var tabs : [TabObject] = RootDataObject.mockData().tabs
    
    func getTabData(index: Int) -> TabObject? {
        guard tabs.count > index else { return nil}
        return tabs[index]
    }
    
    func getTabs() -> RootDataObject {
        RootDataObject.mockData()
    }
}
