//
//  GameViewController.swift
//  Exist
//
//  Created by Daniel Basaldua on 3/22/21.
//

import UIKit
import SpriteKit
import GameplayKit
import os.log

var sizeOfView: CGSize!
var notWhiteColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
var notBlackColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sizeOfView = self.view.frame.size
        gameAchievements()
        
        if let view = self.view as! SKView? {
            if let scene = TitleScene(fileNamed: "TitleScene") {
                scene.scaleMode = .aspectFill
                highScore = scores[0].score
                view.presentScene(scene)
            }
            view.ignoresSiblingOrder = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func gameAchievements() {
        if let savedScores = loadScores() {
            scores += savedScores
        } else {
            loadSampleScores()
        }
    }
    
    private func loadSampleScores() {
        guard let saved1 = SavedGame(name: "Exist", score: 0) else {
            fatalError("Unable to instantiate saved1")
        }
        scores += [saved1]
    }
    
    private func loadScores() -> [SavedGame]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: SavedGame.ArchiveURL.path) as? [SavedGame]
    }
}
