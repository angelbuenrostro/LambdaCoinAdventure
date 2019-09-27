//
//  Room.swift
//  LambdaCoinAdventure
//
//  Created by Angel Buenrostro on 9/21/19.
//  Copyright © 2019 Angel Buenrostro. All rights reserved.
//

//Example JSON
//// Starting room
    //{
    //  "room_id": 0,
    //  "title": "Room 0",
    //  "description": "You are standing in an empty room.",
    //  "coordinates": "(60,60)",
    //  "players": [],
    //  "items": ["small treasure"],
    //  "exits": ["n", "s", "e", "w"],
    //  "cooldown": 60.0,
    //  "errors": [],
    //  "messages": []
    //}

import Foundation

struct Room: Codable, Equatable {
    
    let room_id: Int
    let title: String
    let description: String // For now think its just a string.... might not be the case though. Ask Brady
    let coordinates: String 
    let elevation: Int
    let terrain: String
    let players: [String]
    let items:[String]
    let exits: [String]
    let cooldown: Double
    let errors: [String]
    let messages: [String]
}
