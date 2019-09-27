//
//  MapView.swift
//  LambdaCoinAdventure
//
//  Created by Angel Buenrostro on 9/22/19.
//  Copyright © 2019 Angel Buenrostro. All rights reserved.
//

import UIKit

class MapView: UIView {
    
    weak var delegate: WiseMoveDelegate?
    
    var apiController : APIController? = nil
    let pointSize = CGSize(width: 20 , height: 20)
    
    var infoLabelMade = false
    var infoLabelRef: UILabel?
    var superviewCenter: CGPoint?
    
    var idDict: [String:Int] = [:] // Keys -> String MinXMinY frame of UIButtons  : Values -> RoomID #
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
//        print("Drawing Map")
        // Drawing code
        
        // Get Context
        let context = UIGraphicsGetCurrentContext()!
            
        // Check for apiController reference
        guard let apiController = self.apiController else { return }
        
        // Draw Points
        
//        print("Num in mapSet: \(apiController.mapSet.count)")
        for coordinate in apiController.mapSet {
            
            
            let point = convertCoordinates(coordinate: coordinate)
            // Draws an ellipse exactly around the origin point
            let pointRect = CGRect(origin: CGPoint(x: point.x - (pointSize.width/2),
                                                   y: point.y + (pointSize.height/2)),
                                                                    size: pointSize)
            
            addButton(on: pointRect, coordinate: coordinate)
            
            // Draws Exit Markers to relevant cardinal direction
            if !coordinate.exits.isEmpty {
                let exits = coordinate.exits
                let lineColor = UIColor.lightGray.cgColor
                
                context.setLineWidth(2)
                context.setStrokeColor(lineColor)
                
                for exit in exits {
                    context.setBlendMode(.luminosity)
                    drawHallway(direction: exit, context: context, startPoint: point)
                }
                context.setBlendMode(.normal)
            }
            
            // Draw Room Circle
            var roomColor = UIColor.white.cgColor
            var lineWidth = CGFloat(3)
            // Different colors denote special rooms
            if coordinate.shop {
                roomColor = #colorLiteral(red: 0.9993286729, green: 0.7073625326, blue: 0.4233144522, alpha: 1).cgColor
                lineWidth += 1
            } else if coordinate.shrine {
                roomColor = #colorLiteral(red: 0.3600000143, green: 0.7900000215, blue: 0.9599999785, alpha: 1).cgColor
                lineWidth += 1
            } else if coordinate.mine {
                roomColor = #colorLiteral(red: 1, green: 0.1705859303, blue: 0.1705859303, alpha: 1).cgColor
                lineWidth += 1
            } else if coordinate.nameChanger {
                roomColor = #colorLiteral(red: 0.2899999917, green: 0.9499999881, blue: 0.6299999952, alpha: 1).cgColor
                lineWidth += 1
            } else if coordinate.transmogrifier {
                roomColor = #colorLiteral(red: 0.9700000286, green: 0.5400000215, blue: 0.8799999952, alpha: 1).cgColor
                lineWidth += 1
            } else if coordinate.elevated {
                roomColor = #colorLiteral(red: 0.1366455257, green: 0.2963576317, blue: 0.495860517, alpha: 1).cgColor
                lineWidth = CGFloat(5)
            } else if coordinate.trap {
                lineWidth = CGFloat(2)
                context.setFillColor(#colorLiteral(red: 0.6908203363, green: 0.2223847806, blue: 0.2223847806, alpha: 0.8).cgColor)
                context.fillEllipse(in: pointRect)
                context.fill(pointRect)
            }
            
            context.setLineWidth(lineWidth)
            context.setLineCap(.round)
            context.setStrokeColor(roomColor)

            // Checks to see player's current position within the map
            // Also stores currentCoordinate ID into a dictionary set so a button press on coordinate position can return roomID when needed
            guard let currentCoordinate = apiController.currentCoordinate else { return }
            if coordinate == currentCoordinate {
                context.setFillColor(UIColor.white.cgColor)
                context.fillEllipse(in: pointRect)
            }
                        
//            context.stroke(pointRect)
            context.strokeEllipse(in: pointRect)
        }
    }
    
    private func convertCoordinates(coordinate: Coordinates) -> CGPoint {
        var x = coordinate.x - 60
        var y = coordinate.y - 60
        
        // Used to create a map origin point from which coordinates are offset
        let mapCenter = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
//        let mapCenter = superviewCenter!
        // Offsets coordinate point by arbitrary amount to create spacing between points
        x *= Int(pointSize.width) + 12
        y *= Int(-pointSize.height) - 9
        
        return CGPoint(x: mapCenter.x + CGFloat(x), y: mapCenter.y + CGFloat(y))
    }
    
