//
//  GameScene.swift
//  Project 11
//
//  Created by Aleksandra Sobot on 20.11.23..
//

import SpriteKit
import UIKit


class GameScene: SKScene, SKPhysicsContactDelegate {

    var scoreLabel: SKLabelNode!
    var editLabel: SKLabelNode!
    
    let balls = ["ballRed", "ballBlue", "ballGreen", "ballYellow", "ballCyan", "ballPurple", "ballGrey"]
    
    var numberOfBoxes = 10
    // Challange 3. - We are giving players limit of 5 balls
    var numberOfBalls = 5
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.horizontalAlignmentMode = .left
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let objects = nodes(at: location)
        
        if objects.contains(editLabel) {
            editingMode.toggle()
        } else {
            if editingMode {
                // create a box
                // Challange 3. - making 10 random boxes
               makeRandomBox(number: 10)
            } else {
                // create a ball
                for ball in balls {
                    // Challange 3. - If there is more than 1 ball left, create a ball
                    if numberOfBalls > 0 {
                        // Challange 1. - Picking a random ball color
                        if ball == balls.randomElement() {
                            let newBall = SKSpriteNode(imageNamed: ball)
                            newBall.physicsBody = SKPhysicsBody(circleOfRadius: newBall.size.width / 2.0)
                            newBall.physicsBody?.contactTestBitMask = newBall.physicsBody?.collisionBitMask ?? 0
                            newBall.physicsBody?.restitution = 0.4
                            newBall.name = "ball"
                            // Challange 2. - Creating a ball close to top egde of the screen
                            newBall.position = CGPoint(x: location.x, y: 700)
                            addChild(newBall)
                        }
                    } else {
                        alert()
                    }
                }
            }
        }
    }
    // Challange 3. - creating 10 random boxes
    func makeRandomBox(number: Int) {
        for _ in 1...number {
            let size = CGSize(width: Int.random(in: 16...128), height: 16)
            let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
            box.zRotation = CGFloat.random(in: 0...3)
            box.position = CGPoint(x: CGFloat.random(in: 128...896), y: CGFloat.random(in: 200...568))
            box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
            box.name = "box"
            box.physicsBody?.isDynamic = false
            addChild(box)
        }
    }
    
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotGlow)
        addChild(slotBase)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collision(between ball: SKNode, object: SKNode) {
        if object.name == "good" {
                destroy(ball: ball)
                score += 1
            
            if score >= 10 {
                winAlert()
            }
            
            } else if object.name == "bad" {
                destroy(ball: ball)
                score -= 1
                numberOfBalls -= 1
        }
        // Challange 3. - Player wins if he destroys all boxes
        if object.name == "box" {
            destroy(ball: object)
            numberOfBoxes -= 1
            
            if numberOfBoxes == 0 {
                winAlert()
            }
        }
    }
    
    func destroy(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        ball.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let bodyA = contact.bodyA.node else { return }
        guard let bodyB = contact.bodyB.node else { return }
        
        if bodyA.name == "ball" {
            collision(between: bodyA, object: bodyB)
        } else if bodyB.name == "ball" {
            collision(between: bodyB, object: bodyA)
        }
        
        if bodyA.name == "box" {
            collision(between: bodyA, object: bodyB)
        } else if bodyB.name == "box" {
            collision(between: bodyB, object: bodyA)
        }
    }
    // Challange 3. - Giving player 5 balls, and ending the game when they run out of balls, or when they reach score of 10
    func winAlert() {
        let ac = UIAlertController(title: "GREAT JOB", message: "You win!", preferredStyle: .alert)
        let newGame = UIAlertAction(title: "New Game", style: .default) { [weak self] _ in
            self?.resetGame()
        }
        ac.addAction(newGame)
        ac.addAction(UIAlertAction(title: "Quit", style: .cancel))
        self.view?.window?.rootViewController?.present(ac, animated: true)
    }
    func alert(){
        let ac = UIAlertController(title: "Game Over", message: "OOps...you lost!", preferredStyle: .alert)
        let newGame = UIAlertAction(title: "New Game", style: .default) { [weak self] _ in
            self?.resetGame()
        }
        ac.addAction(newGame)
        ac.addAction(UIAlertAction(title: "Quit", style: .cancel))
        self.view?.window?.rootViewController?.present(ac, animated: true)
    }
    
    func resetGame(){
        numberOfBalls = 5
        score = 0
        for box in children {
            if box.name == "box" {
                box.removeFromParent()
            }
        }
    }
}
