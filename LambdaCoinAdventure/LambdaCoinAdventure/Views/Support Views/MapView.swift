//
//  MapView.swift
//  LambdaCoinAdventure
//
//  Created by Angel Buenrostro on 9/22/19.
//  Copyright © 2019 Angel Buenrostro. All rights reserved.
//

import UIKit

class MapView: UIView {
    
    let pointsArray:[Coordinates] = []

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let viewWidth: CGFloat = self.bounds.width
        let viewHeight: CGFloat = self.bounds.height
        
        print(viewWidth)
        print(viewHeight)
    }
    

}