    private func drawHallway(direction: String, context: CGContext, startPoint: CGPoint) {
        context.beginPath()
        
        context.setStrokeColor(  #colorLiteral(red: 0.8590000272, green: 0.908010006, blue: 0.9488199949, alpha: 1).cgColor)
        context.setLineWidth(CGFloat(4))
        
        let roomSizeOffset = (pointSize.height/2 + 0)
        let centerX = startPoint.x
        let centerY = startPoint.y + pointSize.height
        
        var endPoint = startPoint
        if direction == "s" || direction == "w" {
            
            if direction == "r" {
                //            context.move(to: CGPoint(x: centerX, y: centerY - roomSizeOffset))
                //            endPoint = CGPoint(x: centerX, y: context.currentPointOfPath.y - roomSizeOffset + 1)
            }
            else if direction == "s" {
                context.move(to: CGPoint(x: centerX, y: centerY + roomSizeOffset))
                endPoint = CGPoint(x: centerX, y: context.currentPointOfPath.y + (roomSizeOffset - 4) )
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
    
    func addButton(on pointRect: CGRect, coordinate: Coordinates){
        
        let biggerRect = CGRect(x: pointRect.minX - 3, y: pointRect.minY - 3, width: pointRect.width + 6, height: pointRect.height + 6)
        // Check Dictionary set of buttons, if does not exist at MinXMinY Dictionary then add new button, else do nothing.
        
        // Create dictionary
        let frameKey = getFrameKey(rect: biggerRect)
        if idDict.keys.contains(frameKey) {
            return
        } else {
            //MARK: - TODO
            idDict[frameKey] = coordinate.id
            let numLabel = UILabel(frame: biggerRect)
            numLabel.text = String(coordinate.id)
            numLabel.font = UIFont(name: "Gilroy-Bold", size: 9)
            numLabel.textAlignment = .center
            numLabel.textColor = .clear
            numLabel.backgroundColor = UIColor.clear
            numLabel.layer.borderColor = UIColor.clear.cgColor
            numLabel.layer.borderWidth = 2
            
            
            let infoButton = UIButton(frame: biggerRect)
            infoButton.setTitle(String(coordinate.id), for: .normal)
            infoButton.setTitleColor(UIColor.clear, for: .normal)
            infoButton.backgroundColor = UIColor.clear
            infoButton.addTarget(self, action: #selector(infoButtonPressed(sender:)), for: .touchUpInside)
//            infoButton.addTarget(self, action: #selector(wiseMoveButtonPressed(sender:)), for: .touchUpInside)
            // Add button to self.superview.superview to put it on the mainVC
            self.addSubview(infoButton)
            self.addSubview(numLabel)
//            self.superview?.superview?.addSubview(infoButton)
        }
    }
    
    @objc func wiseMoveButtonPressed(sender: UIButton) {
        let frameKey = getFrameKey(rect: sender.frame)
        guard let nextID = idDict[frameKey] else {
            fatalError()
        }
        self.apiController?.move(direction: "w", roomPrediction: String(nextID), completion: { (result) in
            print("movedFast")
        })
    }
    
    @objc func infoButtonPressed(sender: UIButton!) {
        
        delegate?.inputIDToTextfield(sender.title(for: .normal)!)
        if sender.title(for: .normal) != nil {
            print("button has title: \(sender.title(for: .normal))")
        }
//        let frameKey = getFrameKey(rect: sender.frame)
//        if sender.backgroundColor != #colorLiteral(red: 0.5765730143, green: 0.8659184575, blue: 0.9998990893, alpha: 0.7) {
//
//            guard let nextID = idDict[frameKey] else { fatalError() }
            
//            print(nextID)
            
            // Draw UILabel with RoomID info on screen
            // Bool check prevents duplicaate labels
//            if infoLabelMade == false {
//                let infoLabel = UILabel()
//                infoLabel.frame = CGRect(x: self.frame.maxX - 210, y: 860, width: 200, height: 50)
//                infoLabel.textAlignment = .center
//                infoLabel.backgroundColor = #colorLiteral(red: 0, green: 0.4770143032, blue: 0.9955772758, alpha: 1)
//                infoLabel.layer.cornerRadius = 8.0
//                infoLabel.textColor = .white
//                infoLabel.clipsToBounds = true
//                infoLabel.adjustsFontSizeToFitWidth = true
//                infoLabel.minimumScaleFactor = 0.5
//
//                self.insertSubview(infoLabel, at: 0)
//                infoLabelMade = true
//                infoLabel.text = String(nextID)
//                guard let customFont = UIFont(name: "Gilroy-Bold", size: UIFont.labelFontSize) else {
//                    fatalError("failed to load custom font")
//                }
//                infoLabel.font = customFont
//                infoLabelRef = infoLabel
//            } else {
//                guard var idText = infoLabelRef!.text else { fatalError() }
//                if idText.count > 18 {
//                    idText = String(idText.dropFirst(3))
//                }
//
//                infoLabelRef!.text = idText + " " + (String(nextID))
//                self.subviews[0].isHidden = false
//                sender.backgroundColor = #colorLiteral(red: 0.5765730143, green: 0.8659184575, blue: 0.9998990893, alpha: 0.7)
//            }
//        } else {
//            self.subviews[0].isHidden = true
//            infoLabelRef!.text = ""
//            sender.backgroundColor = nil
//        }
    }
    
    private func getFrameKey(rect: CGRect) -> String {
        let frameXMin = String(Int(rect.minX))
        let frameYMin = String(Int(rect.minY))
        let frameKey = frameXMin + frameYMin
        return frameKey
    }
}


protocol WiseMoveDelegate: class {
    func inputIDToTextfield(_ id: String) 
}
