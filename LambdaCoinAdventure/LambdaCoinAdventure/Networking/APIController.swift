//
//  APIController.swift
//  LambdaCoinAdventure
//
//  Created by Angel Buenrostro on 9/21/19.
//  Copyright © 2019 Angel Buenrostro. All rights reserved.
//

import Foundation

enum HTTPHeader: String {
    case authorization = "Authorization"
    case contentType = "Content-Type"
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum NetworkError: Error {
    case noAuth
    case badAuth
    case otherError
    case badData
    case noDecode
}

class APIController {
    
    // Building a map to feed into the MapView
    var mapSet: Set<Coordinates> = []
//    var mapCoordinates:[Coordinates] = []
    var currentCoordinate: Coordinates? = nil
    
    let constants = Constants() // Holds API Key and pre-built URLs
    
    func getStatus(completion: @escaping (Result<Player, NetworkError>) -> Void ) {
        // Make Request
        var request = URLRequest(url: constants.statusURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("Token \(constants.apiKey)", forHTTPHeaderField: HTTPHeader.authorization.rawValue)
        
        // Decode JSON while handling errors
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                completion(.failure(.badAuth))
                return
            }
            
            if let _ = error {
                completion(.failure(.otherError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let player = try decoder.decode(Player.self, from: data)
                completion(.success(player))
            } catch {
                completion(.failure(.noDecode))
            }
        }.resume()
    }
    
    func initialize(completion: @escaping (Result<Room, NetworkError>) -> Void ) {
        // Make Request
        var request = URLRequest(url: constants.initURL)
        request.httpMethod = HTTPMethod.get.rawValue
        request.addValue("Token \(constants.apiKey)", forHTTPHeaderField: HTTPHeader.authorization.rawValue)
        
        // Decode JSON while handling errors
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                completion(.failure(.badAuth))
                return
            }
            
            if let _ = error {
                completion(.failure(.otherError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let room = try decoder.decode(Room.self, from: data)
                self.parseCoordinates(room)
                completion(.success(room))
            } catch {
                completion(.failure(.noDecode))
            }
        }.resume()
    }
    
    func dash(direction: String, roomsPrediction: String, completion: @escaping (Result<Room, NetworkError>) -> Void ) {
        // Get Num of Rooms Dashing from prediction string parsing
        let numRooms = (roomsPrediction.filter { $0 == "," }.count + 1)
        print("Dashing! \(numRooms) body: \(roomsPrediction)")
        
        // Make Request
        var request = URLRequest(url: constants.dashURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("Token \(constants.apiKey)", forHTTPHeaderField: HTTPHeader.authorization.rawValue)
        request.addValue("application/json", forHTTPHeaderField: HTTPHeader.contentType.rawValue)
        let bodyObject: [String:String] = [
            "direction": direction,
            "num_rooms": String(numRooms),
            "next_room_ids": roomsPrediction
        ]
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
        
        // Decode JSON while handling errors
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                completion(.failure(.badAuth))
                return
            }
            
            if let _ = error {
                completion(.failure(.otherError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let room = try decoder.decode(Room.self, from: data)
                self.parseCoordinates(room)
                completion(.success(room))
            } catch {
                completion(.failure(.noDecode))
            }
        }.resume()
    }
    
    
    func move(direction: String, roomPrediction: String?, completion: @escaping (Result<Room, NetworkError>) -> Void ) {
        
        
        // Make Request
        var request = URLRequest(url: constants.moveURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("Token \(constants.apiKey)", forHTTPHeaderField: HTTPHeader.authorization.rawValue)
        request.addValue("application/json", forHTTPHeaderField: HTTPHeader.contentType.rawValue)
        
        var bodyObject: [String: String]
        // JSON Body
        if roomPrediction != nil && roomPrediction != "GUESS?" && roomPrediction != "" {
            guard let roomID = roomPrediction else { print("Nil Room Prediction")
                return
            }
            bodyObject = [
                "direction": direction,
                "next_room_id": roomID
            ]
        } else {
            bodyObject = [
                "direction": direction
            ]
        }
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
        
        // Decode JSON while handling errors
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                completion(.failure(.badAuth))
                return
            }
            
            if let _ = error {
                completion(.failure(.otherError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let room = try decoder.decode(Room.self, from: data)
                self.parseCoordinates(room)
                completion(.success(room))
            } catch {
                completion(.failure(.noDecode))
            }
        }.resume()
    }
    
    
    // MARK: - Put Somewhere Else!
    func parseCoordinates(_ room: Room){
        
        // ID
        let id = room.room_id
        
        // Strip, Split, Cast string coordinates into usable Int values
        var stringCoords = room.coordinates
        stringCoords.removeFirst()
        stringCoords.removeLast()
        let coordArray = stringCoords.split(separator: ",")
        
        // Integer Coordinate Values
        let xValue = Int(coordArray[0])
        let yValue = Int(coordArray[1])
        
        // Array of directional exits
        var exits: [String] = []
        for exit in room.exits {
            exits.append(exit)
        }

        // Boolean flags for special locations
        var isShop: Bool = false
        var isNameChanger: Bool = false
        var isShrine: Bool = false
        var isTransmogrifier: Bool = false
        var isMine: Bool = false
        var isElevated: Bool = false
        
        // TODO: - Replace if else statements with Switch
        if room.title == "Shop"{
            print("room is Shop")
            isShop = true
        } else if room.title == "Name Changer" {
            print("room is Name Changer")
            isNameChanger = true
        } else if room.title == "Shrine" {
            print("room is Shrine")
            isShrine = true
        } else if room.title == "Transmogrifier" {
            print("room is Transmogrifier")
            isTransmogrifier = true
        } else if room.title == "Mine" {
            print("room is Mine")
            isMine = true
        } else if room.description.contains("elevated"){
            print("room is elevated")
            isElevated = true
        }
        
        // MapView readable Coordinate
        let coordinate = Coordinates(id: id, x: xValue!, y: yValue!,
                                     exits: exits, shop: isShop, nameChanger: isNameChanger, shrine: isShrine, transmogrifier: isTransmogrifier, mine: isMine, elevated: isElevated)
        
        self.currentCoordinate = coordinate
        self.mapSet.insert(coordinate)
    }
    
}
