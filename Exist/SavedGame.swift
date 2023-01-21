//
//  SavedGame.swift
//  Exist
//
//  Created by Daniel Basaldua on 4/18/21.
//

import Foundation
import UIKit
import os.log

class SavedGame: NSObject, NSCoding {
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: PropertyKey.name)
        coder.encode(score, forKey: PropertyKey.score)
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let name = decoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a saved score.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let score = decoder.decodeInteger(forKey: PropertyKey.score)
        
        self.init(name: name, score: score)
    }
    
    var name: String
    var score: Int
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("savedGame")
    
    struct PropertyKey {
        static let name = "name"
        static let score = "score"
    }
    
    init?(name: String, score: Int) {
        guard !name.isEmpty else {
            return nil
        }
        
        self.name = name
        self.score = score
    }
}
