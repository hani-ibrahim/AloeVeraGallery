//
//  ExampleViewController.swift
//  AloeVeraGalleryExample
//
//  Created by Hani on 09.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import AloeVeraGallery
import UIKit

final class ExampleViewController: UIViewController {
    
    @IBAction private func openGalleryButtonPressed() {
        let viewModels = (0..<10).map { ImageCellViewModel(image: UIImage(named: "test-image-\($0)")!) }
        let section = ImageCollectionViewCell.Section(viewModels: viewModels, cellSource: .xib)
        let viewController = GalleryViewController(sections: [section], pageSpacing: 50, startIndex: nil)
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
}
