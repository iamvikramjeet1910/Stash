//
//  HomeViewModel.swift
//  Stash
//
//  Created by Vikram Kumar on 09/06/26.
//

final class HomeViewModel: HomeViewController.DataSource {

    let items: [SharedDataObject]

    init(items: [SharedDataObject]) {
        self.items = items
    }
}
