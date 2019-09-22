//
//  MainViewController.swift
//  LambdaCoinAdventure
//
//  Created by Angel Buenrostro on 9/22/19.
//  Copyright © 2019 Angel Buenrostro. All rights reserved.
//

import UIKit
import SpriteKit

class MainViewController: UIViewController {
    
    let apiController = APIController()

    @IBOutlet weak var mapView: MapView!
    
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    
    @IBAction func upButtonPressed(_ sender: UIButton) {
        print("north")
        
        apiController.move(direction: "n") { (result) in
            if let room = try? result.get() {
                DispatchQueue.main.async {
                    <#code#>
                }
            }
        }
    }
    @IBAction func rightButtonPressed(_ sender: UIButton) {
        print("east")
        apiController.move(direction: "e", completion: <#T##(Result<Room, NetworkError>) -> Void#>)
    }
    @IBAction func leftButtonPressed(_ sender: UIButton) {
        print("west")
        apiController.move(direction: "w", completion: <#T##(Result<Room, NetworkError>) -> Void#>)
    }
    @IBAction func downButtonPressed(_ sender: UIButton) {
        print("south")
        apiController.move(direction: "s", completion: <#T##(Result<Room, NetworkError>) -> Void#>)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = #colorLiteral(red: 0.07691047341, green: 0.0657993257, blue: 0.1335668266, alpha: 1)
        
        // Do any additional setup after loading the view.
        setupUI()
        
    }
    
    func setupUI(){
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
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
