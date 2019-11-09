//
//  AloeVeraGallery.swift
//  AloeVeraGallery
//
//  Created by Hani on 09.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import Foundation

public struct AloeVeraGallery {
    
    public static func makeGallery() -> GalleryViewController {
        GalleryViewController(nibName: nil, bundle: Bundle(for: BundleToken.self))
    }
}

private class BundleToken {}
