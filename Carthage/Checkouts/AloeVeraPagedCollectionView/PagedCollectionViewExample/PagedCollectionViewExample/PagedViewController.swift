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
    
    private let data = (0..<10).map { String($0) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pagedCollectionView.pageSpacing = 50
        pagedCollectionView.collectionViewLayout.scrollDirection = .horizontal
        pagedCollectionView.collectionView.dataSource = self
        pagedCollectionView.collectionView.registerCell(ofType: PagedCollectionViewCell.self)
        pagedCollectionView.configure()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        pagedCollectionView.collectionViewLayout.collectionViewSizeWillChange()
    }
}

extension PagedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(ofType: PagedCollectionViewCell.self, at: indexPath)
        cell.titleLabel.text = data[indexPath.row]
        return cell
    }
}
