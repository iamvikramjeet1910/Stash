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

    private let pillView: UIView = {
        let v = UIView()
        v.backgroundColor = StashTheme.tabBarPill
        v.layer.cornerRadius = 28
        v.layer.cornerCurve = .continuous
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.35
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
        v.layer.shadowRadius = 14
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let mainStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 8
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        pillView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0.35 : 0.15
    }

    private func setupUI() {
        backgroundColor = .clear

        addSubview(pillView)
        pillView.addSubview(mainStackView)

        NSLayoutConstraint.activate([
            pillView.topAnchor.constraint(equalTo: topAnchor),
            pillView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pillView.trailingAnchor.constraint(equalTo: trailingAnchor),
            pillView.bottomAnchor.constraint(equalTo: bottomAnchor),

            mainStackView.topAnchor.constraint(equalTo: pillView.topAnchor, constant: 8),
            mainStackView.leadingAnchor.constraint(equalTo: pillView.leadingAnchor, constant: 12),
            mainStackView.trailingAnchor.constraint(equalTo: pillView.trailingAnchor, constant: -12),
            mainStackView.bottomAnchor.constraint(equalTo: pillView.bottomAnchor, constant: -8),
        ])
    }

    func configure(with tabs: [TabObject]) {
        self.tabs = tabs

        mainStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        tabViews.removeAll()

        for (index, tab) in tabs.enumerated() {
            let tabView = TabItemView()
            tabView.configure(with: tab, isSelected: index == 0)
            tabView.tag = index
            tabView.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(tabTapped(_:)))
            )
            tabViews.append(tabView)
            mainStackView.addArrangedSubview(tabView)
        }
    }

    @objc private func tabTapped(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        selectTab(at: view.tag)
        delegate?.didSelectTab(index: view.tag, tabId: tabs[view.tag].tabId)
    }

    func selectTab(at index: Int) {
        selectedIndex = index
        for (idx, tabView) in tabViews.enumerated() {
            tabView.updateSelectionState(isSelected: idx == index)
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
        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        layer.cornerRadius = 20
        layer.cornerCurve = .continuous

        titleLabel.font = .systemFont(ofSize: 11, weight: .medium)
        iconView.contentMode = .scaleAspectFit
    }

    func configure(with tab: TabObject, isSelected: Bool) {
        self.tab = tab
        iconView.image = tab.icon
        titleLabel.text = tab.title
        updateSelectionState(isSelected: isSelected)
    }

    func updateSelectionState(isSelected: Bool) {
        guard let tab else { return }
        backgroundColor = isSelected ? tab.selectedBgColor : tab.unselectedBgColor
        titleLabel.textColor = isSelected ? tab.selectedTextColor : tab.unselectedTextColor
        iconView.tintColor = isSelected ? tab.selectedTextColor : tab.unselectedTextColor
    }
}
