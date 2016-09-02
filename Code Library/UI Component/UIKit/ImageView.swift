//
//  ImageView.swift
//
//
//  Created by 黄穆斌 on 16/8/30.
//
//

import UIKit

class ImageView: UIImageView {
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        load()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        load()
    }
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        load()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        load()
    }
    
    private func load() {
        layer.masksToBounds = true
        layer.cornerRadius = corner
    }
    
    // MARK: - MASK
    
    let maskLayer = CALayer()
    
    @IBInspectable var corner: CGFloat = 0 {
        didSet {
            layer.cornerRadius = corner
            layer.displayIfNeeded()
        }
    }
    
    func round() {
        maskLayer.cornerRadius = bounds.height / 2
        layer.displayIfNeeded()
    }
    
}
