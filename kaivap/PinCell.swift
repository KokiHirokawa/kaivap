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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func animate() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        })
    }
    
    // longGesture or SwipeGesture
    // delete location
    func deleteMarker() {
        
    }
}
