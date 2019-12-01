//
//  CenteredItemViewController.swift
//  PagedCollectionViewExample
//
//  Created by Hani on 03.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit
import AloeVeraPagedCollectionView

final class CenteredItemViewController: UIViewController {
    
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var collectionViewLayout: CenteredItemCollectionViewFlowLayout!
    
    private let visibleCenterView = UIView()
    private var section = CenteredItemCollectionViewCell.Section(cellSource: .storyboard)
    private lazy var dataSource = DataSource(sections: [section])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVisibleCenterView()
        setupDataSource()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateVisibleCenterLocation()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionViewLayout.collectionViewSizeWillChange()
    }
}

private extension CenteredItemViewController {
    func setupVisibleCenterView() {
        visibleCenterView.frame.size = CGSize(width: 10, height: 10)
        visibleCenterView.backgroundColor = .green
        visibleCenterView.layer.cornerRadius = 5
        view.addSubview(visibleCenterView)
    }
    
    func setupDataSource() {
        let viewModels = (0..<1000).map { index in
            CenteredItemCellViewModel(
                title: String(index),
                backgroundColor: index == 162 ? .blueCell : .red
            )
        }
        section.update(with: viewModels)
        collectionView.dataSource = dataSource
    }
    
    func updateVisibleCenterLocation() {
        let offset = (collectionView.adjustedContentInset.top - collectionView.adjustedContentInset.bottom) / 2
        visibleCenterView.center = CGPoint(x: collectionView.center.x, y: collectionView.center.y + offset)
    }
}

private extension UIColor {
    static let blueCell = UIColor(red: 0.1, green: 0.1, blue: 0.8, alpha: 1)
}
