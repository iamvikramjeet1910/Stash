//
//  HomeViewModel.swift  →  StashGridViewModel
//  Stash
//
//  Created by Vikram Kumar on 09/06/26.
//

import UIKit

final class StashGridViewModel {

    // MARK: - State

    enum ViewState {
        case loading
        case content
        case empty
    }

    var onStateChange: ((ViewState) -> Void)?

    private(set) var allItems: [SharedDataObject] = []
    private(set) var displayItems: [SharedDataObject] = []

    private let tabId: TabId
    private var debounceWork: DispatchWorkItem?
    private var hasLoaded = false
    private var currentQuery: String?
    private var foregroundObserver: NSObjectProtocol?

    init(tabId: TabId) {
        self.tabId = tabId

        foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self, self.hasLoaded else { return }
            self.fetchItems(query: self.currentQuery)
        }
    }

    deinit {
        if let observer = foregroundObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - Lifecycle

    func viewDidLoad() {
        currentQuery = nil
        fetchItems(query: nil)
    }

    // MARK: - Search (debounced 400 ms, server-side ilike)

    func search(query: String) {
        debounceWork?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespaces)

        if trimmed.isEmpty {
            currentQuery = nil
            guard hasLoaded else { return }
            displayItems = allItems
            onStateChange?(allItems.isEmpty ? .empty : .content)
            return
        }

        currentQuery = trimmed
        let work = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.fetchItems(query: self.currentQuery)
        }
        debounceWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: work)
    }

    // MARK: - Private

    private func fetchItems(query: String?) {
        onStateChange?(.loading)
        APIService.shared.fetchData(tabId: tabId, query: query) { [weak self] items in
            guard let self else { return }
            if query == nil {
                self.allItems = items
                self.hasLoaded = true
            }
            self.displayItems = items
            self.onStateChange?(items.isEmpty ? .empty : .content)
        }
    }
}
