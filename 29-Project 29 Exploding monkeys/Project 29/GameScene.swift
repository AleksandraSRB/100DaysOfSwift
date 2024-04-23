//
//  GameScene.swift
//  Project 29
//
//  Created by Aleksandra Sobot on 1.4.24..
//

import SpriteKit
import GameplayKit

enum CollisionTypes: UInt32 {
    case banana = 1
    case building = 2
    case player = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var buildings = [BuildingNode]()
    // creates weak reference to GameViewController. We need reference to communicate between two view controllers, but we want to avoid retain cycle
    weak var viewController: GameViewController?
    
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var banana: SKSpriteNode!
    
    var currentPlayer = 1
    // Challange 1
    var maxScore = 3
    var isGameOver = false
    // Challange 3
    var currentWind: CGFloat = 0
    var windSpeed: Int = 0
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
    
        createBuildings()
        createPlayers()
        
        physicsWorld.contactDelegate = self
        
    }
    
    
    func createBuildings() {
        // starting x coordinate is -15, before left edge of the screen
        var currentX: CGFloat = -15
        
        //while x coordinate is less than 1024, aka right edge of the screen
        while currentX < 1024 {
            // size of building will be: random width 80, 120 or 160, and height random in 300...600
            let size = CGSize(width: Int.random(in: 2...4) * 40, height: Int.random(in: 300...600))
            // moving buildings by their width and adding small space
            currentX += size.width + 2
            
            let building = BuildingNode(color: .red, size: size)
            // in SpriteKit nodes have anchor point in center, so we need to move them by 1/2 od their size
            building.position = CGPoint(x: currentX - (size.width / 2), y: size.height / 2)
            // configures building, gives physics to the building
            building.setup()
            addChild(building)
            // appends it to the array
            buildings.append(building)
        }
    }
    
    func launch(angle: Int, velocity: Int) {
        // we gave the velocity of banana, but because it is too fast, we are slowing it down
        let speed = Double(velocity) / 10.0
        // calculates radian value from degrees
        let radians = deg2rad(degrees: angle)
        
        if banana != nil {
            banana.removeFromParent()
            banana = nil
        }
        // Creates banana
        banana = SKSpriteNode(imageNamed: "banana")
        banana.name = "banana"
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
        banana.physicsBody?.categoryBitMask = CollisionTypes.banana.rawValue
        banana.physicsBody?.contactTestBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        banana.physicsBody?.collisionBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        // it slows down the app, use it only when needed
        banana.physicsBody?.usesPreciseCollisionDetection = true
        addChild(banana)
        
        if currentPlayer == 1 {
            banana.position = CGPoint(x: player1.position.x - 30, y: player1.position.y + 40)
            banana.physicsBody?.angularVelocity = -20
            
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player1Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            player1.run(sequence)
            
            // calculates the impuls from left to right
            let impulse = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        } else {
            banana.position = CGPoint(x: player2.position.x + 30, y: player2.position.y + 40)
            banana.physicsBody?.angularVelocity = 20
            
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player2Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            player2.run(sequence)
            
            // calculates the impuls from right to left
            let impulse = CGVector(dx: cos(radians) * -speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        }
    }
    
    func createPlayers() {
        player1 = SKSpriteNode(imageNamed: "player")
        player1.name = "player1"
        player1.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width / 2)
        player1.physicsBody?.isDynamic = false
        player1.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player1.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue // bounce off bnana
        player1.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue // tell us when it hits banana
        
        // player1 will be on top of the second building from the left(buildings array [1])
        let player1Building = buildings[1]
        // position x is buildings position x, y position
        player1.position = CGPoint(x: player1Building.position.x, y: player1Building.position.y + ((player1Building.size.height + player1.size.height) / 2))
        addChild(player1)
        
        player2 = SKSpriteNode(imageNamed: "player")
        player2.name = "player2"
        player2.physicsBody = SKPhysicsBody(circleOfRadius: player2.size.width / 2)
        player2.physicsBody?.isDynamic = false
        player2.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player2.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
        player2.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        
        // player1 will be on top of the second building from the left(buildings array [1])
        let player2Building = buildings[buildings.count - 2]
        // position x is buildings position x, y position
        player2.position = CGPoint(x: player2Building.position.x, y: player2Building.position.y + ((player2Building.size.height + player2.size.height) / 2))
        addChild(player2)
        
    }
    
    // formula for calculating radius value from degrees
    func deg2rad(degrees: Int) -> Double {
        return Double(degrees) * Double.pi / 180
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // we are creating two variables and giving them physics bodies
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody
        
        //we are checking categoryBitMask value and asigning it to bodies. First body will hold lowest number, and second will hold highest number
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
       // checks if any of the nodes is nil. If one of them is nil, that means we already handeled that collision
        guard let firstNode = firstBody.node else { return }
        guard let secondNode = secondBody.node else { return }
        
        // if none of the nodes is nil, we are checking both of their names
        // if banana hits building, call bananaHit(building:, atPoint:)
        if firstNode.name == "banana" && secondNode.name == "building" {
            bananaHit(building: secondNode, atPoint: contact.contactPoint)
            
        }
        // if banana hits player1, call destroy(player:)
        if firstNode.name == "banana" && secondNode.name == "player1" {
            destroy(player: player1)
            // Challange 1
            viewController?.player2Score += 1
            if viewController?.player2Score == maxScore {
                viewController?.player2ScoreLabel.text = "WINNER"
                gameOver()
            } else {
                newGame()
            }
        }
        // if banana hits player2, call destroy(player:)
        // Challange 1
        if firstNode.name == "banana" && secondNode.name == "player2" {
            destroy(player: player2)
            viewController?.player1Score += 1
            if viewController?.player1Score == maxScore {
                viewController?.player1ScoreLabel.text = "WINNER"
                gameOver()
            } else {
                newGame()
            }
           
        }
    }
    
    func destroy(player: SKSpriteNode) {
        if let emitter = SKEmitterNode(fileNamed: "hitPlayer") {
            emitter.position = player.position
            addChild(emitter)
        }
        
        banana.removeFromParent()
        player.removeFromParent()
    }
    
    func newGame() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let newGame = GameScene(size: self.size)
            // newGame points to viewController and viewController points to newGame
            newGame.viewController = self.viewController
            self.viewController?.currentGame = newGame
            // we are changing the player, and setting new player as a current player
            self.changePlayer()
            // Challange 3
            self.generateRandomWind()
            newGame.currentPlayer = self.currentPlayer
            // creating transition effect
            let transition = SKTransition.crossFade(withDuration: 1.5)
            // presenting new scene with animation
            self.view?.presentScene(newGame, transition: transition)
        }
    }
    
    func changePlayer() {
        if currentPlayer == 1 {
            currentPlayer = 2
        } else {
            currentPlayer = 1
        }
        viewController?.activatePlayer(number: currentPlayer)
    }
    
    func bananaHit(building: SKNode, atPoint contactPoint: CGPoint) {
        guard let building = building as? BuildingNode else { return }
        // converting collision contactPoint into coordinates relative to the building node
        let buildingLocation = convert(contactPoint, to: building)
        building.hit(at: buildingLocation)
        
        if let explosion = SKEmitterNode(fileNamed: "hitBuilding") {
            explosion.position = contactPoint
            addChild(explosion)
        }
        
        banana.name = "" //banana could hit two building at the same time, and it's a bug. We are giving banana name value of "", so when first collision happens, banana is destroyed
        banana.removeFromParent()
        banana = nil
        changePlayer()
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard banana != nil else { return }
        
        if abs(banana.position.y) > 1000 {
            banana.removeFromParent()
            banana = nil
            changePlayer()
        }
    }
    // Challange 3. - Generating random wind
    func generateRandomWind() {
        currentWind = CGFloat.random(in: -5...5)
        physicsWorld.gravity = CGVector(dx: currentWind, dy: physicsWorld.gravity.dy)
        
        windSpeed = Int(abs(currentWind) * 10)
        
        if currentWind < 0 {
            viewController?.windLabel.text = "Wind: EAST: \(windSpeed)"
        } else if currentWind > 0 {
            viewController?.windLabel.text = "Wind: WEST: \(windSpeed)"
        } else {
            viewController?.windLabel.text = "WIND: \(windSpeed)"
        }
    }
    
    func gameOver() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isGameOver = true
            self.isUserInteractionEnabled = false
            
            for node in self.children {
                if ["player1", "player2", "banana"].contains(node.name) {
                    node.removeFromParent()
                }
            }
            
             let gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
             gameOverLabel.text = "GAME OVER!"
             gameOverLabel.fontSize = 46
             gameOverLabel.position = CGPoint(x: 512, y: 386)
             gameOverLabel.zPosition = 3
             self.addChild(gameOverLabel)
        }
    }
}
