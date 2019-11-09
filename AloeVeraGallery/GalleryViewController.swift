//
//  GalleryViewController.swift
//  AloeVeraGallery
//
//  Created by Hani on 09.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import AloeVeraPagedCollectionView
import UIKit

open class GalleryViewController: UIViewController {
    
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var collectionViewLayout: PagedCollectionViewFlowLayout!
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var pageControl: UIPageControl!
    
    private let dataSource: CollectionViewDataSource
    private let options: AloeVeraGallery.Options
    
    public init(sections: [SectionConfiguring], options: AloeVeraGallery.Options) {
        self.dataSource = CollectionViewDataSource(sections: sections)
        self.options = options
        super.init(nibName: nil, bundle: Bundle(for: GalleryViewController.self))
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:) has not been implemented")
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = dataSource
        setupUI()
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionViewLayout.willRotate()
    }
    
    @IBAction private func closeButtonPressed() {
        dismiss(animated: true)
    }
}

private extension GalleryViewController {
    func setupUI() {
        
        closeButton.configure(for: options.closeButton)
        collectionView.backgroundColor = options.backgroundColor
    }
}

private extension UIButton {
    func configure(for closeButton: AloeVeraGallery.CloseButton) {
        switch closeButton {
        case .hidden:
            isHidden = true
        case .visible(let properties):
            isHidden = false
            setTitle(properties.title, for: .normal)
            titleLabel?.font = properties.font
            setTitleColor(properties.textColor, for: .normal)
            setImage(properties.image, for: .normal)
            backgroundColor = properties.backgroundColor
        }
    }
}
