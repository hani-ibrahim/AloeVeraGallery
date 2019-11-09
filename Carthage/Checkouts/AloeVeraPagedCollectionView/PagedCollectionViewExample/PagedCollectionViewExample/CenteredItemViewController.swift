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
    private let data = (0..<1000).map { String($0) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visibleCenterView.frame.size = CGSize(width: 10, height: 10)
        visibleCenterView.backgroundColor = .green
        visibleCenterView.layer.cornerRadius = 5
        view.addSubview(visibleCenterView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let offset = (collectionView.adjustedContentInset.top - collectionView.adjustedContentInset.bottom) / 2
        visibleCenterView.center = CGPoint(x: collectionView.center.x, y: collectionView.center.y + offset)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionViewLayout.willRotate()
    }
}

extension CenteredItemViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(ofType: TestCollectionViewCell.self, at: indexPath)
        cell.titleLabel.text = data[indexPath.row]
        cell.backgroundColor = indexPath.item == 162 ? UIColor(red: 0.1, green: 0.1, blue: 0.8, alpha: 1) : .red
        return cell
    }
}
