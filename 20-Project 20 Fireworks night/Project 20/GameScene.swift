//
//  GameScene.swift
//  Project 20
//
//  Created by Aleksandra Sobot on 26.1.24..
//

import SpriteKit


class GameScene: SKScene {
    
    var gameTimer: Timer?
    var fireworks = [SKNode]()
    var scoreLabel: SKLabelNode!
    
    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22
    
    // Challange 2
    var numberOfLaunches = 0
    
    // Challange 1
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
        // Challange 1
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        score = 0
    }
    
    func createFireworks(xMovement: CGFloat, x: Int, y: Int) {
        // creates a container
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        // creates firework
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1
        firework.name = "firework"
        node.addChild(firework)
        
        // gives firework random color
        switch Int.random(in: 0...2) {
        case 0:
            firework.color = .cyan
        case 1:
            firework.color = .green
        case 2:
            firework.color = .red
        default:
            break
        }
        
        //gives firework a path
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        
        // gives firework action
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        node.run(move)
        
        //gives firework emiter (particle) behind it
        if let emitter = SKEmitterNode(fileNamed: "fuse") {
            emitter.position = CGPoint(x: 0, y: -22)
            node.addChild(emitter)
        }
        // adds firework to Firework array and adds firework to the scene
        fireworks.append(node)
        addChild(node)
    }
    
    @objc func launchFireworks() {
        
        let movementAmount: CGFloat = 1800
        // Challange 2
        numberOfLaunches += 1
        
        switch Int.random(in: 0...3) {
        case 0:
            // fires 5, from bottom edge up
            createFireworks(xMovement: 0, x: 512, y: bottomEdge)
            createFireworks(xMovement: 0, x: 512 - 200, y: bottomEdge)
            createFireworks(xMovement: 0, x: 512 - 100, y: bottomEdge)
            createFireworks(xMovement: 0, x: 512 + 100, y: bottomEdge)
            createFireworks(xMovement: 0, x: 512 + 200, y: bottomEdge)
        case 1:
            // fires 5, from bottom in a fan
            createFireworks(xMovement: 0, x: 512, y: bottomEdge)
            createFireworks(xMovement: -200, x: 512 - 200, y: bottomEdge)
            createFireworks(xMovement: -100, x: 512 - 100, y: bottomEdge)
            createFireworks(xMovement: 100, x: 512 + 100, y: bottomEdge)
            createFireworks(xMovement: 200, x: 512 + 200, y: bottomEdge)
        case 2:
            // fires 5, from left to right
            createFireworks(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
            createFireworks(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
            createFireworks(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
            createFireworks(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
            createFireworks(xMovement: movementAmount, x: leftEdge, y: bottomEdge)
        case 3:
            // fires 5, from right to left
            createFireworks(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
            createFireworks(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
            createFireworks(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
            createFireworks(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
            createFireworks(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)
        default: 
            break
        }
        // Challange 2
        if numberOfLaunches == 10 {
           gameOver()
        }
    }
    
    func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        // typecasting node as SKSpriteNode to find "firework" in nodesAtPoint
        for case let node as SKSpriteNode in nodesAtPoint {
            guard node.name == "firework" else { continue }
            
            // inner loop checks if tapped fireworks are the same color
            for parent in fireworks {
                guard let firework = parent.children.first as? SKSpriteNode else { continue }
                
                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            // marking firework node as selcted
            node.name = "selected"
            node.colorBlendFactor = 0
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }
    
    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 900 {
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    
    func explode(firework: SKNode) {
        if let emitter = SKEmitterNode(fileNamed: "explode") {
            emitter.position = firework.position
            addChild(emitter)
            
            // challange 3
            let delay = SKAction.wait(forDuration: 0.2)
            let action = SKAction.run { emitter.removeFromParent() }
            let sequence = SKAction.sequence([delay, action])
            emitter.run(sequence)
        }
        firework.removeFromParent()
    }
    
    func explodeFireworks() {
        var numExploded = 0
        
        for (index, fireworkContainer) in fireworks.enumerated().reversed() {
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue }
            if firework.name == "selected" {
                explode(firework: fireworkContainer)
                fireworks.remove(at: index)
                numExploded += 1
            }
        }
        switch numExploded {
        case 0:
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
        }
    }
    
    // Challange 2
    func gameOver() {
        gameTimer?.invalidate()
        
        for node in fireworks {
            node.removeFromParent()
        }
        
        let gameOver = SKLabelNode(fontNamed: "Chalkduster")
        gameOver.text = "GAME OVER! Your score is \(score)"
        gameOver.position = CGPoint(x: 512, y: 387)
        gameOver.zPosition = 5
        gameOver.fontSize = 40
        gameOver.horizontalAlignmentMode = .center
        addChild(gameOver)
    }
}
