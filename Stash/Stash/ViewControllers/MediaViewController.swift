//
//  MediaViewController.swift
//  Stash
//
//  Created by Vikram Kumar on 09/06/26.
//

import UIKit

final class MediaViewController: UIViewController {
    
    private let headerView = HeaderView()
    
    private var dataSource: DataSource
    
    init(dataSource: DataSource) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
    }
}

extension MediaViewController {
    
    protocol DataSource: AnyObject {
        
    }
    
    protocol Delegate: AnyObject {
        
    }
}
