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
        let viewController = AloeVeraGallery.makeGallery()
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
}
