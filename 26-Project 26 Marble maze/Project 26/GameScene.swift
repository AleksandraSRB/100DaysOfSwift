//
//  GameScene.swift
//  Project 26
//
//  Created by Aleksandra Sobot on 18.3.24..
//

import CoreMotion
import SpriteKit

enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case star = 4
    case vortex = 8
    case finish = 16
    case portal = 32
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: SKSpriteNode!
    var lastTouchPosition: CGPoint?
    var motionManager: CMMotionManager!
    
    var scoreLabel: SKLabelNode!
    var isGameOver = false
    var level = 1
    var maxLevel = 3
    
    var gameOverLabel: SKLabelNode!
    
    var isFirstPortal = false
    var isPortalActive = false
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.zPosition = -1
        background.blendMode = .replace
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.fontSize = 36
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.zPosition = 2
        addChild(scoreLabel)
        
        score = 0
        
        loadLevel()
        createPlayer()
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
    }
    

    func loadLevel() {
        // forcing fatal error in case we couldn't load level file
                                                            // challange 2. we created 3 levels
        guard let levelURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") else {
            fatalError("Could not find level\(level).txt in the app bundle.")
        }
        // forcing fatal error in case we couldn't load level file
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not find level\(level).txt in the app bundle.")
        }
        // creating separated lines from level1.txt file. Creates line by line
        let lines = levelString.components(separatedBy: "\n")
        
        // loops over each line in lines
        for (row, line) in lines.reversed().enumerated() {
            // loops over each character in line
            for (column, letter) in line.enumerated() {
                // each square takes 64x64 space. We are calculating it's position by multiplying his row and column by 64, and adding 32.
                let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)
                
            // Challange 1 and 3
                switch letter {
                case "x":
                    loadWall(spriteNamed: "block", position: position, collisionType: CollisionTypes.wall)
                case "v":
                    loadVortex(spriteNamed: "vortex", position: position, collisionType: CollisionTypes.vortex)
                case "s":
                    loadStar(spriteNamed: "star", position: position, collisionType: CollisionTypes.star)
                case "f":
                    loadFinish(spriteNamed: "finish", position: position, collisionType: CollisionTypes.finish)
                    // Challange 3. first portal that is open/entry portal
                case "p":
                    loadPortal(spriteNamed: "portal", position: position, collisionType: CollisionTypes.portal, isFirst: true)
                    // Challange 3. second portal that is closed/exit portal
                case "2":
                    loadPortal(spriteNamed: "portal2", position: position, collisionType: CollisionTypes.portal, isFirst: false)
                case " ":
                    break
                default:
                    fatalError("Unknown level letter: \(letter)")
                }
            }
        }
    }
    
    // Challange 1. Refactor loadLevel() method unto smaller methods
    func loadWall(spriteNamed: String, position: CGPoint, collisionType: CollisionTypes) {
        let node = SKSpriteNode(imageNamed: "block")
        node.position = position
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
        node.physicsBody?.isDynamic = false // doesn't move if it is hit
        addChild(node)
    }
    // Challange 1. Refactor loadLevel() method unto smaller methods
    func loadVortex(spriteNamed: String, position: CGPoint, collisionType: CollisionTypes) {
        let node = SKSpriteNode(imageNamed: "vortex")
        node.name = "vortex"
        node.position = position
        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        addChild(node)
    }
    // Challange 1. Refactor loadLevel() method unto smaller methods
    func loadStar(spriteNamed: String, position: CGPoint, collisionType: CollisionTypes) {
        let node = SKSpriteNode(imageNamed: "star")
        node.name = "star"
        node.position = position
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        addChild(node)
    }
    // Challange 1. Refactor loadLevel() method into smaller methods
    func loadFinish(spriteNamed: String, position: CGPoint, collisionType: CollisionTypes) {
        let node = SKSpriteNode(imageNamed: "finish")
        node.name = "finish"
        node.position = position
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        addChild(node)
    }
    // Challange 1. Refactor loadLevel() method unto smaller methods + Challange 3. Creating a loadPortal method
    func loadPortal(spriteNamed: String, position: CGPoint, collisionType: CollisionTypes, isFirst: Bool) {
        let node = SKSpriteNode(imageNamed: "portal")
        
        if isFirst {
            node.name = "portal"
            isPortalActive = true
        } else {
            node.name = "portal2"
            isPortalActive = false
        }
        
        node.position = position
        node.size = CGSize(width: Double(node.size.width * 2), height: Double(node.size.width * 2))
        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionTypes.portal.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        addChild(node)
    }
    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 96, y: 672)
        player.zPosition = 1
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = false // stops ball from rotating
        player.physicsBody?.angularDamping = 0.5 // naturally slows down the ball
        
        // gives player a category number
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        // starts monitoring contact between star, vortex and finish
        player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue | CollisionTypes.vortex.rawValue | CollisionTypes.finish.rawValue | CollisionTypes.portal.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue // it will bounce off wall
        addChild(player)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isGameOver == false else { return }
        
        // if we are using simulator, this block of code will be exicuted. Code will exist only if we compile for the simulator
