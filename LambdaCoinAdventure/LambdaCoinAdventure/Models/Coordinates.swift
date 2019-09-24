//
//  Coordinates.swift
//  LambdaCoinAdventure
//
//  Created by Angel Buenrostro on 9/22/19.
//  Copyright © 2019 Angel Buenrostro. All rights reserved.
//

import Foundation

struct Coordinates: Equatable, Hashable {
    let id: Int
    let x: Int
    let y: Int
    let exits: [String]
    let shop: Bool
    let nameChanger: Bool
    let shrine: Bool
    let transmogrifier: Bool
    let mine: Bool
    let elevated: Bool
}
