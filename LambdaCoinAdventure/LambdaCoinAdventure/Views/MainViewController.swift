//
//  MainViewController.swift
//  LambdaCoinAdventure
//
//  Created by Angel Buenrostro on 9/22/19.
//  Copyright © 2019 Angel Buenrostro. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    // MARK: - Properties
    let apiController = APIController()
    var currentRoom = Room(room_id: -1,
                           title: "testTitle",
                           description: "testDescription",
                           coordinates: "(1,1)",
                           items: nil,
                           exits: ["w","e"],
                           cooldown: 1.0,
                           errors: [],
                           messages: ["testMessage"]) {
        didSet {
            self.view.setNeedsLayout()
        }
    }
    
    // MARK: - Outlets

    @IBOutlet weak var mapView: MapView!
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    
    // MARK: - Actions
    @IBAction func upButtonPressed(_ sender: UIButton) {
        movePlayer("n")
    }
    
    @IBAction func rightButtonPressed(_ sender: UIButton) {
        movePlayer("e")
    }
    
    @IBAction func leftButtonPressed(_ sender: UIButton) {
        movePlayer("w")
    }
    
    @IBAction func downButtonPressed(_ sender: UIButton) {
        movePlayer("s")
    }
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        setupUI()
        
    }
    
    
    // MARK: - Private Functions
    
    private func setupUI(){
        // Background Color
        self.view.backgroundColor = #colorLiteral(red: 0.07691047341, green: 0.0657993257, blue: 0.1335668266, alpha: 1)
        
        // Round Map
        mapView.layer.opacity = 0.80
        mapView.layer.cornerRadius = 16.0
        mapView.clipsToBounds = true
        
        // Round Buttons
        let buttonRadius = CGFloat(6.0)
        upButton.layer.cornerRadius = buttonRadius
        upButton.clipsToBounds = true
        leftButton.layer.cornerRadius = buttonRadius
        leftButton.clipsToBounds = true
        rightButton.layer.cornerRadius = buttonRadius
        rightButton.clipsToBounds = true
        downButton.layer.cornerRadius = buttonRadius
        downButton.clipsToBounds = true
    }
    
    private func movePlayer(_ direction: String) {
        print(direction)
//        apiController.move(direction: direction) { (result) in
//            if let room = try? result.get() {
//                DispatchQueue.main.async {
//                    if room.errors.isEmpty {
//                        // Sets returned API room as currentRoom triggering a didSet UI update
//                        self.currentRoom = room
//                    } else {
//                        print("Room: \(room)")
//                        print("Room Error: \(room.errors)")
//                    }
//                }
//            }
//        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
