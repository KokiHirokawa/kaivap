//
//  PinCell.swift
//  kaivap
//
//  Created by KokiHirokawa on 2018/10/26.
//  Copyright © 2018年 KokiHirokawa. All rights reserved.
//

import UIKit


// Pin > Marker
class PinCell: UICollectionViewCell {

    @IBOutlet weak var pinImageView: UIImageView!
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            } else {
                self.transform = CGAffineTransform.identity
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
