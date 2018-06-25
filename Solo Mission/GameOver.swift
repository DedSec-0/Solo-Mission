//
//  GameOver.swift
//  Solo Mission
//
//  Created by Administrator on 15/06/2018.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation
import SpriteKit

class GameOver : SKScene {
    
    let restartLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    override func didMove(to view: SKView) {
        
        let backGround = SKSpriteNode(imageNamed: "background")
        backGround.size = self.size
        backGround.position = CGPoint(x: self.size.width/2, y: self.size.height/2)      //setting center point
        backGround.zPosition = 0
        self.addChild(backGround)

        let gameOverLabel = SKLabelNode(fontNamed: "The Bold Font")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 200
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.7)
        gameOverLabel.zPosition = 1
        self.addChild(gameOverLabel)

        let gameScore = SKLabelNode(fontNamed: "The Bold Font")
        gameScore.text = "Score: \(Score)"
        gameScore.fontSize = 125
        gameScore.fontColor = SKColor.white
        gameScore.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.55)
        gameScore.zPosition = 1
        self.addChild(gameScore)

        restartLabel.text = "Restart"
        restartLabel.fontSize = 90
        restartLabel.fontColor = SKColor.white
        restartLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.3)
        restartLabel.zPosition = 1
        self.addChild(restartLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch : AnyObject in touches {
            let pointOfTouch = touch.location(in: self)
            
            if restartLabel.contains(pointOfTouch){
                
                let sceneToMoveTo = GameScene(size: self.size)
                let myTransition = SKTransition.fade(withDuration: 0.5)
                
                sceneToMoveTo.scaleMode = self.scaleMode
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
            }
            
        }
    }
}
