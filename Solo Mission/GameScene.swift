//
//  GameScene.swift
//  Solo Mission
//
//  Created by Administrator on 12/06/2018.
//  Copyright © 2018 Administrator. All rights reserved.
//

import SpriteKit
import GameplayKit

var Score : Int = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var Lives : Int = 4
    var Level : Int = 0
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    let livesLabel = SKLabelNode(fontNamed: "The Bold Font")
    let levelLabel = SKLabelNode(fontNamed: "The Bold Font")
    let player = SKSpriteNode(imageNamed: "SpaceShip")
    let bulletSound = SKAction.playSoundFileNamed("fire.mp3", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("Explosion.mp3", waitForCompletion: false)
    let gameArea : CGRect
    var EnemySpawnSpeed : TimeInterval = 2
    var EnemyMoveSpeed : TimeInterval = 2
    
    struct PhysicsCategories {
        static let None : UInt32 = 0
        static let Player : UInt32 = 0b1        //1
        static let Bullet : UInt32 = 0b10       //2
        static let Enemy : UInt32 = 0b100       //4
    }

    override init(size: CGSize) {
        let maxAspectRatio : CGFloat = 16.0 / 9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Utility Functions
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    override func didMove(to view: SKView) {
        Score = 0
        Level = 0
        Lives = 3
        self.physicsWorld.contactDelegate = self                                       //for physics body contact
        
        let backGround = SKSpriteNode(imageNamed: "background")
        backGround.size = self.size
        backGround.position = CGPoint(x: self.size.width/2, y: self.size.height/2)      //setting center point
        backGround.zPosition = 0
        self.addChild(backGround)
        
        player.setScale(1)                                                             //size of player ship
        player.position = CGPoint(x: self.size.width/2, y: 0 - player.size.height)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player          //defining Category
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(player)
        
        scoreLabel.text = "Score: 0"                                                //Score Label
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width * 0.15, y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        livesLabel.text = "Lives: \(Lives)"                                                //Score Label
        livesLabel.fontSize = 70
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width * 0.85, y: self.size.height + scoreLabel.frame.size.height)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        presentStart()
        let moveToScreen = SKAction.moveTo(y: self.size.height * 0.9, duration: 0.3)
        let showPlayer = SKAction.moveTo(y: self.size.height * 0.2, duration: 0.3)
        
        scoreLabel.run(moveToScreen)
        livesLabel.run(moveToScreen)
        player.run(showPlayer)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        switch Level {
        case 1:
            fireBullet()
            break
            
        case 2:
            fireBullet(xAxis: gameArea.maxX, xOfRotation: -50)
            fireBullet(xAxis: gameArea.minX, xOfRotation: 50)
            break
        
        case 3:
            fireBullet()
            fireBullet(xAxis: gameArea.maxX, xOfRotation: -50)
            fireBullet(xAxis: gameArea.minX, xOfRotation: 50)
            break
            
        default:
            print("Bullet Fire Error")
            fireBullet()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches{
            
            let pointOfTouch = touch.location(in: self)
            let prevPointOfTouch = touch.previousLocation(in: self)
            let amountDragged = pointOfTouch.x - prevPointOfTouch.x
            
            player.position.x += amountDragged
            if player.position.x > gameArea.maxX - (player.size.width / 2) {
                player.position.x = gameArea.maxX  - (player.size.width / 2)
            }
            if player.position.x < gameArea.minX  + (player.size.width / 2) {
                player.position.x = gameArea.minX  + (player.size.width / 2)
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
        else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        //if Player hit the ship
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy {
            if body1.node != nil {
                spawnExplosion(spawnPosition: body1.node!.position)
            }
            if body2.node != nil {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            gameOver()
        }
        
        //if Bullet hit the ship
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy {
            addScore()
            if body2.node != nil {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
        
    }
    
    func spawnExplosion(spawnPosition: CGPoint){
        let Explosion = SKSpriteNode(imageNamed: "explosion")
        Explosion.position = spawnPosition
        Explosion.zPosition = 3
        self.addChild(Explosion)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
        Explosion.run(explosionSequence)
    }
    
    func addScore(){
        Score += 1
        scoreLabel.text = "Score: \(Score)"
        
        if Score == 1 || Score == 10 {
            self.removeAction(forKey: "spawningEnemies")
            levelLabel.text = "Level Completed"
            levelLabel.fontSize = 100
            levelLabel.fontColor = SKColor.white
            levelLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
            levelLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
            levelLabel.zPosition = 100
            levelLabel.alpha = 0
            self.addChild(levelLabel)
            
            let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
            let waitToAppear = SKAction.wait(forDuration: 2)
            let fadeoutAction = SKAction.fadeOut(withDuration: 0.5)
            let deleteLabel = SKAction.removeFromParent()
            let startNextLevel = SKAction.run(presentStart)
            let startSequence = SKAction.sequence([fadeInAction, waitToAppear, fadeoutAction, deleteLabel, startNextLevel])
            
            levelLabel.run(startSequence)
        }
        else if Score == 30 {
            gameOver()
        }
    }
    func loseLives(){
        Lives -= 1
        livesLabel.text = "Lives: \(Lives)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLabel.run(scaleSequence)
        
        if Lives == 0 {
            gameOver()
        }
    }
    
    func gameOver(){
        
        let sceneToMoveTo = GameOver(size: self.size)
        let myTransition = SKTransition.fade(withDuration: 0.5)
        
        sceneToMoveTo.scaleMode = self.scaleMode
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
    }
    
    func startLevel(){
        
        if self.action(forKey: "spawningEnemies") != nil {
            self.removeAction(forKey: "spawningEnemies")
        }
        
        let spawn = SKAction.run(spawnEnemies)
        let waitToSpawn = SKAction.wait(forDuration: EnemySpawnSpeed)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")
    }
    
    func presentStart(){
        Level += 1
        switch Level {
        case 1:
            EnemySpawnSpeed = 2
            EnemyMoveSpeed = 5
            break
            
        case 2:
            EnemySpawnSpeed = 1.0
            EnemyMoveSpeed = 4
            break
            
        case 3:
            EnemySpawnSpeed = 1.2
            EnemyMoveSpeed = 3
            break
            
        default:
            print("Error")
        }
        
        levelLabel.text = "Level  \(Level)  Start"
        levelLabel.fontSize = 125
        levelLabel.fontColor = SKColor.white
        levelLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        levelLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        levelLabel.zPosition = 100
        levelLabel.alpha = 0
        self.addChild(levelLabel)
        
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        let waitToAppear = SKAction.wait(forDuration: 2)
        let fadeoutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteLabel = SKAction.removeFromParent()
        let startSequence = SKAction.sequence([fadeInAction, waitToAppear, fadeoutAction, deleteLabel])
        
        levelLabel.run(startSequence)
        startLevel()
    }
    
    func fireBullet(){

        let Bullet = SKSpriteNode(imageNamed: "bullet")
        Bullet.name = "Bullett"
        Bullet.setScale(1)
        Bullet.position = player.position
        Bullet.zPosition = 1
        Bullet.physicsBody = SKPhysicsBody(rectangleOf: Bullet.size)
        Bullet.physicsBody!.affectedByGravity = false
        Bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet          //defining Category
        Bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        Bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(Bullet)

        let moveBullet = SKAction.moveTo(y: self.size.height + Bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])
        Bullet.run(bulletSequence)
    }
    
    func fireBullet(xAxis : CGFloat, xOfRotation : CGFloat){
        
        let Bullet = SKSpriteNode(imageNamed: "bullet")
        Bullet.name = "Bullett"
        Bullet.setScale(1)
        Bullet.position = player.position
        Bullet.zPosition = 1
        Bullet.physicsBody = SKPhysicsBody(rectangleOf: Bullet.size)
        Bullet.physicsBody!.affectedByGravity = false
        Bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet          //defining Category
        Bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        Bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(Bullet)
        
        let X = xAxis - player.position.x
        let Y = player.size.height + 200
        let moveBullet = SKAction.moveBy(x: X, y: Y, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])      //sequence is a list of actions runs in order
        Bullet.run(bulletSequence)
        
        let dx = CGFloat(xOfRotation)
        let dy = CGFloat(50)
        let amountRotate = atan2(dy, dx)
        Bullet.zRotation = amountRotate
    }
    
    func spawnEnemies(){
        
        let X = GameScene.random(min: gameArea.minX, max: gameArea.maxX)
        let Y = GameScene.random(min: gameArea.minX, max: gameArea.maxX)
        let startPoint = CGPoint(x: X, y: self.size.height * 1.2)           // 1.2 shows 20% from top of screen
        let endPoint = CGPoint(x: Y, y: -self.size.height * 1.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.name = "Enemy"
        enemy.setScale(1)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy          //defining Category
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: EnemyMoveSpeed)
        let deleteEnemy = SKAction.removeFromParent()
        let loseLiveAction = SKAction.run(loseLives)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseLiveAction])      //sequence is a list of actions runs in order
        enemy.run(enemySequence)

        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountRotate = atan2(dy, dx)
        enemy.zRotation = amountRotate
    }
    
    
    
}
