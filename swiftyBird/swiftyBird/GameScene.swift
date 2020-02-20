//
//  GameScene.swift
//  swiftyBird
//
//  Created by local192 on 19/02/2020.
//  Copyright © 2020 local192. All rights reserved.
//

import SpriteKit
import GameplayKit

private struct PysicsCategory {
    static let charater: UInt32 = 0x1 << 1
    static let ground: UInt32 = 0x1 << 2
    static let obstacle: UInt32 = 0x1 << 3
    static let score: UInt32 = 0x1 << 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var ground: SKSpriteNode!
    private var bird: SKSpriteNode!
    private var pipes: SKNode!
    private var restartButton: SKSpriteNode!
    private var scoreLabel: SKLabelNode!
    private var pipesMovement: SKAction!
    private var isGameStarted = false
    private var isDead = false
    private var score = 0
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        createScene()
        
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        if firstBody.categoryBitMask == PysicsCategory.charater || secondBody.categoryBitMask == PysicsCategory.charater
        {
            if firstBody.categoryBitMask == PysicsCategory.ground || secondBody.categoryBitMask == PysicsCategory.ground
                || firstBody.categoryBitMask == PysicsCategory.obstacle || secondBody.categoryBitMask == PysicsCategory.obstacle
            {
                
                bird.physicsBody?.isDynamic = false
                enumerateChildNodes(withName: "Pipes", using: ( { (node, error) in
                    node.speed = 0
                    self.removeAllActions()
                }))
                if !isDead {
                    restartButton = SKSpriteNode(imageNamed: "Restart")
                    restartButton.position = CGPoint(x: 0, y: 0)
                    restartButton.zPosition = 5
                    restartButton.setScale(0)
                    
                    restartButton.run(SKAction.scale(to: 1.0, duration: 0.4))
                    self.addChild(restartButton)
                    isDead = true
                }
                
            }else if firstBody.categoryBitMask == PysicsCategory.score || secondBody.categoryBitMask == PysicsCategory.score {
                score+=1
               scoreLabel.text = "\(score)"
            }
            
        }
    }
    
    func createPipes(){
        pipes = SKNode()
        pipes.name = "Pipes"
        let topPipe = SKSpriteNode(imageNamed: "Pipe")
        let bottomPipe = SKSpriteNode(imageNamed: "Pipe")
        
        topPipe.position = CGPoint(x: (self.frame.width / 2) + (topPipe.frame.width / 2), y: 600)
        bottomPipe.position = CGPoint(x: (self.frame.width / 2) + (bottomPipe.frame.width / 2), y: -600)
        
        topPipe.zRotation = CGFloat(Double.pi)
        
        pipes.zPosition = 1
        bird.zPosition = 2
        ground.zPosition = 3
        
        
        
        topPipe.physicsBody = SKPhysicsBody(rectangleOf: topPipe.frame.size)
        topPipe.physicsBody?.categoryBitMask = PysicsCategory.obstacle
        topPipe.physicsBody?.collisionBitMask = PysicsCategory.charater
        topPipe.physicsBody?.contactTestBitMask = PysicsCategory.charater
        topPipe.physicsBody?.affectedByGravity = false
        topPipe.physicsBody?.isDynamic = false
        
        bottomPipe.physicsBody = SKPhysicsBody(rectangleOf: bottomPipe.frame.size)
        bottomPipe.physicsBody?.categoryBitMask = PysicsCategory.obstacle
        bottomPipe.physicsBody?.collisionBitMask = PysicsCategory.charater
        bottomPipe.physicsBody?.contactTestBitMask = PysicsCategory.charater
        bottomPipe.physicsBody?.affectedByGravity = false
        bottomPipe.physicsBody?.isDynamic = false
        
        pipes.addChild(topPipe)
        pipes.addChild(bottomPipe)
        
        //Score node
        let scoreNode = SKSpriteNode()
        scoreNode.size = CGSize(width: 1, height: 200)
        scoreNode.position = CGPoint(x: (self.frame.width / 2) + (bottomPipe.frame.width / 2), y: 0)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = PysicsCategory.score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PysicsCategory.charater
        
//        scoreNode.color = UIColor.blue
        pipes.addChild(scoreNode)
        
        let distance = CGFloat(self.frame.width + pipes.frame.width)
        let movePipes = SKAction.moveBy(x: -distance - 100, y: 0, duration: TimeInterval(0.01 * distance))
        let removePipes = SKAction.removeFromParent()
        pipesMovement = SKAction.sequence([movePipes,removePipes])
        
        let ramdomPosition = CGFloat.random(min: -200, max: 200)
        pipes.position.y = pipes.position.y + ramdomPosition
        
        pipes.run(pipesMovement)
        
        self.addChild(pipes)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isGameStarted {
            isGameStarted = true
            
            let spawnPipes = SKAction.run {
                () in
                self.createPipes()
            }
            let delay = SKAction.wait(forDuration: 2.3)
            let spawnPipesDelay = SKAction.sequence([spawnPipes,delay])
            let spawnForever = SKAction.repeatForever(spawnPipesDelay)
            self.run(spawnForever)
            
            bird.physicsBody?.affectedByGravity = true
            
        }
        if !isDead {
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 30))
        }
        
        for touch in touches {
            let location = touch.location(in: self)
            
            if isDead && restartButton.contains(location)  {
                restartScene()
            }
        }
        
    }
    
    func createScene(){
        
        
        
        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: "Background")
            background.position = CGPoint(x: CGFloat(i)*background.frame.width, y: (background.frame.height / 2) - (self.frame.height / 2))
            background.name = "Background"
            background.zPosition = 0
            self.addChild(background)
        }
        
        ground = SKSpriteNode(imageNamed: "Ground")
        ground.position = CGPoint(x: 0, y: (ground.frame.height/2) - (self.frame.height / 2))
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.categoryBitMask = PysicsCategory.ground
        ground.physicsBody?.collisionBitMask = PysicsCategory.charater
        ground.physicsBody?.contactTestBitMask = PysicsCategory.charater
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.isDynamic = false
        self.addChild(ground)
        
        bird = SKSpriteNode(imageNamed: "Bird")
        bird.size = CGSize(width: 60, height: 40)
        bird.position = CGPoint(x: 0, y: 0)
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.frame.height / 2)
        bird.physicsBody?.categoryBitMask = PysicsCategory.charater
        bird.physicsBody?.collisionBitMask = PysicsCategory.ground | PysicsCategory.obstacle
        bird.physicsBody?.contactTestBitMask = PysicsCategory.ground | PysicsCategory.obstacle | PysicsCategory.score
        bird.physicsBody?.affectedByGravity = false
        bird.physicsBody?.isDynamic = true
        self.addChild(bird)
        
        scoreLabel = SKLabelNode()
        scoreLabel.position = CGPoint(x: 0, y: self.frame.height / 3)
        scoreLabel.zPosition = 4
        scoreLabel.text = "\(score)"
        scoreLabel.fontName = "04b_19"
        scoreLabel.fontColor = UIColor.black
        scoreLabel.fontSize = 90
        self.addChild(scoreLabel)
    }
    
    func restartScene(){
        self.removeAllChildren()
        self.removeAllActions()
        
        isDead = false
        isGameStarted = false
        score = 0
        createScene()
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if isGameStarted && !isDead {
            enumerateChildNodes(withName: "Background", using: ({
                (node,error) in
                if let bg = node as? SKSpriteNode {
                    bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
                    
                    if bg.position.x <= -bg.size.width {
                        bg.position = CGPoint(x: bg.position.x + bg.size.width * 2, y: bg.position.y)
                    }
                }
            }))
        }
    }
}
