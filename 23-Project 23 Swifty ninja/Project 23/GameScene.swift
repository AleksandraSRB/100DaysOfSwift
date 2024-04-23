//
//  GameScene.swift
//  Project 23
//
//  Created by Aleksandra Sobot on 26.2.24..
//

import AVFoundation
import SpriteKit
import GameplayKit

enum SequenceType: CaseIterable {
    case oneNoBomb, one, twoWithOneBomb, two, three, four, chain, fastChain
}
enum ForceBomb {
    case never, always, random
}

class GameScene: SKScene {
    
    var gameScore: SKLabelNode!
    
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    var livesImages = [SKSpriteNode]()
    var lives = 3
    
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    
    var activeSlicePoints = [CGPoint]()
    var isSwooshSoundActive = false
    var activeEnemies = [SKSpriteNode]()
    var bombSoundEffect: AVAudioPlayer?
    
    var popupTime = 0.9 // time between creating a new enemy (toss time)
    var sequence = [SequenceType]() // new object, an empty array of sequenceType
    var sequencePosition = 0 // where are we in the game
    var chainDelay = 3.0 // delay time when creating .chain or .fastChain sequenceType enemies
    var nextSequenceQueued = true
    
    var isGameEnded = false // by default game is active
    
    // Challange 1 - giving constant properties for values that we are later using
    let randomXVelocityLowSpeed = 3...5
    let randomXVelocityMediumSpeed = 8...15
    let randomYVelocityRange = 24...32
    
    let randomAngularVelocityRange: ClosedRange<CGFloat> = -3...3
    
    let leftHalfOfTheScreen: CGFloat = 256
    let rightHalfOfTheScreen: CGFloat = 768
    
    //Challange 2 - creating fast enemy
    var penguin = 1
    var bomb = 0
    var fastPenguin = 6
    
    let enemyVelocityMultiplier = 40
    let fastEnemyMultiplier = 50...55
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        physicsWorld.speed = 0.85
        
        createScore()
        createLives()
        createSlices()
        
