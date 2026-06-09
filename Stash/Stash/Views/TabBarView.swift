//
//  TabBarView.swift
//  Stash
//
//  Created by Vikram Kumar on 09/06/26.
//

import UIKit

final class TabBarView: UIView {
    
    protocol Delegate: AnyObject {
        func didSelectTab(index: Int, tabId: TabId?)
    }
    
    private weak var delegate: Delegate?

    private let mainStackView = UIStackView()

    private var tabs: [TabObject] = []
    private var tabViews: [TabItemView] = []

    private var selectedIndex: Int = 0
    
    init(delegate: Delegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {

        addSubview(mainStackView)

        mainStackView.axis = .horizontal
        mainStackView.distribution = .fillEqually
        mainStackView.spacing = 16

        mainStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        mainStackView.backgroundColor = .black
        
        mainStackView.layer.cornerRadius = 12
    }

    func configure(with tabs: [TabObject]) {

        self.tabs = tabs

        mainStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }

        tabViews.removeAll()

        for (index, tab) in tabs.enumerated() {

            let tabView = TabItemView()

            tabView.configure(
                with: tab,
                isSelected: index == 0
            )

            tabView.tag = index

            let tap = UITapGestureRecognizer(
                target: self,
                action: #selector(tabTapped(_:))
            )

            tabView.addGestureRecognizer(tap)

            tabViews.append(tabView)
            mainStackView.addArrangedSubview(tabView)
            
        }
    }

    @objc
    private func tabTapped(_ gesture: UITapGestureRecognizer) {

        guard let view = gesture.view else { return }

        selectTab(at: view.tag)

        delegate?.didSelectTab(index: view.tag, tabId: tabs[view.tag].tabId)
    }

    func selectTab(at index: Int) {

        selectedIndex = index

        for (idx, tabView) in tabViews.enumerated() {

            tabView.updateSelectionState(
                isSelected: idx == index
            )
        }
    }
}

final class TabItemView: UIView {

    private let iconView = UIImageView()
    private let titleLabel = UILabel()

    private var tab: TabObject?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setupUI() {

        let stack = UIStackView(
            arrangedSubviews: [
                iconView,
                titleLabel
            ]
        )

        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4

        addSubview(stack)

        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        layer.cornerRadius = 24

        titleLabel.font = .systemFont(
            ofSize: 12,
            weight: .medium
        )

        iconView.contentMode = .scaleAspectFit
    }

    func configure(
        with tab: TabObject,
        isSelected: Bool
    ) {

        self.tab = tab

        iconView.image = tab.icon
        titleLabel.text = tab.title

        updateSelectionState(
            isSelected: isSelected
        )
    }

    func updateSelectionState(
        isSelected: Bool
    ) {

        guard let tab else { return }

        backgroundColor = isSelected
        ? tab.selectedBgColor
        : tab.unselectedBgColor

        titleLabel.textColor = isSelected
        ? tab.selectedTextColor
        : tab.unselectedTextColor

        iconView.tintColor = isSelected
        ? tab.selectedTextColor
        : tab.unselectedTextColor
    }
}
