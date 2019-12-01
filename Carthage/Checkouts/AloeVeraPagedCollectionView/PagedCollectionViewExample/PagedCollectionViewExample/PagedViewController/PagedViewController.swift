//
//  PagedViewController.swift
//  PagedCollectionViewExample
//
//  Created by Hani on 03.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit
import AloeVeraPagedCollectionView

final class PagedViewController: UIViewController {
    
    @IBOutlet private var pagedCollectionView: PagedCollectionView!
    
    private var section = PagedCollectionViewCell.Section(cellSource: .xib)
    private lazy var dataSource = DataSource(sections: [section])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupDataSource()
    }
}

private extension PagedViewController {
    func setupCollectionView() {
        pagedCollectionView.collectionViewLayout.pageSpacing = 50
        pagedCollectionView.collectionViewLayout.pageInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        pagedCollectionView.collectionViewLayout.shouldRespectAdjustedContentInset = false
        pagedCollectionView.configure()
    }
    
    func setupDataSource() {
        let viewModels = (0..<10).map { PagedCellViewModel(title: String($0)) }
        section.update(with: viewModels)
        section.registerCell(in: pagedCollectionView.collectionView)
        pagedCollectionView.collectionView.dataSource = dataSource
    }
}
