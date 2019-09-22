//
//  Proof.swift
//  LambdaCoinAdventure
//
//  Created by Angel Buenrostro on 9/21/19.
//  Copyright © 2019 Angel Buenrostro. All rights reserved.
//

import Foundation

struct Proof: Decodable {
    let proof: Int
    let difficulty: Int
    let cooldown: Double
    let messages: [String]
    let errors: [String]
}
