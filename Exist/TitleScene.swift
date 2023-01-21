//
//  TitleScene.swift
//  Exist
//
//  Created by Daniel Basaldua on 4/17/21.
//
import UIKit
import Foundation
import SpriteKit
import os.log

var highScore: Int = 0
var scores = [SavedGame]()

class TitleScene: SKScene {
    var btnPlay: UIButton!
    var btnReset: UIButton!
    var shareBtn: UIButton!
    var achievmentTitle: UILabel!
    //stop
    //stop
    //stop
    var gameTitle = SKLabelNode()
    var gameFAQs = SKLabelNode()
    var gameFAQ1 = SKLabelNode()
    
    override func didMove(to view: SKView) {
        self.backgroundColor = notBlackColor
        setUpText()
    }
    
    @objc func playTheGame() {
        self.view?.presentScene(GameScene(), transition: SKTransition.fade(withDuration: 1.00))
        
        btnPlay.removeFromSuperview()
        btnPlay.removeFromSuperview()
        btnReset.removeFromSuperview()
        achievmentTitle.removeFromSuperview()
        shareBtn.removeFromSuperview()
        
        gameTitle.removeFromParent()
        gameFAQs.removeFromParent()
        gameFAQ1.removeFromParent()
        
        if let scene = GameScene(fileNamed: "GameScene") {
            let skView = self.view! as SKView
            skView.ignoresSiblingOrder = true
            scene.scaleMode = .aspectFill
            skView.presentScene(scene)
        }
    }
    
    @objc func resetTheGame() {
        scores[0].score = 0
        highScore = 0
        achievmentTitle.text = "High Score : \(highScore)"
        //shareBtn.setTitle("High Score : \(highScore)", for: .normal) //if button
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(scores, toFile: SavedGame.ArchiveURL.path)
        
        if isSuccessfulSave {
            os_log("High Score successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save high score...",  log: OSLog.default, type: .error)
        }
    }
    
    func setUpText() {
        let scaleYPosition = sizeOfView.height
        let btnSize: CGFloat = view!.frame.size.width/3.8
        
        gameTitle = SKLabelNode(fontNamed: "Marker Felt")
        gameTitle.fontColor = notWhiteColor
        gameTitle.fontSize = scaleYPosition/9
        gameTitle.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - scaleYPosition/4)
        
        gameTitle.text = "Exist!"
        self.addChild(gameTitle)
        
        gameFAQs = SKLabelNode(fontNamed: "Marker Felt")
        gameFAQs.fontColor = notWhiteColor
        gameFAQs.fontSize = scaleYPosition/40
        gameFAQs.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - scaleYPosition/3.5)
        gameFAQs.text = "---Avoid bombs and collect orbs for more points---"
        self.addChild(gameFAQs)
        
        gameFAQ1 = SKLabelNode(fontNamed: "Marker Felt")
        gameFAQ1.fontColor = notWhiteColor
        gameFAQ1.fontSize = scaleYPosition/40
        gameFAQ1.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - scaleYPosition/3)
        gameFAQ1.text = "---Exist for as long as possible---"
        self.addChild(gameFAQ1)
        
        spawnPlayer()
        
        //PLAY BUTTON with image
        btnPlay = UIButton(frame: CGRect(x: 0, y: 0, width: btnSize, height: btnSize/2))
        btnPlay.backgroundColor = notBlackColor
        //left center
        btnPlay.center = CGPoint(x: sizeOfView.width/2, y: sizeOfView.height/2 + 250)
        btnPlay.setImage(UIImage(named: "playExistButton"), for: UIControl.State.normal)
        btnPlay.addTarget(self, action: (#selector(TitleScene.playTheGame)), for: UIControl.Event.touchUpInside)
        self.view?.addSubview(btnPlay)
        
        //HIGH SCORE
        
        achievmentTitle = UILabel(frame: CGRect(x: self.frame.midX + 20, y: scaleYPosition/1.18, width: sizeOfView.width - btnSize, height: 100))
        achievmentTitle.textColor = notWhiteColor
        achievmentTitle.font = UIFont(name: "Marker Felt", size: scaleYPosition/20)
        achievmentTitle.textAlignment = NSTextAlignment.center
        achievmentTitle.text = "High Score : \(highScore)"
        self.view?.addSubview(achievmentTitle)
         
        //buttton option
        //stop
        shareBtn = UIButton(frame: CGRect(x: 0, y: 0, width: (sizeOfView.width - btnSize) / 2, height: 50))
        shareBtn.center = CGPoint(x: achievmentTitle.center.x, y: achievmentTitle.center.y + 75)
        //shareBtn.setTitleColor(notWhiteColor, for: .normal)
        //shareBtn.backgroundColor = .black
        //shareBtn.setTitle("Copy High Score", for: .normal)
        //shareBtn.titleLabel?.font = UIFont(name: "Marker Felt", size: 20)
        shareBtn.setImage(UIImage(named: "copyHighScoreExistButtonLong"), for: UIControl.State.normal)
        shareBtn.addTarget(self, action: (#selector(TitleScene.copyHighScore)), for: UIControl.Event.touchUpInside)
        self.view?.addSubview(shareBtn)
        
        //RESET HIGH SCORE
        btnReset = UIButton(frame: CGRect(x: 0, y: 0, width: btnSize/1.5, height: btnSize/1.5))
        btnReset.backgroundColor = notBlackColor
        btnReset.center = CGPoint(x: achievmentTitle.frame.maxX, y: achievmentTitle.frame.midY)
        btnReset.setImage(UIImage(named: "resetExistButton"), for: UIControl.State.normal)
        btnReset.addTarget(self, action: (#selector(TitleScene.resetTheGame)), for: UIControl.Event.touchUpInside)
        self.view?.addSubview(btnReset)
    }
    
    func spawnPlayer() {
        player = SKSpriteNode(imageNamed: "playerWhite")
        player?.size = CGSize(width: 400, height: 400)
        player?.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        player?.isHidden = false
        self.addChild(player!)
    }
    
    @objc func copyHighScore() {
        let text = "My high score for Exist is: \(highScore)"
        UIPasteboard.general.string = String(text)
        let UIAlert = UIAlertController(title: "Success!", message: "Your high score was successfully saved to your clipboard", preferredStyle: .alert)
        UIAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            UIAlert.dismiss(animated: true, completion: nil)
        }))
        UIAlert.popoverPresentationController?.sourceView = self.view
        self.view?.window?.rootViewController?.present(UIAlert, animated: true)
        
        //var topScore = highScore
        //let shareSheetAC = UIActivityViewController(activityItems: [topScore], applicationActivities: nil)
        //shareSheetAC.popoverPresentationController?.sourceView = self.view
        //self.view?.window?.rootViewController?.present(shareSheetAC, animated: true)
        
    }

}

