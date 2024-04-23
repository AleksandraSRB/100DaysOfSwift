//
//  BuildingNode.swift
//  Project 29
//
//  Created by Aleksandra Sobot on 1.4.24..
//

import SpriteKit
import UIKit


class BuildingNode: SKSpriteNode {
    
    var currentImage: UIImage!
    
    func setup() {
        name = "building"
        currentImage = drawBuilding(size: size)
        texture = SKTexture(image: currentImage)
        configurePhysics()
    }
    
    func configurePhysics() {
        // creating physics body using texture and size of currentImage
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        // setting it's gravity to false, so it stays fixed on the screen
        physicsBody?.isDynamic = false
        // tells us what it is
        physicsBody?.categoryBitMask = CollisionTypes.building.rawValue
        // tells us about collision with bananas
        physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
    }
    
    func drawBuilding(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let img = renderer.image { ctx in
            let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
             
            let color: UIColor
            
            // creates 3 random colors of building
            switch Int.random(in: 0...2) {
            case 0:
                color = UIColor(hue: 0.502, saturation: 0.98, brightness: 0.67, alpha: 1)
            case 1:
                color = UIColor(hue: 0.999, saturation: 0.99, brightness: 0.67, alpha: 1)
            default:
                color = UIColor(hue: 0, saturation: 0, brightness: 0.67, alpha: 1)
            }
            color.setFill()
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fill)
            
            // creates 2 colors that will randomly represent windows on buildings
            let lightOnColor = UIColor(hue: 0.19, saturation: 0.67, brightness: 0.99, alpha: 1)
            let lightOffColor = UIColor(hue: 0, saturation: 0, brightness: 0.34, alpha: 1)
            
            // loops over numbers with interval
            // row will start from 10 up to height - 10, by 40
            for row in stride(from: 10, to: Int(size.height - 10), by: 40) {
                // column will start from 10 up to width - 10, by 40
                for col in stride(from: 10, to: Int(size.width - 10), by: 40) {
                    // randomly sets true or false and acts accordingly
                    if Bool.random() {
                        lightOnColor.setFill()
                    } else {
                        lightOffColor.setFill()
                    }
                    // fills the rectangle of size:
                    ctx.cgContext.fill(CGRect(x: col, y: row, width: 15, height: 20))
                }
            }
        }
        return img
    }
    
    func hit(at point: CGPoint) {
        // Converting SpriteKit positions to CoreGrapics
        let convertedPoint = CGPoint(x: point.x + size.width / 2, y: abs(point.y - (size.height / 2)))
        
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let img = renderer.image { ctx in
            currentImage.draw(at: .zero)
            
            ctx.cgContext.addEllipse(in: CGRect(x: convertedPoint.x - 32, y: convertedPoint.y - 32, width: 64, height: 64))
            ctx.cgContext.setBlendMode(.clear)
            ctx.cgContext.drawPath(using: .fill)
        }
        
        texture = SKTexture(image: img)
        currentImage = img
        configurePhysics()
    }

}
