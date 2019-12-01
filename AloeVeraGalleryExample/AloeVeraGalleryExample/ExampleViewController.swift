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
    
    private lazy var transitionDelegate = GalleryTransitionDelegate(source: self)
    private lazy var dataSource = DataSource(sections: [makeImageSection(withFillMode: .aspectFill)])
    private var startingIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
}

private extension ExampleViewController {
    func setupView() {
        pagedCollectionView.collectionViewLayout.pageSpacing = 20
        pagedCollectionView.collectionViewLayout.scrollDirection = .horizontal
        pagedCollectionView.collectionViewLayout.shouldRespectAdjustedContentInset = false
        pagedCollectionView.collectionView.dataSource = dataSource
        pagedCollectionView.collectionView.delegate = self
        dataSource.registerCells(in: pagedCollectionView.collectionView)
        pagedCollectionView.configure()
    }
    
    func makeImageSection(withFillMode fillMode: GalleryFillMode) -> ImageCollectionViewCell.Section {
        let viewModels = (0..<10).map { ImageCellViewModel(image: UIImage(named: "test-image-\($0)")!, fillMode: fillMode) }
        return ImageCollectionViewCell.Section(cellSource: .xib, viewModels: viewModels)
    }
}

extension ExampleViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        startingIndex = indexPath.item
        let viewController = GalleryViewController.makeViewController()
        viewController.sections = [makeImageSection(withFillMode: .aspectFit)]
        viewController.pageSpacing = 50
        viewController.startingIndexPath = indexPath
        viewController.delegate = self
        viewController.transitioningDelegate = transitionDelegate
        viewController.modalPresentationStyle = .overFullScreen
        present(viewController, animated: true)
    }
}

extension ExampleViewController: GalleryTransitionSource {
    var sourceView: UIView {
        pagedCollectionView
    }
    
    var metadata: GalleryTransitionMetadata {
        let imageSize = UIImage(named: "test-image-\(startingIndex)")!.size
        return GalleryTransitionMetadata(
            contentAspectRatio: imageSize.width / imageSize.height,
            sourceFillMode: .aspectFill,
            destinationFillMode: .aspectFit
        )
    }
    
    func sourceViewFrame(relativeTo containerView: UIView) -> CGRect {
        view.convert(pagedCollectionView.frame, to: containerView)
    }
}

extension ExampleViewController: GalleryDelegate {
    func gallery(galleryViewController: GalleryViewController, didScrollToItemAt indexPath: IndexPath) {
        pagedCollectionView.updateIndexPathForNextViewLayout(with: indexPath)
    }
    
    func didClose(galleryViewController: GalleryViewController, source: CloseSource) {
        
    }
}
