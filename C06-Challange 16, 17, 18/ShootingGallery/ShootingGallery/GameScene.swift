//
//  GameScene.swift
//  ShootingGallery
//
//  Created by Matt X on 12/20/22.
//

import SpriteKit

class GameScene: SKScene {
    
    enum Field: Int {
        case bottom = 50
        case middle = 250
        case top = 450
    }
    
    static let width = 1024
    static let height = 768
    
    var scoreLabel: SKLabelNode!
    var timeRemainingLabel: SKLabelNode!
    var shotsLabel: SKLabelNode!
    var generateTargetTimer: Timer?
    var gameTimer: Timer?
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var timeRemaining = 60 {
        didSet {
            timeRemainingLabel.text = "Time: \(timeRemaining) sec."
        }
    }
    
    var shotsRemaining = 5 {
        didSet {
            shotsLabel.text = "Bullets: \(shotsRemaining)"
        }
    }
    
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "wood-background")
        background.position = CGPoint(x: GameScene.width / 2, y: GameScene.height / 2)
        background.size = frame.size
        background.zPosition = -1
        background.blendMode = .replace
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 25, y: GameScene.height - 60)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontSize = 36
        addChild(scoreLabel)
        
        timeRemainingLabel = SKLabelNode(fontNamed: "Chalkduster")
        timeRemainingLabel.position = CGPoint(x: 512, y: GameScene.height - 60)
        timeRemainingLabel.fontSize = 36
        addChild(timeRemainingLabel)
        
        shotsLabel = SKLabelNode(fontNamed: "Chalkduster")
        shotsLabel.position = CGPoint(x: 800, y: GameScene.height - 60)
        shotsLabel.fontSize = 36
        shotsLabel.horizontalAlignmentMode = .left
        addChild(shotsLabel)
    
        physicsWorld.gravity = .zero
        startGame()
    }
    
    func startGame() {
        run(SKAction.playSoundFileNamed("reload.wav", waitForCompletion: false))
        score = 0
        timeRemaining = 60
        shotsRemaining = 6
        
        generateTargetTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(generateRandomTarget), userInfo: nil, repeats: true)
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(decreaseTime), userInfo: nil, repeats: true)
    }
    
    func createTarget(at field: Field) {
        let target = Target()
        target.configureTarget()
        
        
        var xMovement: CGFloat
        var xPosition: Int
        
        switch field {
        case .bottom:
            target.zPosition = 1
            xMovement = CGFloat(GameScene.width) + 80
            xPosition = -30
            target.setScale(0.75)
            target.target.name = "targetGood"
        case .middle:
            target.zPosition = 2
            xMovement = -1 * CGFloat(GameScene.width) - 80
            xPosition = 1024
            target.xScale *= -1 // Mirror target to face other direction
            target.target.name = "targetNeutral"
        case .top:
            target.zPosition = 3
            xMovement = CGFloat(GameScene.width) + 80
            xPosition = -30
            target.setScale(0.5)
            target.target.name = "targetExcellent"
        }
        
        target.position = CGPoint(x: xPosition, y: field.rawValue)
    
        let moveAction = SKAction.moveBy(x: xMovement, y: 0, duration: 5)
        let deleteAction = SKAction.customAction(withDuration: 1) { node, _ in
            node.removeFromParent()
        }
        let sequence = SKAction.sequence([moveAction, deleteAction])
        target.run(sequence)
        
        addChild(target)
    }
    
    @objc func generateRandomTarget() {
        if Int.random(in: 1...5) <= 2 {
            createTarget(at: .bottom)
        }
        if Int.random(in: 1...5) <= 2 {
            createTarget(at: .top)
        }
        
        if Int.random(in: 1...5) >= 4 {
            createTarget(at: .middle)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        let tappedNode = nodes(at: location)
        
        shotsRemaining -= 1
        shotSound()
       
        for node in tappedNode {
            
            if node.name == "targetGood" {
                score += 5
                shotSound()
                node.removeFromParent()
            } else if node.name == "targetNeutral" {
                score += 1
                shotSound()
                node.removeFromParent()
            } else if node.name == "targetExcellent" {
                score += 10
                shotSound()
                node.removeFromParent()
            }
        }
        
        if shotsRemaining == 0 {
            run(SKAction.playSoundFileNamed("empty.wav", waitForCompletion: false))
            gameOver()
        }
    }
    
    func shotSound() {
        run(SKAction.playSoundFileNamed("shot.wav", waitForCompletion: false))
    }
   
    @objc func decreaseTime() {
        timeRemaining -= 1
        
        if timeRemaining == 0 {
            gameOver()
        }
    }
    
    func gameOver() {
        gameTimer?.invalidate()
        generateTargetTimer?.invalidate()
        
        let gameOver = SKSpriteNode(imageNamed: "game-over")
        gameOver.position = CGPoint(x: 512, y: 368)
        gameOver.zPosition = 10
        addChild(gameOver)
        run(SKAction.playSoundFileNamed("gameOver.wav", waitForCompletion: false))
    }
}

    
  

