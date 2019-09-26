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
    case wrongType
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
    
    func treasure(action: String, treasureName: String, completion: @escaping (Error?) -> ()) {
        var request: URLRequest?
        if action == "take"{
            request = URLRequest(url: constants.treasureTakeURL)
        } else {
            request = URLRequest(url: constants.treasureDropURL)
        }
        guard var treasureRequest = request else { fatalError("Could not make treasure request URL") }
        treasureRequest.httpMethod = HTTPMethod.post.rawValue
        treasureRequest.addValue("Token \(constants.apiKey)", forHTTPHeaderField: HTTPHeader.authorization.rawValue)
        treasureRequest.addValue("application/json", forHTTPHeaderField: HTTPHeader.contentType.rawValue)
        let bodyObject: [String:String] = [
            "name":"\(treasureName)"
        ]
        treasureRequest.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
        
        // Send Request
        URLSession.shared.dataTask(with: treasureRequest) { (_, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    func sellTreasure(treasureName: String, confirm: String, completion: @escaping (Result<Room, NetworkError>) -> Void) {
        var request = URLRequest(url: constants.treasureSellURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("Token \(constants.apiKey)", forHTTPHeaderField: HTTPHeader.authorization.rawValue)
        request.addValue("application/json", forHTTPHeaderField: HTTPHeader.contentType.rawValue)
        var bodyObject: [String: String] = [:]
        if confirm == "yes" {
            bodyObject = [
                "name":"\(treasureName)",
                "confirm":"yes"
            ]
        } else {
            bodyObject = [
                "name":"\(treasureName)"
            ]
        }
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
        
        // Send Request
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
    
    
    func nameChange(name: String, completion: @escaping (Error?) -> ()) {
        var request = URLRequest(url: constants.nameChangeURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("Token \(constants.apiKey)", forHTTPHeaderField: HTTPHeader.authorization.rawValue)
        request.addValue("application/json", forHTTPHeaderField: HTTPHeader.contentType.rawValue)
        let bodyObject: [String:String] = [
            "name": name
        ]
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
        
        // Send Request
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    func pray(completion: @escaping(Error?)-> ()) {
        var request = URLRequest(url: constants.prayURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("Token \(constants.apiKey)", forHTTPHeaderField: HTTPHeader.authorization.rawValue)
        request.addValue("application/json", forHTTPHeaderField: HTTPHeader.contentType.rawValue)
        
        // Send Request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    func proof(completion: @escaping(Result<Proof, NetworkError>) -> Void ){
        var request = URLRequest(url: constants.proofURL)
            request.httpMethod = HTTPMethod.post.rawValue
            request.addValue("Token \(constants.apiKey)", forHTTPHeaderField: HTTPHeader.authorization.rawValue)
            request.addValue("application/json", forHTTPHeaderField: HTTPHeader.contentType.rawValue)
            
            // Send Request
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
                        let proof = try decoder.decode(Proof.self, from: data)
                        completion(.success(proof))
                    } catch {
                        completion(.failure(.noDecode))
                    }
                }.resume()
            }
    
    func mine(proposedProof: Int, completion: @escaping(Result<Room, NetworkError>) -> Void ) {
        var request = URLRequest(url: constants.coinMineURL)
            request.httpMethod = HTTPMethod.post.rawValue
            request.addValue("Token \(constants.apiKey)", forHTTPHeaderField: HTTPHeader.authorization.rawValue)
            request.addValue("application/json", forHTTPHeaderField: HTTPHeader.contentType.rawValue)
            let bodyObject: [String:Int] = [
                "proof": proposedProof
            ]
            request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
            
//            print(request)
//            print(bodyObject)
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
                    completion(.success(room))
                } catch {
                        completion(.failure(.noDecode))
                    }
            }.resume()
    }
    
    func wear(itemName: String, completion: @escaping(Error?)-> ()) {
        var request = URLRequest(url: constants.wearURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("Token \(constants.apiKey)", forHTTPHeaderField: HTTPHeader.authorization.rawValue)
        request.addValue("application/json", forHTTPHeaderField: HTTPHeader.contentType.rawValue)
        
        let bodyObject: [String:String] = [
            "name": itemName
        ]
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
        
        // Send Request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    func balance(completion: @escaping(Result<Examination, NetworkError>) -> Void) {
        var request = URLRequest(url: constants.balanceURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("Token \(constants.apiKey)", forHTTPHeaderField: HTTPHeader.authorization.rawValue)
        request.addValue("application/json", forHTTPHeaderField: HTTPHeader.contentType.rawValue)
        
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
                let balance = try decoder.decode(Examination.self, from: data)
                completion(.success(balance))
            } catch {
                    completion(.failure(.noDecode))
                }
        }.resume()
    }
    
    func ghostCourier(action: String, itemName: String, completion: @escaping(Result<Room, NetworkError>) -> Void ) {
        var request = URLRequest(url: constants.ghostCarryURL)
        
        if action == "give" {
            request.url = constants.ghostCarryURL
        } else {
            request.url = constants.ghostReceiveURL
        }
            request.httpMethod = HTTPMethod.post.rawValue
            request.addValue("Token \(constants.apiKey)", forHTTPHeaderField: HTTPHeader.authorization.rawValue)
            request.addValue("application/json", forHTTPHeaderField: HTTPHeader.contentType.rawValue)
        
        if action == "give" {
            let bodyObject: [String:String] = [
                "name": itemName
            ]
            request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
        }
            
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
                    completion(.success(room))
                } catch {
                        completion(.failure(.noDecode))
                    }
            }.resume()
    }
    
    func examine(name: String, completion: @escaping(Result<Examination, NetworkError>) -> Void) {
        var request = URLRequest(url: constants.examineURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("Token \(constants.apiKey)", forHTTPHeaderField: HTTPHeader.authorization.rawValue)
        request.addValue("application/json", forHTTPHeaderField: HTTPHeader.contentType.rawValue)
        let bodyObject: [String:String] = [
            "name": name
        ]
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
        
//        print(request)
//        print(bodyObject)
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
                let examination = try decoder.decode(Examination.self, from: data)
                completion(.success(examination))
            } catch {
                    completion(.failure(.noDecode))
                }
        }.resume()
    }
    
    func dash(direction: String, roomsPrediction: String, completion: @escaping (Result<Room, NetworkError>) -> Void ) {
        // Get Num of Rooms Dashing from prediction string parsing
        let numRooms = (roomsPrediction.filter { $0 == "," }.count + 1)
//        print("Dashing! \(numRooms) body: \(roomsPrediction)")
        
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
        var isTrap: Bool = false
        
        // TODO: - Replace if else statements with Switch
        if room.title == "Shop"{
//            print("room is Shop")
            isShop = true
        } else if room.title.contains("Pirate") {
//            print("room is Name Changer")
            isNameChanger = true
        } else if room.description.contains("prayer") || room.description.contains("pray") || room.title.contains("Shrine") || room.description.contains("shrine"){
//            print("room is Shrine")
            isShrine = true
        } else if room.description.contains("machine") {
//            print("room is Transmogrifier")
            isTransmogrifier = true
        } else if room.title == "Mine" {
//            print("room is Mine")
            isMine = true
        } else if room.elevation > 0{
//            print("room is elevated")
            isElevated = true
        } else if room.messages.count > 1 {
            for msg in room.messages {
                if msg.contains("trap") || msg.contains("trap!:"){
                    isTrap = true
                }
            }
        }
        
        // MapView readable Coordinate
        let coordinate = Coordinates(id: id, x: xValue!, y: yValue!,
                                     exits: exits, shop: isShop, nameChanger: isNameChanger, shrine: isShrine, transmogrifier: isTransmogrifier, mine: isMine, elevated: isElevated, trap: isTrap)
        
        self.currentCoordinate = coordinate
        self.mapSet.insert(coordinate)
    }
    
}
