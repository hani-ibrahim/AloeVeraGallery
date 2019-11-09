//
//  AloeVeraGallery.swift
//  AloeVeraGallery
//
//  Created by Hani on 09.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

public struct AloeVeraGallery {
    
    public static func makeGallery(with sections: [SectionConfiguring], options: Options) -> GalleryViewController {
        GalleryViewController(sections: sections, options: options)
    }
}

extension AloeVeraGallery {
    public struct Options {
        let startIndex: Int
        let closeButton: CloseButton
        let backgroundColor: UIColor
        
        public init(closeButton: CloseButton, backgroundColor: UIColor, startIndex: Int = 0) {
            self.closeButton = closeButton
            self.backgroundColor = backgroundColor
            self.startIndex = startIndex
        }
    }
    
    public enum CloseButton {
        case hidden
        case visible(properties: Properties)
    }
}

extension AloeVeraGallery.CloseButton {
    public struct Properties {
        let title: String?
        let font: UIFont?
        let textColor: UIColor?
        let image: UIImage?
        let backgroundColor: UIColor
        
        public init(title: String?, font: UIFont?, textColor: UIColor?, image: UIImage?, backgroundColor: UIColor) {
            self.title = title
            self.font = font
            self.textColor = textColor
            self.image = image
            self.backgroundColor = backgroundColor
        }
    }
}
