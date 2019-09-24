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
                           items: [],
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
    @IBOutlet weak var predictionTextField: UITextField!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var mapView: MapView!
    
    // MARK: - Actions

    @IBAction func upButtonPressed(_ sender: UIButton) {    movePlayer("n") }
    @IBAction func rightButtonPressed(_ sender: UIButton) { movePlayer("e") }
    @IBAction func leftButtonPressed(_ sender: UIButton) {  movePlayer("w") }
    @IBAction func downButtonPressed(_ sender: UIButton) {  movePlayer("s") }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        print("Start")
        startButton.isEnabled = false
        startButton.isHidden = true
        initPlayer()
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
        self.view.backgroundColor = #colorLiteral(red: 0.1483936906, green: 0.1771853268, blue: 0.2190909386, alpha: 1)
        self.mapView.backgroundColor = #colorLiteral(red: 0.1394269764, green: 0.1392630935, blue: 0.1629098058, alpha: 1)
        
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
        startButton.layer.cornerRadius = 10.0
        startButton.clipsToBounds = true
        timerLabel.layer.cornerRadius = 20.0
        timerLabel.clipsToBounds = true
        
        // Border
        startButton.layer.borderColor = UIColor.darkGray.cgColor
        startButton.layer.borderWidth = CGFloat(2.0)
        
        // Ready Cooldown
        self.timerLabel.text = ""
    }
    
    func updateUI() {
        
        self.predictionTextField.inputView = UIView()
        
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
        var prediction: String = ""
        if predictionTextField.text != nil {
            prediction = predictionTextField.text!
        }
        
        apiController.move(direction: direction, roomPrediction: prediction) { (result) in
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
                        self.validateMoveAbility()
                        
                        print("Curent Room: \(self.currentRoom)")
                    } else {
                        print("Room: \(room)")
                        print("Room Error: \(room.errors)")
                    }
                }
            }
        }
    }
    
    private func initPlayer() {
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
    
    private func runTimer() {
        self.seconds = self.currentRoom.cooldown
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
    }
    
    func validateMoveAbility(){
        if isTimerRunning {
            upButton.isEnabled = false
            downButton.isEnabled = false
            rightButton.isEnabled = false
            leftButton.isEnabled = false
        } else {
            upButton.isEnabled = true
            downButton.isEnabled = true
            rightButton.isEnabled = true
            leftButton.isEnabled = true
        }
    }
    
    @objc func updateTimer() {
        timerLabel.text = "\(Int(seconds))" // May cause issues if automating traversal as casting to int will round the time interval
        timerLabel.textColor = UIColor.black
        if seconds <= 0.0 {
            timerLabel.text = ""
            timer.invalidate()
            self.isTimerRunning = false
            timerLabel.textColor = UIColor.darkGray
            validateMoveAbility()
        }
        seconds -= 1
    }

}