#if targetEnvironment(simulator)
        if let currentTouch = lastTouchPosition {
            let diff = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
            physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
        }
#else
        // we are adding tilt information
        if let accelerometerData = motionManager.accelerometerData {
            // if we can read accelerometer data, we will use it to create CGVector from tilt information, and will use x and y tilt for our physicsWorld.gravity
            // we are passing y coordinate to  dx, and x coordinate to xy cause of rortating screen
            // we are multiplying with -50 and 50, cause tilt is very sensitive
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
        }
#endif
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA == player {
            playerCollided(with: nodeB)
        } else if nodeB == player {
            playerCollided(with: nodeA)
        }
    }
    // Challange 2. Preparing scene for loading next level - deleting all nodes from scene
    func prepareForNextLevel() {
        for node in children {
            if ["wall", "star", "vortex", "finish", "portal", "portal2"].contains(node.name) {
                node.removeFromParent()
            }
            player.removeFromParent()
            
        }
    }
    
    // Challange 2. Creating a new level
    func levelUp() {
        
        if level < maxLevel {
            level += 1
            loadLevel()
            createPlayer()
            isGameOver = false
        } else if maxLevel == 3 {
            level = 1
            isGameOver = true
        }
    }
    
    func playerCollided(with node: SKNode) {
        if node.name == "vortex" {
            player.physicsBody?.isDynamic = false
            score -= 1
            isGameOver = true
            
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])
            
            player.run(sequence) { [weak self] in
                self?.createPlayer()
                self?.isGameOver = false
            }
        } else if node.name == "star" {
            node.removeFromParent()
            score += 1
            // Challange 3. What happens when player collides with portal
        } else if node.name == "portal" {
           
            if let newNode = self.childNode(withName: "portal2") {
                teleportPlayer(oldPosition: self.position, newPosition: newNode.position)
            }
            
        } else if node.name == "finish" {
            player.physicsBody?.isDynamic = false
            isGameOver = true
            
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])
            
            loadGameOverLabel()
            
            player.run(sequence) { [weak self] in
                self?.prepareForNextLevel()
                self?.gameOverLabel.removeFromParent()
                self?.levelUp()
                
            }
            
        }
        
        // Challange 3. Creating a teleport action, player is moved from one position to the other
        func teleportPlayer(oldPosition: CGPoint, newPosition: CGPoint) {
            
            isFirstPortal = true
            isPortalActive = true
            player.physicsBody?.isDynamic = false
            
            let move = SKAction.move(to: oldPosition, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let teleportTo = SKAction.move(to: newPosition, duration: 0)
            let scaleBack = SKAction.scale(to: 1, duration: 0.25)
            let restorePhysicsBody = SKAction.run {
                [weak self] in
                self?.player.physicsBody?.isDynamic = true
            }
            let sequence = SKAction.sequence([move, scale, teleportTo, scaleBack, restorePhysicsBody])
                
            player.run(sequence)
            isPortalActive = false
        }
        
        // Challange 1. gameOver label
        func loadGameOverLabel() {
           gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
            gameOverLabel.text = "GAME OVER!\n Your score is: \(score)"
            gameOverLabel.fontSize = 46
            gameOverLabel.position = CGPoint(x: 512, y: 386)
            gameOverLabel.zPosition = 3
            addChild(gameOverLabel)
        }
    }
}