        sequence = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain]
        
        for _ in 0...1000 {
            if let nextSequence = SequenceType.allCases.randomElement() {
                sequence.append(nextSequence)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            [weak self] in self?.tossEnemies()
        }
       
    }
    // creates score label on tbe bottom left corner of the screen
    func createScore() {
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.fontSize = 48
        gameScore.horizontalAlignmentMode = .left
        addChild(gameScore)
        
        gameScore.position = CGPoint(x: 16, y: 10)
        gameScore.zPosition = 2
        score = 0
    }
    // creates xxx on toprigt corner of the screen, wich present lives
    func createLives() {
        for i in 0..<3 {
            let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
            spriteNode.position = CGPoint(x: CGFloat(834 + (i * 70)), y: 720)
            addChild(spriteNode)
            livesImages.append(spriteNode)
        }
    }
    // creates curve lines (slices) that will be used to cut enemies (yellow and white)
    func createSlices() {
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2
        
        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 3
        
        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.lineWidth = 9
        
        activeSliceFG.strokeColor = .white
        activeSliceFG.lineWidth = 5
        
        addChild(activeSliceBG)
        addChild(activeSliceFG)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isGameEnded == false else { return }
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        if !isSwooshSoundActive {
            playSwooshSound()
        }
        
        let nodesAtPoint = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtPoint {
            if node.name == "enemy" {
                // destroy the penguin
                // 1. creating emitter over the penguin
                if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy") {
                    emitter.position = node.position
                    addChild(emitter)
                }
                
                // 2. deleting nodes name so it stops exsisting
                node.name = ""
                
                // 3. change it's isDynamic physics body so it doesn't fall
                node.physicsBody?.isDynamic = false
                
                // 4. scale out and fade out the penguin
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                // putting actions in a group means that all actions will execute simultaneosly
                let group = SKAction.group([scaleOut, fadeOut])
                
                // 5. add group to sequence
                let sequence = SKAction.sequence([group, .removeFromParent()])
                node.run(sequence)
                
                // 6. adding point to the score
                score += 1
                
                // 7. removing enemy from the array
                if let index = activeEnemies.firstIndex(of: node) {
                    activeEnemies.remove(at: index)
                }
                
                // 8. run the sound
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                
              // Challange 2 - What happens when player hits fast penguin
            } else if node.name == "fastEnemy" {
                if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy") {
                    emitter.position = node.position
                    addChild(emitter)
                }
                node.name = ""
                node.physicsBody?.isDynamic = false
                
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                
                let sequence = SKAction.sequence([group, .removeFromParent()])
                node.run(sequence)
                
                score += 5
                
                if let index = activeEnemies.firstIndex(of: node) {
                    activeEnemies.remove(at: index)
                }
                
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                
            } else if node.name == "bomb" {
                guard let bombContainer = node.parent as? SKSpriteNode else { continue }
                
                if let emitter = SKEmitterNode(fileNamed: "sliceHitBomb") {
                    emitter.position = bombContainer.position
                    addChild(emitter)
                }
                node.name = ""
                bombContainer.physicsBody?.isDynamic = false
                
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                
                let sequence = SKAction.sequence([group, .removeFromParent()])
                bombContainer.run(sequence)
                
                if let index = activeEnemies.firstIndex(of: bombContainer) {
                    activeEnemies.remove(at: index)
                }
                
                run(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
                endGame(triggeredByBomb: true)
            }
        }
    }
    
    func endGame(triggeredByBomb: Bool) {
        guard isGameEnded == false else { return } //don't run endGame() method more than once
        
        isGameEnded = true
        
        physicsWorld.speed = 0
        isUserInteractionEnabled = false
        
        bombSoundEffect?.stop()
        bombSoundEffect = nil
        
        if triggeredByBomb {
            livesImages[0].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[1].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[2].texture = SKTexture(imageNamed: "sliceLifeGone")
            
        }
        // challange 3
        setUpGameOverLabel()
      
    }
    
    // challange 3
    func setUpGameOverLabel() {
        let gameOver = SKLabelNode(fontNamed: "Chalkduster")
        gameOver.text = "GAME OVER"
        gameOver.position = CGPoint(x: 512, y: 368)
        gameOver.fontSize = 55
        gameOver.zPosition = 3
        addChild(gameOver)
        
    }
    
    func playSwooshSound() {
        // sound is active
        isSwooshSoundActive = true
        
        // choosing random sound
        let randomNumber = Int.random(in: 1...3)
        let soundName = "swoosh\(randomNumber).caf"
        
        // wrapping that in play action
        let swooshSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        // run the action and writting copletion handler so that it knows when the sound stopped playing
        run(swooshSound) { [weak self] in
            self?.isSwooshSoundActive = false
        }
    }
    // destroys slices
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        // 1. destroys previous slices
        activeSlicePoints.removeAll(keepingCapacity: true)
        
        // 2.
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        
        // 3.
        redrawActiveSlice()
        
        // 4.
        activeSliceBG.removeAllActions()
        activeSliceFG.removeAllActions()
        
        // 5.
        activeSliceBG.alpha = 1
        activeSliceFG.alpha = 1
    }
    
    func redrawActiveSlice() {
        // 1.
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }
        
        // 2.
        if activeSlicePoints.count > 12 {
            activeSlicePoints.removeFirst(activeSlicePoints.count - 12)
        }
        
        // 3.
        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])
        
        for i in 1..<activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }
        
        // 4.
        activeSliceBG.path = path.cgPath
        activeSliceFG.path = path.cgPath
    }
    
    func createEnemy(forceBomb: ForceBomb = .random) {
        let enemy: SKSpriteNode
        var enemyType = Int.random(in: 0...6)
        
        // enemyType = 1 is penguin, enemyType = 0 is bomb
        if forceBomb == .never {
            enemyType = Int.random(in: 1...6)
        } else if forceBomb == .always {
            enemyType = bomb
        }
        
        if enemyType == bomb {
            // creates a bomb
            // 1. we are creating a SKSpriteNode object that will be a container that holds bomb image and emitter
            enemy = SKSpriteNode()
            enemy.zPosition = 1
            enemy.name = "bombContainer"
            
            // 2. we are creating bomb image, giving it a name and adding it to container
            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)
            
            // 3. if the bombSound is active, we need to deactive and destroy it
            if bombSoundEffect != nil {
                bombSoundEffect?.stop()
                bombSoundEffect = nil
            }
            
            // 4. creating new bomb sound effect and play it
            if let path = Bundle.main.url(forResource: "sliceBombFuse", withExtension: "caf"){
                let sound = try? AVAudioPlayer(contentsOf: path)
                bombSoundEffect = sound
                sound?.play()
            }
            
            // 5. create new particle emitter and position it at the edge of the bomb fuse, and add it to contaier
            if let emitter = SKEmitterNode(fileNamed: "sliceFuse") {
                emitter.position = CGPoint(x: 76, y: 64)
                enemy.addChild(emitter)
            }
            // Challange 2 - creates faster and smaller penguin
        } else if enemyType == fastPenguin {
            enemy = SKSpriteNode(imageNamed: "penguin")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "fastEnemy"
            enemy.scale(to: CGSize(width: 60, height: 60))
            
        } else {
            // creates a penguin
            enemy = SKSpriteNode(imageNamed: "penguin")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            
            enemy.name = "enemy"
        }
        
        // position goes here, x position is bottom length of the screen, and y is bellow bottom
        let randomPosition = CGPoint(x: Int.random(in: 64...960), y: -128)
        enemy.position = randomPosition
        
        
        let randomAngularVelocity = CGFloat.random(in: randomAngularVelocityRange)
        let randomXVelocity: Int
        
        if randomPosition.x < leftHalfOfTheScreen {
            randomXVelocity = Int.random(in: randomXVelocityMediumSpeed)
        } else if randomPosition.x < leftHalfOfTheScreen {
            randomXVelocity = Int.random(in: randomXVelocityLowSpeed)
        } else if randomPosition.x < rightHalfOfTheScreen {
            randomXVelocity = -Int.random(in: randomXVelocityLowSpeed)
        } else {
            randomXVelocity = -Int.random(in: randomXVelocityMediumSpeed)
        }
        
        let randomYVelocity = Int.random(in: randomYVelocityRange)
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        
        // Challange 2
        let enemySpeed: Int
        
        if enemyType == fastPenguin {
            enemySpeed = Int.random(in: fastEnemyMultiplier)
        } else {
            enemySpeed = enemyVelocityMultiplier
        }
        
        enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * enemySpeed, dy: randomYVelocity * enemySpeed)
        enemy.physicsBody?.angularVelocity = randomAngularVelocity
        enemy.physicsBody?.collisionBitMask = 0
        
        addChild(enemy)
        activeEnemies.append(enemy)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if activeEnemies.count > 0 {
            for (index, node) in activeEnemies.enumerated().reversed() {
                if node.position.y < -140 {
                    node.removeAllActions()
                    
                    if node.name == "enemy" {
                        node.name = ""
                        subtractLife()
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                        // Challange 2 - doesn't subtract life, just gives bonus points
                    } else if node.name == "fastEnemy" {
                        node.name = ""
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    } else if node.name == "bombContainer" {
                        node.name = ""
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    }
                }
            }
    
                } else {
                    if !nextSequenceQueued {
                        DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) {
                            [weak self] in self?.tossEnemies()
                        }
                        nextSequenceQueued = true
                    }
                }
                var bombCount = 0
                
                for node in activeEnemies {
                    if node.name == "bobmContainer" {
                        bombCount += 1
                        break
                    }
                }
                // if there are no bombs, stop the sound fuse
                if bombCount == 0 {
                    bombSoundEffect?.stop()
                    bombSoundEffect = nil
                }
            }
    
    func subtractLife() {
        lives -= 1
        
        run(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))
        
        var life: SKSpriteNode
        
        if lives == 2 {
            life = livesImages[0]
        } else if lives == 1 {
            life = livesImages[1]
        } else {
            life = livesImages[2]
            endGame(triggeredByBomb: false)
        }
        
        life.texture = SKTexture(imageNamed: "sliceLifeGone")
        life.xScale = 1.3
        life.yScale = 1.3
        life.run(SKAction.scale(to: 1, duration: 0.1))
    }
    
    func tossEnemies() {
        guard isGameEnded == false else { return }
        
        popupTime *= 0.991
        chainDelay *= 0.99
        physicsWorld.speed *= 1.02
        
        // sequenceType is a new object of sequence array at it's index(position)
        let sequenceType = sequence[sequencePosition]
        
        // we are switching through all possible cases in sequenceType
        switch sequenceType {
        case .oneNoBomb:
            createEnemy(forceBomb: .never) // it will never be a bomb
        case .one:
            createEnemy() // it will be a random enemy (enemy or bomb)
        case .twoWithOneBomb:
            createEnemy(forceBomb: .never) // one enemy will never be a bomb
            createEnemy(forceBomb: .always) // one enemy will always be a bomb
        case .two:
            createEnemy() // it will be a random enemy (enemy or bomb)
            createEnemy() // it will be a random enemy (enemy or bomb)
        case .three:
            createEnemy()
            createEnemy()
            createEnemy()
        case .four:
            createEnemy()
            createEnemy()
            createEnemy()
            createEnemy()
        case .chain:
            // creating at least one enemy straight away
            createEnemy()
            // creating enemies after some delay - 1/5 of our chainDelay time
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0)) {
                [weak self] in self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 2)) {
                [weak self] in self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 3)) {
                [weak self] in self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 4)) {
                [weak self] in self?.createEnemy()
            }
        case .fastChain:
            // creating at least one enemy straight away
            createEnemy()
            
            // creating enemies after some delay - faster that .chain
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0)) {
                [weak self] in self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 2)) {
                [weak self] in self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 3)) {
                [weak self] in self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 4)) {
                [weak self] in self?.createEnemy()
            }
        }
        sequencePosition += 1
        nextSequenceQueued = false
    }
}
