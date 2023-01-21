//
//  GameScene.swift
//  Exist
//
//  Created by Daniel Basaldua on 3/22/21.
//

import SpriteKit
import GameplayKit
import os.log

var player: SKSpriteNode?

class GameScene: SKScene, SKPhysicsContactDelegate {
    var collectable: SKSpriteNode?
    var collectableSpeed = 1.5
    var collectableTimerSpawn = 4.0
    var bomb: SKSpriteNode?
    var bombSpeed = 1.5
    var bombTimerSpawn = 0.8
    
    var statusLabel : SKLabelNode?
    var scoreLabel : SKLabelNode?
    var hideLabel = true
    
    var touchLocation: CGPoint?
    
    var isAlive = true
    
    var collectablesCollected = 0
    var score = 0
    
    var level = 0 //used to determine difficulty of the game
    
    var btnPlayAgain: UIButton! = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 300)) //---------------------
    var btnQuit: UIButton! = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 200)) //---------------------
    
    //---------------------
    func spawnPlayAgainBtn() {
        btnPlayAgain.backgroundColor = notBlackColor
        btnPlayAgain.center = CGPoint(x: sizeOfView.width/2, y: sizeOfView.height/2 - 150)
        btnPlayAgain.setImage(UIImage(named: "playExistAgainButton"), for: UIControl.State.normal)
        btnPlayAgain.addTarget(self, action: (#selector(GameScene.resetTheGame)), for: UIControl.Event.touchUpInside)
        btnPlayAgain.isHidden = false
        self.view?.addSubview(btnPlayAgain)
    }
    
    func spawnQuitBtn() {
        btnQuit.backgroundColor = notBlackColor
        btnQuit.center = CGPoint(x: sizeOfView.width/2, y: sizeOfView.height/2 + 150)
        btnQuit.setImage(UIImage(named: "quitExistButton"), for: UIControl.State.normal)
        btnQuit.addTarget(self, action: (#selector(GameScene.waitThenMoveToTitleScene)), for: UIControl.Event.touchUpInside)
        btnQuit.isHidden = false
        self.view?.addSubview(btnQuit)
    }
    //---------------------
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        self.backgroundColor = notBlackColor
        
        resetVariablesOnStart()
        spawnPlayer()
        spawnBomb()
        bombSpawnTimer()
        spawnCollectable()
        collectableSpawnTimer()
        spawnStatusLabel()
        spawnScoreLabel()
        hideStatusLabel()
        addToScore()
    }
    
    func resetVariablesOnStart() {
        hideLabel = true
        score = 0
        level = 0
        collectablesCollected = 0
        isAlive = true
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchLocation = touch.location(in: self)
            if isAlive {
                player?.position.x = (touchLocation?.x)!
                player?.position.y = (touchLocation?.y)!
            } else if !isAlive {
                player?.position.x = -1000
            }
        }
    }
    
    struct physicsCategory {
        static let player : UInt32 = 1
        static let bomb : UInt32 = 2
        static let collectable : UInt32 = 3
    }
    
    func spawnPlayer() {
        player = SKSpriteNode(imageNamed: "playerWhite")
        player?.size = CGSize(width: 65, height: 65)
        player?.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        player?.physicsBody = SKPhysicsBody(rectangleOf: player!.size)
        player?.physicsBody?.affectedByGravity = false
        player?.physicsBody?.isDynamic = false
        player?.physicsBody?.allowsRotation = false
        player?.physicsBody?.categoryBitMask = physicsCategory.player
        player?.physicsBody?.contactTestBitMask = physicsCategory.bomb
        player?.name = "player"
        self.addChild(player!)
    }
    
    func bombSpawnTimer() {
        let bombTimer = SKAction.wait(forDuration: bombTimerSpawn)
        let spawn = SKAction.run {
            self.spawnBomb()
        }
        let sequence = SKAction.sequence([bombTimer, spawn])
        self.run(SKAction.repeatForever(sequence))
    }
    
    func spawnBomb() {
        bomb = SKSpriteNode(imageNamed: "bomb")
        bomb?.size = CGSize(width: 80, height: 80)
        bomb?.physicsBody = SKPhysicsBody(rectangleOf: bomb!.size)
        bomb?.physicsBody?.affectedByGravity = false
        bomb?.physicsBody?.isDynamic = true
        bomb?.physicsBody?.allowsRotation = true
        
        bomb?.physicsBody?.categoryBitMask = physicsCategory.bomb
        bomb?.physicsBody?.contactTestBitMask = physicsCategory.player
        bomb?.name = "bomb"
        
        let direction = Int.random(in: 1...112)
        bombSpeed = Double.random(in: 1.2...3.0)
        let leftRightRange = leftRightX()
        let upDownRange = upDownY()
        var moveForward = SKAction.moveTo(y: self.frame.minY/2-200, duration: bombSpeed)
        switch direction {
        case 1..<15, 57..<71: //bottom
                bomb?.position = CGPoint(x: Int(arc4random_uniform(50)) + leftRightRange, y: -600)
                moveForward = SKAction.moveTo(y: self.frame.maxY/2+200, duration: bombSpeed)
        case 15..<29, 71..<85: //right
                bomb?.position = CGPoint(x: 600, y: Int(arc4random_uniform(50)) + upDownRange)
                moveForward = SKAction.moveTo(x: self.frame.minX/2-200, duration: bombSpeed)
        case 29..<43, 85..<99: //left
                bomb?.position = CGPoint(x: -600, y: Int(arc4random_uniform(50)) + upDownRange)
                moveForward = SKAction.moveTo(x: self.frame.maxX/2+200, duration: bombSpeed)
            default: //top
                bomb?.position = CGPoint(x: Int(arc4random_uniform(50)) + leftRightRange, y: 600)
        }
        
        let destroy = SKAction.removeFromParent()
        bomb?.run(SKAction.sequence([moveForward, destroy]))
        self.addChild(bomb!)
    }
    
    func leftRightX() -> Int{
        var leftRightRange = Int(arc4random_uniform(UInt32(self.frame.maxX*2)))
        if leftRightRange < Int(self.frame.maxX) {
            leftRightRange *= -1
        } else {
            leftRightRange -= Int(self.frame.maxX)
        }
        return leftRightRange
    }
    
    func upDownY() -> Int{
        var upDownRange = Int(arc4random_uniform(UInt32(self.frame.maxY*2)))
        if upDownRange < Int(self.frame.maxY) {
            upDownRange *= -1
        } else {
            upDownRange -= Int(self.frame.maxY)
        }
        return upDownRange
    }
    
    func spawnCollectable() {
        collectable = SKSpriteNode(imageNamed: "collectableWhite")
        
        collectable?.size = CGSize(width: 45, height: 45)
        collectable?.physicsBody = SKPhysicsBody(rectangleOf: collectable!.size)
        collectable?.physicsBody?.affectedByGravity = false
        collectable?.physicsBody?.isDynamic = true
        collectable?.physicsBody?.allowsRotation = false
        collectable?.physicsBody?.categoryBitMask = physicsCategory.collectable
        collectable?.physicsBody?.contactTestBitMask = physicsCategory.player
        collectable?.name = "collectable"
        
        let direction = Int.random(in: 1...112)
        collectableSpeed = Double.random(in: 2.0...3.0)
        let leftRightRange = leftRightX()
        let upDownRange = upDownY()
        var moveForward = SKAction.moveTo(y: self.frame.minY/2-200, duration: collectableSpeed)
        switch direction {
        case 1..<15, 57..<71: //bottom
            collectable?.position = CGPoint(x: Int(arc4random_uniform(50)) + leftRightRange, y: -600)
                moveForward = SKAction.moveTo(y: self.frame.maxY/2+200, duration: collectableSpeed)
        case 15..<29, 71..<85: //right
            collectable?.position = CGPoint(x: 600, y: Int(arc4random_uniform(50)) + upDownRange)
                moveForward = SKAction.moveTo(x: self.frame.minX/2-200, duration: collectableSpeed)
        case 29..<43, 85..<99: //left
            collectable?.position = CGPoint(x: -600, y: Int(arc4random_uniform(50)) + upDownRange)
                moveForward = SKAction.moveTo(x: self.frame.maxX/2+200, duration: collectableSpeed)
            default: //top
                collectable?.position = CGPoint(x: Int(arc4random_uniform(50)) + leftRightRange, y: 600)
        }
        
        let destroy = SKAction.removeFromParent()
        collectable?.run(SKAction.sequence([moveForward, destroy]))
        self.addChild(collectable!)
    }
    
    func collectableSpawnTimer() {
        let collectableTimer = SKAction.wait(forDuration: collectableTimerSpawn)
        let spawn = SKAction.run {
            self.spawnCollectable()
        }
        let sequence = SKAction.sequence([collectableTimer, spawn])
        self.run(SKAction.repeatForever(sequence))
    }
    
    func bombPlayerCollision(bombTemp: SKSpriteNode, playerTemp: SKSpriteNode) {
        bombTemp.removeFromParent()
        playerTemp.removeFromParent()
        isAlive = false
        
        gameOver()
    }
    
    func collectablePlayerCollision(collectableTemp: SKSpriteNode) {
        collectableTemp.removeFromParent()
        collectablesCollected += 1
        score += collectablesCollected
        updateScore()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody : SKPhysicsBody = contact.bodyA
        let secondBody : SKPhysicsBody = contact.bodyB
        
        if ((firstBody.categoryBitMask == physicsCategory.player) && (secondBody.categoryBitMask == physicsCategory.bomb)) {
            spawnSmoke(playerTemp: firstBody.node as! SKSpriteNode)
            bombPlayerCollision(bombTemp: firstBody.node as! SKSpriteNode, playerTemp: secondBody.node as! SKSpriteNode)
        }
        if ((firstBody.categoryBitMask == physicsCategory.bomb) && (secondBody.categoryBitMask == physicsCategory.player)) {
            spawnSmoke(playerTemp: firstBody.node as! SKSpriteNode)
            bombPlayerCollision(bombTemp: firstBody.node as! SKSpriteNode, playerTemp: secondBody.node as! SKSpriteNode)
        }
        
        if ((firstBody.categoryBitMask == physicsCategory.player) && (secondBody.categoryBitMask == physicsCategory.collectable)) {
            spawnBling(playerTemp: firstBody.node as! SKSpriteNode)
            collectablePlayerCollision(collectableTemp: secondBody.node as! SKSpriteNode)
        }
        if ((firstBody.categoryBitMask == physicsCategory.collectable) && (secondBody.categoryBitMask == physicsCategory.player)) {
            spawnBling(playerTemp: firstBody.node as! SKSpriteNode)
            collectablePlayerCollision(collectableTemp: firstBody.node as! SKSpriteNode)
        }
    }
    
    func spawnSmoke(playerTemp: SKSpriteNode) {
        let explosion = newSmokeParticle()!
        
        explosion.position = CGPoint(x: playerTemp.position.x, y: playerTemp.position.y)
        explosion.zPosition = 1
        explosion.targetNode = self
        
        self.addChild(explosion)
        let explosionTimerRemove = SKAction.wait(forDuration: 1.0)
        
        let removeExplosion = SKAction.run {
            explosion.removeFromParent()
        }
        self.run(SKAction.sequence([explosionTimerRemove, removeExplosion]))
    }
    
    func newSmokeParticle() -> SKEmitterNode? {
        return SKEmitterNode(fileNamed: "SmokeParticle.sks")
    }
    
    func spawnBling(playerTemp: SKSpriteNode) {
        let bling = newBlingParticle()!
        
        bling.position = CGPoint(x: playerTemp.position.x, y: playerTemp.position.y)
        bling.zPosition = 1
        bling.targetNode = self
        
        self.addChild(bling)
        let explosionTimerRemove = SKAction.wait(forDuration: 0.5)
        
        let removeExplosion = SKAction.run {
            bling.removeFromParent()
        }
        self.run(SKAction.sequence([explosionTimerRemove, removeExplosion]))
    }
    
    func newBlingParticle() -> SKEmitterNode? {
        return SKEmitterNode(fileNamed: "BlingParticle.sks")
    }
    
    func spawnStatusLabel() {
        statusLabel = SKLabelNode(fontNamed: "Rockwell")
        statusLabel?.fontSize = 100
        statusLabel?.fontColor = UIColor.white
        statusLabel?.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 350)
        statusLabel?.text = "Exist!"
        self.addChild(statusLabel!)
    }
    
    func spawnScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Rockwell")
        scoreLabel?.fontSize = 60
        scoreLabel?.fontColor = UIColor.green
        scoreLabel?.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 200)
        scoreLabel?.text = "Score: 0"
        self.addChild(scoreLabel!)
    }
    
    func hideStatusLabel() {
        let wait = SKAction.wait(forDuration: 2.0)
        let hideIt = SKAction.run {
            if self.hideLabel {
                self.statusLabel?.alpha = 0.0
            }
        }
        let sequence = SKAction.sequence([wait, hideIt])
        self.run(SKAction.repeat(sequence, count: 1))
    }
    
    func updateScore() {
        scoreLabel?.text = "Score: \(score)"
        if score >= 15 && level == 0 {
            scoreLabel?.fontColor = UIColor.yellow
            bombSpawnTimer()
            level += 1
        } else if score >= 30 && level == 1 {
            scoreLabel?.fontColor = UIColor.blue
            bombSpawnTimer()
            level += 1
        } else if score >= 50 && level == 2 {
            scoreLabel?.fontColor = UIColor.red
            bombSpawnTimer()
            level += 1
        } else if score >= 100 && level == 3 {
            scoreLabel?.fontColor = UIColor.black
            bombSpawnTimer()
            level += 1
        }
    }
    
    func addToScore() {
        //add to the score every second the player stays alive
        let timerInterval = SKAction.wait(forDuration: 1.0)
        let addAndUpdateScore = SKAction.run {
            if self.isAlive {
                self.score += 1
                self.updateScore()
            }
        }
        let sequence = SKAction.sequence([timerInterval, addAndUpdateScore])
        self.run(SKAction.repeatForever(sequence))
    }
    
    func gameOver() {
        hideLabel = false
        statusLabel?.alpha = 1.0
        statusLabel?.fontSize = 50
        statusLabel?.fontColor = notWhiteColor
        statusLabel?.text = "Good Score!"
        
        if score > highScore {
            highScore = score
            statusLabel?.fontColor = UIColor.green
            statusLabel?.text = "New High Score! \(highScore)"
            saveScores()
        } else if !isAlive {
            statusLabel?.fontColor = UIColor.red
            statusLabel?.text = "Game Over"
        }
        spawnPlayAgainBtn()
        spawnQuitBtn()
    }
    
    
    @objc func resetTheGame() {
        btnPlayAgain.isHidden = true
        btnPlayAgain.removeFromSuperview()
        btnQuit.removeFromSuperview()
        self.view?.presentScene(GameScene(), transition: SKTransition.fade(withDuration: 1.00))
        
        bomb?.removeFromParent()
        player?.removeFromParent()
        collectable?.removeFromParent()
        
        if let scene = GameScene(fileNamed: "GameScene") {
            let skView = self.view! as SKView
            skView.ignoresSiblingOrder = true
            scene.scaleMode = .aspectFill
            skView.presentScene(scene)
        }
    }
 
    
    @objc func waitThenMoveToTitleScene() {
        btnQuit.isHidden = true
        btnQuit.removeFromSuperview()
        btnPlayAgain.removeFromSuperview()
        let wait = SKAction.wait(forDuration: 0.5)
        let transition = SKAction.run {
            if let scene = TitleScene(fileNamed: "TitleScene") {
                let skView = self.view! as SKView
                scene.scaleMode = .aspectFill
                skView.presentScene(scene)
            }
        }
        
        let sequence = SKAction.sequence([wait, transition])
        self.run(SKAction.repeat(sequence, count: 1))
    }
    
    private func saveScores() {
        scores[0].score = highScore
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(scores, toFile: SavedGame.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("High score successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save high score", log: OSLog.default, type: .error)
        }
    }
}
