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
    
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var collectionViewLayout: PagedCollectionViewFlowLayout!
    
    private let data = (0..<10).map { String($0) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewLayout.pageInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionViewLayout.pageSpacing = 50
        collectionViewLayout.shouldRespectAdjustedContentInset = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionViewLayout.willRotate()
    }
}

extension PagedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(ofType: TestCollectionViewCell.self, at: indexPath)
        cell.titleLabel.text = data[indexPath.row]
        return cell
    }
}
