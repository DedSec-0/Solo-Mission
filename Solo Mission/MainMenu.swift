//
//  GameOver.swift
//  Solo Mission
//
//  Created by Administrator on 03/07/2018.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenu : SKScene {
    
    let playLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    override func didMove(to view: SKView) {
        
        let backGround = SKSpriteNode(imageNamed: "background")
        backGround.size = self.size
        backGround.position = CGPoint(x: self.size.width/2, y: self.size.height/2)      //setting center point
        backGround.zPosition = 0
        self.addChild(backGround)
        
        let gameLabel1 = SKLabelNode(fontNamed: "The Bold Font")
        gameLabel1.text = "Space"
        gameLabel1.fontSize = 350
        gameLabel1.fontColor = SKColor.white
        gameLabel1.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.7)
        gameLabel1.zPosition = 2
        self.addChild(gameLabel1)
        
        let gameLabel = SKLabelNode(fontNamed: "The Bold Font")
        gameLabel.text = "Shooter"
        gameLabel.fontSize = 270
        gameLabel.fontColor = SKColor.white
        gameLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.55)
        gameLabel.zPosition = 2
        self.addChild(gameLabel)
        
        playLabel.text = "Play Game"
        playLabel.fontSize = 90
        playLabel.fontColor = SKColor.red
        playLabel.position = CGPoint(x: self.size.width / 2 + 25, y: self.size.height * 0.4)
        playLabel.zPosition = 2
        self.addChild(playLabel)
        
        startEffect()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch : AnyObject in touches {
            let pointOfTouch = touch.location(in: self)
            
            if playLabel.contains(pointOfTouch){
                
                let sceneToMoveTo = GameScene(size: self.size)
                let myTransition = SKTransition.fade(withDuration: 0.5)
                
                sceneToMoveTo.scaleMode = self.scaleMode
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
            }
            
        }
    }
    
    func startEffect(){
        let spawn = SKAction.run(enemiesEffect)
        let waitToSpawn = SKAction.wait(forDuration: 6)
        let spawnSequence = SKAction.sequence([spawn, waitToSpawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever)
    }
    
    func enemiesEffect(){
        
        let maxAspectRatio : CGFloat = 16.0 / 9.0
        let playableWidth = self.size.height / maxAspectRatio
        let margin = (self.size.width - playableWidth) / 2
        let gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: self.size.height)
        
        let X = GameScene.random(min: gameArea.minX, max: gameArea.maxX)
        let Y = GameScene.random(min: gameArea.minX, max: gameArea.maxX)
        let startPoint = CGPoint(x: X, y: self.size.height * 1.2)           // 1.2 shows 20% from top of screen
        let endPoint = CGPoint(x: Y, y: -self.size.height * 1.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.setScale(1)
        enemy.position = startPoint
        enemy.zPosition = 1
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 5)
        let deleteEnemy = SKAction.removeFromParent()
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy])
        enemy.run(enemySequence)
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountRotate = atan2(dy, dx)
        enemy.zRotation = amountRotate
    }
}

