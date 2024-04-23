//
//  Target.swift
//  ShootingGallery
//
//  Created by Aleksandra Sobot on 16.1.24..
//

import SpriteKit

class Target: SKNode {
    
    var target: SKSpriteNode!
    
    func configureTarget() {
        let targetIndex = Int.random(in: 0...3)
        
        target = SKSpriteNode(imageNamed: "target\(targetIndex)")
        target.position = CGPoint(x: 0, y: Int.random(in: 0...150))
        
        addChild(target)
    }
}

