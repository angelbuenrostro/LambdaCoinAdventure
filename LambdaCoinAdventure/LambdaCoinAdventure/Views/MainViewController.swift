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
    var player: Player?
    var timer = Timer()
    var seconds = 0.0
    var isTimerRunning = false
    
    let errorLabel: UILabel = UILabel()
    
    var isDashing = false
    var isFlying = false
    var isPlaying = false
    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var messagesLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    // Status Labels
    @IBOutlet weak var statusBGView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var goldLabel: UILabel!
    @IBOutlet weak var strengthLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var encumbranceLabel: UILabel!
    
    // Controls
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var predictionTextField: UITextField!
    @IBOutlet weak var dashButton: UIButton!
    @IBOutlet weak var flyButton: UIButton!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var mapView: MapView!
    
    // MARK: - Actions
    @IBAction func dashButtonPressed(_ sender: UIButton) {
        if isFlying == false {
            isDashing = !isDashing
            if isDashing {
                dashButton.backgroundColor = #colorLiteral(red: 0.1394269764, green: 0.1392630935, blue: 0.1629098058, alpha: 1)
                dashButton.layer.borderWidth = 2.0
                dashButton.layer.borderColor = #colorLiteral(red: 0.131129995, green: 0.3781099916, blue: 0.6658899784, alpha: 1)
            } else {
                dashButton.backgroundColor = UIColor.clear
                dashButton.layer.borderWidth = 0.0
            }
        }
    }
    
    @IBAction func flyButtonPressed(_ sender: UIButton) {
        if isDashing == false {
            isFlying = !isFlying
            if isFlying {
                flyButton.backgroundColor = #colorLiteral(red: 0.1394269764, green: 0.1392630935, blue: 0.1629098058, alpha: 1)
                flyButton.layer.borderWidth = 2.0
                flyButton.layer.borderColor = #colorLiteral(red: 0.131129995, green: 0.3781099916, blue: 0.6658899784, alpha: 1)
            } else {
                flyButton.backgroundColor = UIColor.clear
                flyButton.layer.borderWidth = 0.0
            }
        }
    }
    
    @IBAction func upButtonPressed(_ sender: UIButton) {    movePlayer("n") }
    @IBAction func rightButtonPressed(_ sender: UIButton) { movePlayer("e") }
    @IBAction func leftButtonPressed(_ sender: UIButton) {  movePlayer("w") }
    @IBAction func downButtonPressed(_ sender: UIButton) {  movePlayer("s") }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        print("Start")
        if isPlaying == false {
            startButton.setTitle("STATUS", for: .normal)
            initPlayer()
        } else {
            updateStatus()
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
        self.view.backgroundColor = #colorLiteral(red: 0.1483936906, green: 0.1771853268, blue: 0.2190909386, alpha: 1)
        self.mapView.backgroundColor = #colorLiteral(red: 0.1394269764, green: 0.1392630935, blue: 0.1629098058, alpha: 1)
        self.predictionTextField.backgroundColor = #colorLiteral(red: 0.1394269764, green: 0.1392630935, blue: 0.1629098058, alpha: 1)
        startButton.backgroundColor = UIColor.systemBlue
        
        // Borders
        mapView.layer.borderWidth = 2.0
        mapView.layer.borderColor = #colorLiteral(red: 0.06660000235, green: 0.06315000355, blue: 0.06259000301, alpha: 1)
//        startButton.layer.borderColor = UIColor.black.cgColor
//        startButton.layer.borderWidth = CGFloat(4.0)
        
        // Shadows
        startButton.layer.shadowPath = UIBezierPath(roundedRect: self.startButton.bounds, cornerRadius: self.startButton.layer.cornerRadius).cgPath
        startButton.layer.shadowColor = #colorLiteral(red: 0.3600000143, green: 0.7900000215, blue: 0.9599999785, alpha: 1)
        startButton.layer.shadowRadius = 8
        startButton.layer.shadowOpacity = 0.7
        startButton.layer.masksToBounds = false
        
        statusBGView.layer.shadowPath = UIBezierPath(roundedRect: self.statusBGView.bounds, cornerRadius: self.statusBGView.layer.cornerRadius).cgPath
        statusBGView.layer.shadowColor = UIColor.black.cgColor
        statusBGView.layer.shadowRadius = 12
        statusBGView.layer.shadowOpacity = 0.8
        statusBGView.layer.masksToBounds = false
        
        mapView.layer.shadowPath = UIBezierPath(roundedRect: self.mapView.bounds, cornerRadius: self.mapView.layer.cornerRadius).cgPath
        mapView.layer.shadowColor = UIColor.black.cgColor
        mapView.layer.shadowRadius = 8
        mapView.layer.shadowOpacity = 0.8
        mapView.layer.masksToBounds = false
        
        
        // Round StatusBG
        statusBGView.layer.cornerRadius = 10
        
        // Round Map
        mapView.layer.opacity = 0.80
        mapView.layer.cornerRadius = 16.0
        
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
        timerLabel.layer.cornerRadius = 20.0
        timerLabel.clipsToBounds = true
        dashButton.layer.cornerRadius = buttonRadius
        dashButton.clipsToBounds = true
        flyButton.layer.cornerRadius = buttonRadius
        flyButton.clipsToBounds = true
        predictionTextField.layer.cornerRadius = buttonRadius
        predictionTextField.clipsToBounds = true
        startButton.layer.cornerRadius = 10.0
        
        // Ready Cooldown
        self.timerLabel.text = ""
        
        // Make Error Label
        errorLabel.frame = CGRect(x: mapView.frame.midX - 300, y: self.view.frame.maxY - 69, width: 600, height: 50)
        errorLabel.layer.opacity = 1
        errorLabel.textAlignment = .center
        errorLabel.backgroundColor = .clear
        errorLabel.layer.cornerRadius = 6.0
        errorLabel.clipsToBounds = true
        
        self.view.addSubview(errorLabel)
        errorLabel.textColor = #colorLiteral(red: 0.9486700892, green: 0.9493889213, blue: 0.9487814307, alpha: 1)
        errorLabel.text = "🚫"
        errorLabel.font = UIFont.boldSystemFont(ofSize: 18)
        errorLabel.isHidden = true
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
        
        // If isDashing = true , Make appropriate API Move Call
        if isDashing {
            apiController.dash(direction: direction, roomsPrediction: prediction) { (result) in
                if let room = try? result.get() {
                    self.handleAPIResult(room)
                }
            }
        } else {
            apiController.move(direction: direction, roomPrediction: prediction) { (result) in
                if let room = try? result.get() {
                    self.handleAPIResult(room)
                }
            }
        }
    }
    
    private func initPlayer() {
        self.isPlaying = true
        apiController.initialize { (result) in
            if let room = try? result.get() {
                
                print("Room: \(room)")
                print(room.errors.isEmpty)
                self.handleAPIResult(room)
            }
        }
    }
    
    private func runTimer(_ type: String) {
        
        if type == "status"{
            guard let player = self.player else { fatalError() }
            self.seconds = player.cooldown
        } else {
            self.seconds = self.currentRoom.cooldown
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
    }
    
    func validateMoveAbility(){
        if isTimerRunning {
            upButton.isEnabled = false
            downButton.isEnabled = false
            rightButton.isEnabled = false
            leftButton.isEnabled = false
            startButton.isEnabled = false
        } else {
            upButton.isEnabled = true
            downButton.isEnabled = true
            rightButton.isEnabled = true
            leftButton.isEnabled = true
            startButton.isEnabled = true
        }
    }
    
    @objc func updateTimer() {
        timerLabel.text = "\(Int(seconds))" // May cause issues if automating traversal as casting to int will round the time interval
        timerLabel.textColor = UIColor.black
        if seconds <= 0.0 {
            timerLabel.text = ""
            timer.invalidate()
            self.isTimerRunning = false
            self.errorLabel.isHidden = true
            timerLabel.textColor = UIColor.darkGray
            validateMoveAbility()
        }
        seconds -= 1
    }
    
    private func handleAPIResult(_ room: Room) {
        DispatchQueue.main.async {
            
            self.currentRoom = room
            self.updateUI()
            self.view.setNeedsDisplay()
            self.mapView.apiController = self.apiController
            self.mapView.setNeedsDisplay()
            // Run Cooldown Timer
            self.runTimer("move")
            self.validateMoveAbility()
            
            if room.errors.isEmpty {
                print("Curent Room: \(self.currentRoom)")
            } else {
                self.errorLabel.isHidden = false
                self.errorLabel.text = "🚫🙅‍♂️💩 " + room.errors[0]
                print("Room: \(room)")
                print("Room Error: \(room.errors)")
            }
        }
        
    }
    
    private func updateStatus() {
        apiController.getStatus { (result) in
            if let player = try? result.get() {
                DispatchQueue.main.async {
                    self.player = player
                    // Run Cooldown Timer
                    self.runTimer("status")
                    self.validateMoveAbility()
                    
                    print(player)
                    self.nameLabel.text = player.name
                    self.goldLabel.text = String(player.gold)
                    self.strengthLabel.text = String(player.strength)
                    self.speedLabel.text = String(player.speed)
                    self.encumbranceLabel.text = String(player.encumbrance)
                }
            } else {
                print("No player info?")
                print(result)
            }
        }
    }

}
