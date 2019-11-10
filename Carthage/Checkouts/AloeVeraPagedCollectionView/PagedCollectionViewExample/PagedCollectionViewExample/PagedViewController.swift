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
        pagedCollectionView.collectionViewLayout.pageSpacing = 50
        pagedCollectionView.collectionViewLayout.pageInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        pagedCollectionView.collectionViewLayout.shouldRespectAdjustedContentInset = false
        pagedCollectionView.collectionView.dataSource = self
        pagedCollectionView.collectionView.registerCell(ofType: PagedCollectionViewCell.self)
        pagedCollectionView.configure()
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
