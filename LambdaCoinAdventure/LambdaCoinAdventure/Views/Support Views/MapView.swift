//
//  MapView.swift
//  LambdaCoinAdventure
//
//  Created by Angel Buenrostro on 9/22/19.
//  Copyright © 2019 Angel Buenrostro. All rights reserved.
//

import UIKit

class MapView: UIView {
    
    
    var apiController : APIController? = nil
    let pointSize = CGSize(width: 12, height: 12)

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        print("Drawing Map")
        // Drawing code
        
        // Get Context
        //colorLiteral(red: 0.1311326623, green: 0.3781063557, blue: 0.6658913493, alpha: 1)
        let context = UIGraphicsGetCurrentContext()!
            
        // Check for apiController reference
        guard let apiController = self.apiController else { return }
        
        // Draw Points
        
        print("Num in mapSet: \(apiController.mapSet.count)")
        for coordinate in apiController.mapSet {
            
            let roomColor = UIColor.darkGray.cgColor
            
            context.setLineWidth(2)
            context.setLineCap(.round)
            context.setStrokeColor(roomColor)
            
            let point = convertCoordinates(coordinate: coordinate)
            // Draws an ellipse exactly around the origin point
            let pointRect = CGRect(origin: CGPoint(x: point.x - (pointSize.width/2),
                                                   y: point.y + (pointSize.height/2)),
                                                                    size: pointSize)
            
            // Draws Exit Markers to relevant cardinal direction
            if !coordinate.exits.isEmpty {
                let exits = coordinate.exits
                
                //#colorLiteral(red: 0.8590026498, green: 0.9080110788, blue: 0.9488238692, alpha: 1)
                let lineColor = UIColor.white.cgColor
                context.setLineWidth(3)
                context.setStrokeColor(lineColor)
                
                for exit in exits {
                    drawHallway(direction: exit, context: context, startPoint: point)
                }
            }
            
            // Checks to see player's current position within the map
            guard let currentCoordinate = apiController.currentCoordinate else { return }
            if coordinate == currentCoordinate {
                //UIColor(red: 0.40, green: 0.22, blue: 0.94, alpha: 1.00)
                let fillColor = #colorLiteral(red: 0.6036551595, green: 0.2437257618, blue: 0.3888348937, alpha: 1).cgColor
                context.setFillColor(fillColor)
                context.fillEllipse(in: pointRect)
            }
            
            context.strokeEllipse(in: pointRect)
            
        }
    }
    
    private func convertCoordinates(coordinate: Coordinates) -> CGPoint {
        var x = coordinate.x - 60
        var y = coordinate.y - 60
        
        // Used to create a map origin point from which coordinates are offset
        let mapCenter = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        // Offsets coordinate point by arbitrary amount to create spacing between points
        x *= Int(pointSize.width) + 24
        y *= Int(-pointSize.height) - 14
        
        return CGPoint(x: mapCenter.x + CGFloat(x), y: mapCenter.y + CGFloat(y))
    }
    
    private func drawHallway(direction: String, context: CGContext, startPoint: CGPoint) {
        context.beginPath()
        let roomSizeOffset = (pointSize.height/2 + 2.4)
        let centerX = startPoint.x
        let centerY = startPoint.y + pointSize.height
        
        var endPoint = startPoint
        
        if direction == "n" {
            context.move(to: CGPoint(x: centerX, y: centerY - roomSizeOffset))
            endPoint = CGPoint(x: centerX, y: context.currentPointOfPath.y - roomSizeOffset)
        }
        else if direction == "s" {
            context.move(to: CGPoint(x: centerX, y: centerY + roomSizeOffset))
            endPoint = CGPoint(x: centerX, y: context.currentPointOfPath.y + roomSizeOffset)
        }
        else if direction == "w" {
            context.move(to: CGPoint(x:centerX - roomSizeOffset, y: centerY))
            endPoint = CGPoint(x: context.currentPointOfPath.x - roomSizeOffset, y: centerY)
            
        }
        else if direction == "e" {
            context.move(to: CGPoint(x: centerX + roomSizeOffset, y: centerY))
            endPoint = CGPoint(x: context.currentPointOfPath.x + roomSizeOffset, y: centerY)
            
        }
        context.addLine(to: endPoint)
        context.drawPath(using: .stroke)
    }
}
