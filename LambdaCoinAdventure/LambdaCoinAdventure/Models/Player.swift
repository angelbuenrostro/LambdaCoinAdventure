//
//  Player.swift
//  LambdaCoinAdventure
//
//  Created by Angel Buenrostro on 9/24/19.
//  Copyright © 2019 Angel Buenrostro. All rights reserved.
//

import Foundation

struct Player: Decodable {
    
    let name: String
    let cooldown: Double
    let encumbrance: Int
    let strength: Int
    let gold: Int
    let inventory: [String] // Need to confirm type with Brady
    let status: [String]
    let has_mined: Bool
    let errors: [String]
    let messages: [String]
    
}
