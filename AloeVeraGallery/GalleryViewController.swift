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
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var pageControl: UIPageControl!
    
    @IBAction private func closeButtonPressed() {
        dismiss(animated: true)
    }
}
