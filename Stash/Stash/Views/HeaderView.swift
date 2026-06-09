//
//  HeaderView.swift
//  Stash
//
//  Created by Vikram Kumar on 09/06/26.
//

import UIKit

final class HeaderView: UIView {
    private var mainStackView = UIStackView()
    private let leftImage = UIImageView()
    private let title = UILabel()
    
    init(){
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        mainStackView.axis = .horizontal
        mainStackView.distribution = .fillEqually
        addSubview(mainStackView)
        mainStackView.addArrangedSubview(leftImage)
        mainStackView.addArrangedSubview(title)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    public func setData(header: HeaderObject) {
        title.text = header.title
        leftImage.image = header.leftImage
    }
}
