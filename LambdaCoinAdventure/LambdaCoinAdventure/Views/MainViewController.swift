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
                           messages: ["testMessage"])
    var timer = Timer()
    var isTimerRunning = false
    var seconds = 0.0
    
    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var messagesLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var mapView: MapView!
    
    // MARK: - Actions

    @IBAction func upButtonPressed(_ sender: UIButton) {    movePlayer("n") }
    @IBAction func rightButtonPressed(_ sender: UIButton) { movePlayer("e") }
    @IBAction func leftButtonPressed(_ sender: UIButton) {  movePlayer("w") }
    @IBAction func downButtonPressed(_ sender: UIButton) {  movePlayer("s") }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        print("Start")
        
        // Clear MapView Coordinates
        
        
        // Call Lambda API endpoint
        apiController.initialize { (result) in
            if let room = try? result.get() {
                
                print("Room: \(room)")
                print(room.errors.isEmpty)
                DispatchQueue.main.async {
                    if room.errors.isEmpty {
                        // Sets returned API room as currentRoom triggering a didSet UI update
                        self.currentRoom = room
                        self.updateUI()
                        self.view.setNeedsDisplay()
                        self.mapView.apiController = self.apiController
                        self.mapView.setNeedsDisplay()
                        // TODO: - Make Coordinates Object from currentRoom
                        // and set that object to the MapView property
                    } else {
                        print("Room: \(room)")
                        print("Room Error: \(room.errors)")
                    }
                }
            }
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    
    // MARK: - Private Functions
    
    private func setupUI(){
        // Initial UI Setup
        updateUI()
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
        startButton.layer.cornerRadius = buttonRadius
        startButton.clipsToBounds = true
    }
    
    func updateUI() {
        
        // Formats array of string messages from Room Object into single string
        var msgString = ""
        if !currentRoom.messages.isEmpty {
            for message in currentRoom.messages {
                msgString.append(contentsOf: message)
                msgString.append(", ")
            }
            msgString.removeLast(2)
        } else {
            msgString = "No messages"
        }
        
        // Set Labels
        self.messagesLabel.text = msgString
        self.titleLabel.text = currentRoom.title
        self.idLabel.text = ("ID: \(String(currentRoom.room_id))")
        self.descriptionLabel.text = currentRoom.description
        self.seconds = currentRoom.cooldown
    }
    
    private func movePlayer(_ direction: String) {
        print(direction)
        apiController.move(direction: direction) { (result) in
            if let room = try? result.get() {
                DispatchQueue.main.async {
                    if room.errors.isEmpty {
                        // Sets returned API room as currentRoom triggering a didSet UI update
                        self.currentRoom = room
                        self.updateUI()
                        self.view.setNeedsDisplay()
                        self.mapView.apiController = self.apiController
                        self.mapView.setNeedsDisplay()
                        // Run Cooldown Timer
                        self.runTimer()
                        
                        print("Curent Room: \(self.currentRoom)")
                        // TODO: - Make Coordinates Object from currentRoom
                        // and set that object to the MapView property
                    } else {
                        print("Room: \(room)")
                        print("Room Error: \(room.errors)")
                    }
                }
            }
        }
    }
    
    private func runTimer() {
        self.seconds = self.currentRoom.cooldown
        isTimerRunning = true
        timerLabel.textColor = UIColor.systemRed
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        timerLabel.text = "\(seconds)"
        if seconds <= 0.0 {
            timerLabel.text = "0"
            timer.invalidate()
            self.isTimerRunning = false
            timerLabel.textColor = UIColor.darkGray
        }
        seconds -= 1
    }

}
