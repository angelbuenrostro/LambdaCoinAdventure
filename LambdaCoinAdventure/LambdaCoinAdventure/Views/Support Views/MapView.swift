//
//  MapView.swift
//  LambdaCoinAdventure
//
//  Created by Angel Buenrostro on 9/22/19.
//  Copyright © 2019 Angel Buenrostro. All rights reserved.
//

import UIKit

class MapView: UIView {
    
    let currentCoordinate: Coordinates = Coordinates(x: 60, y: 60, exits: ["n","s","w","e"])
    
    let pointsArray:[Coordinates] = [Coordinates(x: 0,y: 0, exits: ["s", "e"]),
                                     Coordinates(x: 60,y: 60, exits: ["n","s","w","e"])]
    let pointSize = CGSize(width: 8, height: 8)

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let viewWidth: CGFloat = self.bounds.width
        let viewHeight: CGFloat = self.bounds.height
        
        print(viewWidth)
        print(viewHeight)
        
        // Get Context
        //colorLiteral(red: 0.1311326623, green: 0.3781063557, blue: 0.6658913493, alpha: 1)
        let context = UIGraphicsGetCurrentContext()!
        let color = CGColor(srgbRed: 0.13, green: 0.37, blue: 0.66, alpha: 1)
        
        context.setLineWidth(2)
        context.setLineCap(.round)
        context.setStrokeColor(color)
        
        // Draw Points
        for coordinate in pointsArray {
            
            let point = convertCoordinates(coordinate: coordinate)
            let pointRect = CGRect(origin: point, size: pointSize)
            context.strokeEllipse(in: pointRect)
            
            // Checks to see player's current position within the map
            if coordinate == currentCoordinate {
                //#colorLiteral(red: 0.2899999917, green: 0.9499999881, blue: 0.6299999952, alpha: 1)
                let fillColor = CGColor(srgbRed: 0.29, green: 0.95, blue: 0.63, alpha: 1)
                context.setFillColor(fillColor)
                context.fill(pointRect)
            }
        }
    }
    
    func convertCoordinates(coordinate: Coordinates) -> CGPoint {
        var x = coordinate.x - 60
        var y = coordinate.y - 60
        
        // Used to create a map origin point from which coordinates are offset
        let mapCenter = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        
        // Offsets coordinate point by arbitrary amount to create spacing between points
        x *= 3
        y *= 3
        
        return CGPoint(x: mapCenter.x + CGFloat(x), y: mapCenter.y + CGFloat(y))
    }
}
