//
//  Examination.swift
//  LambdaCoinAdventure
//
//  Created by Angel Buenrostro on 9/25/19.
//  Copyright © 2019 Angel Buenrostro. All rights reserved.
//

import Foundation

struct Examination: Decodable {
    let room_id: Int?
    let title: String?
    let description: String? // For now think its just a string.... might not be the case though. Ask Brady
    let coordinates: String?
    let elevation: Int?
    let terrain: String?
    let players: [String]?
    let items:[String]?
    let exits: [String]?
    let cooldown: Double?
    let errors: [String]?
    let messages: [String]?
}
