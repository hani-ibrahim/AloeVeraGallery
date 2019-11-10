//
//  ExampleViewController.swift
//  AloeVeraGalleryExample
//
//  Created by Hani on 09.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import AloeVeraGallery
import AloeVeraPagedCollectionView
import UIKit

final class ExampleViewController: UIViewController {
    
    @IBOutlet private var pagedCollectionView: PagedCollectionView!
    
    private lazy var dataSource = CollectionViewDataSource(sections: [section])
    private lazy var section: ImageCollectionViewCell.Section = {
        let viewModels = (0..<10).map { ImageCellViewModel(image: UIImage(named: "test-image-\($0)")!) }
        return ImageCollectionViewCell.Section(viewModels: viewModels, cellSource: .xib)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pagedCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        pagedCollectionView.collectionViewLayout.collectionViewSizeWillChange()
    }
}

private extension ExampleViewController {
    func setupView() {
        pagedCollectionView.pageSpacing = 20
        pagedCollectionView.collectionViewLayout.scrollDirection = .horizontal
        pagedCollectionView.collectionView.dataSource = dataSource
        pagedCollectionView.collectionView.delegate = self
        dataSource.registerCells(in: pagedCollectionView.collectionView)
        pagedCollectionView.configure()
    }
}

extension ExampleViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = GalleryViewController(sections: [section], pageSpacing: 50, startIndexPath: indexPath)
        viewController.modalPresentationStyle = .fullScreen
        viewController.delegate = self
        present(viewController, animated: true)
    }
}

extension ExampleViewController: GalleryDelegate {
    func gallery(galleryViewController: GalleryViewController, didScrollToItemAt indexPath: IndexPath) {
        pagedCollectionView.scrollToItem(at: indexPath)
    }
}
