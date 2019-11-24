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
    
    private let transitionDelegate = GalleryTransitionDelegate()
    private lazy var dataSource = CollectionViewDataSource(sections: [makeImageSection(withContentMode: .aspectFill)])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
}

private extension ExampleViewController {
    func setupView() {
        pagedCollectionView.collectionViewLayout.pageSpacing = 20
        pagedCollectionView.collectionViewLayout.scrollDirection = .horizontal
        pagedCollectionView.collectionView.dataSource = dataSource
        pagedCollectionView.collectionView.delegate = self
        dataSource.registerCells(in: pagedCollectionView.collectionView)
        pagedCollectionView.configure()
    }
    
    func makeImageSection(withContentMode contentMode: ImageCellContentMode) -> ImageCollectionViewCell.Section {
        let viewModels = (0..<10).map { ImageCellViewModel(image: UIImage(named: "test-image-\($0)")!, contentMode: contentMode) }
        return ImageCollectionViewCell.Section(viewModels: viewModels, cellSource: .xib)
    }
}

extension ExampleViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = GalleryViewController.makeViewController()
        viewController.sections = [makeImageSection(withContentMode: .aspectFit)]
        viewController.pageSpacing = 50
        viewController.startingIndexPath = indexPath
        viewController.delegate = self
        viewController.transitioningDelegate = transitionDelegate
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
}

extension ExampleViewController: GalleryTransitionSourceViewController {
    var sourceView: UIView {
        pagedCollectionView
    }
    
    var sourceCropMode: GallerySourceCropMode {
        guard let cell = pagedCollectionView.collectionView.visibleCells.first as? ImageCollectionViewCell else {
            return .none
        }
        print("cell.cropMode: \(cell.cropMode)")
        return cell.cropMode
    }
    
    func sourceViewFrame(relativeTo view: UIView) -> CGRect {
        view.convert(pagedCollectionView.frame, to: view)
    }
}

extension ExampleViewController: GalleryDelegate {
    func gallery(galleryViewController: GalleryViewController, didScrollToItemAt indexPath: IndexPath) {
        pagedCollectionView.updateIndexPathForNextViewLayout(with: indexPath)
    }
    
    func didCloseGalleryView() {
        
    }
}
