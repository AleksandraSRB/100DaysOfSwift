//
//  ViewController.swift
//  Project 27
//
//  Created by Aleksandra Sobot on 25.3.24..
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet var imageView: UIImageView!
    
    var currentDrawType = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       drawRectangle()
    }


    @IBAction func redrawTapped(_ sender: Any) {
        currentDrawType += 1
        
        if currentDrawType > 9 {
            currentDrawType = 0
        }
        
        switch currentDrawType {
        case 0:
            drawRectangle()
        case 1:
            drawCircle()
        case 2:
            drawCheckboard()
        case 3:
            drawRotatedSquare()
        case 4:
            drawLines()
        case 5:
            drawImagesAndText()
        case 6:
            drawSmiley()
        case 7:
            drawSmileyFace()
        case 8:
            drawStar()
        case 9:
            drawTwin()
        default:
            break
        }
    }
    
    func drawRectangle() {
        // creating renderer that holds size
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        // calling image() method on renderer. It is a closure with one parameter called "ctx" (context)
        // this piece of code holds all the drawing
        let image = renderer.image { ctx in
            // creates a rectangle where the drawing will be created. It will move the line inside the rectangle by 5 points
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 5, dy: 5)
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        imageView.image = image
        
    }
    
    func drawCircle() {
        // creating renderer that holds size
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        // calling image() method on renderer. It is a closure with one parameter called "ctx" (context)
        // this piece of code holds all the drawing
        let image = renderer.image { ctx in
            // creates a rectangle where the drawing will be created. It will move the line inside the rectangle by 5 points
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 5, dy: 5)
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            
            // only piece of code that is changing comparing to drawRectangle()
            ctx.cgContext.addEllipse(in: rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = image
        
    }
    
    func drawCheckboard() {
        // creating renderer that holds size
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        // calling image() method on renderer. It is a closure with one parameter called "ctx" (context)
        // this piece of code holds all the drawing
        let image = renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.black.cgColor)
            
            // loops over each row and column. (checkboard is 8X8 fields)
            for row in 0 ..< 8 {
                for column in 0 ..< 8 {
                    // every even number will be filled with black color
                    if (row + column) % 2 == 0 {
                        ctx.cgContext.fill(CGRect(x: column * 64, y: row * 64, width: 64, height: 64))
                    }
                }
            }
        }
        imageView.image = image
    }
    
    func drawRotatedSquare() {
        // creating renderer that holds size
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        // calling image() method on renderer. It is a closure with one parameter called "ctx" (context)
        // this piece of code holds all the drawing
        let image = renderer.image { ctx in
            // moves transformation matrix to center
            ctx.cgContext.translateBy(x: 256, y: 256)
            // we will have 16 rotations
            let rotations = 16
            // creates an amount for rotating squares (180 degrees / 16 rotations)
            let amount = Double.pi / Double(rotations)
            
            // loops over 16 rotations, one by one
            for _ in 0 ..< rotations {
                // rotates each rectangle by amount (11.25)
                ctx.cgContext.rotate(by: CGFloat(amount))
                // adds a rectangle in each position, moving by -128 x and y coordinate, because we are drawing from the center of our canvace, back to point 256 x 256
                ctx.cgContext.addRect(CGRect(x: -128, y: -128, width: 256, height: 256))
            }
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            // default line width is 1
            ctx.cgContext.strokePath()
        }
        imageView.image = image
    }
    func drawLines() {
        // creating renderer that holds size
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        // calling image() method on renderer. It is a closure with one parameter called "ctx" (context)
        // this piece of code holds all the drawing
        let image = renderer.image { ctx in
            // moves transformation matrix to center
            ctx.cgContext.translateBy(x: 256, y: 256)
            
            var first = true
            var lenght: CGFloat = 256
            
            for _ in 0 ..< 256 {
                // rotates box by 90 degreese
                ctx.cgContext.rotate(by: .pi / 2)
                
                // if it is the first line, move(to:)
                if first {
                    ctx.cgContext.move(to: CGPoint(x: lenght, y: 50))
                    first = false
                    // if it is second, addLine(to:)
                } else {
                    ctx.cgContext.addLine(to: CGPoint(x: lenght, y: 50))
                }
                // decreese the lenght by small number to create spiral effect
                lenght *= 0.99
            }
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.strokePath()
        }
        imageView.image = image
    }
    
    func drawImagesAndText() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { ctx in
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .paragraphStyle: paragraphStyle,
                .font: UIFont.systemFont(ofSize: 36)
            ]
            
            let string = "The best-laid schemes o'\nmice an' men gang aft agley"
            let attributedString = NSAttributedString(string: string, attributes: attributes)
            
            attributedString.draw(with: CGRect(x: 32, y: 32, width: 448, height: 448), options: .usesLineFragmentOrigin, context: nil)
            
            let mouse = UIImage(named: "mouse")
            mouse?.draw(at: CGPoint(x: 300, y: 150))
        }
        imageView.image = image
    }
    // Challange 1. with imported png picture
    func drawSmiley() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { ctx in
            
            let smiley = UIImage(named: "smiley")
            smiley?.draw(at: CGPoint(x: 80, y: 100))
        }
        imageView.image = image
    }
    
    // Challange 1. easy
    func drawSmileyFace() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { ctx in
            // creates an edge of smiley
            
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512)
            ctx.cgContext.setFillColor(UIColor.yellow.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(5)
            ctx.cgContext.addEllipse(in: rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
            
            let eye = CGRect(x: 100, y: 180, width: 50, height: 50)
            ctx.cgContext.setFillColor(UIColor.black.cgColor)
            ctx.cgContext.addEllipse(in: eye)
            ctx.cgContext.drawPath(using: .fillStroke)
            
            let secondEye = CGRect(x: 360, y: 180, width: 50, height: 50)
            ctx.cgContext.setFillColor(UIColor.black.cgColor)
            ctx.cgContext.addEllipse(in: secondEye)
            ctx.cgContext.drawPath(using: .fillStroke)
            
           let mouth = CGRect(x: 160, y: 380, width: 180, height: 10)
            ctx.cgContext.setFillColor(UIColor.black.cgColor)
            ctx.cgContext.addRect(mouth)
            ctx.cgContext.drawPath(using: .fill)
        }
        
        imageView.image = image
    }
    // Challange 1. - hard
    func drawStar() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        // calling image() method on renderer. It is a closure with one parameter called "ctx" (context)
        // this piece of code holds all the drawing
        let image = renderer.image { ctx in
            // moves transformation matrix to center
            ctx.cgContext.translateBy(x: 256, y: 0)
            ctx.cgContext.setFillColor(UIColor.yellow.cgColor)
            
            // top triangle
            ctx.cgContext.move(to: CGPoint(x: 0, y: 0))
            ctx.cgContext.addLine(to: CGPoint(x: -96, y: 256))
            ctx.cgContext.addLine(to: CGPoint(x: 96, y: 256))
            ctx.cgContext.closePath()
            ctx.cgContext.drawPath(using: .fill)
            
            // left up triange
            ctx.cgContext.move(to: CGPoint(x: -256, y: 192))
            ctx.cgContext.addLine(to: CGPoint(x: 0, y: 180))
            ctx.cgContext.addLine(to: CGPoint(x: 0, y: 384))
            ctx.cgContext.closePath()
            ctx.cgContext.drawPath(using: .fill)
            
            // left down triangle
            ctx.cgContext.move(to: CGPoint(x: -256, y: 512))
            ctx.cgContext.addLine(to: CGPoint(x: 0, y: 128))
            ctx.cgContext.addLine(to: CGPoint(x: 0, y: 384))
            ctx.cgContext.closePath()
            ctx.cgContext.drawPath(using: .fill)
            
            // right down
            ctx.cgContext.move(to: CGPoint(x: 256, y: 512))
            ctx.cgContext.addLine(to: CGPoint(x: 0, y: 128))
            ctx.cgContext.addLine(to: CGPoint(x: 0, y: 384))
            ctx.cgContext.closePath()
            ctx.cgContext.drawPath(using: .fill)
               
            // left up triange
            ctx.cgContext.move(to: CGPoint(x: 256, y: 192))
            ctx.cgContext.addLine(to: CGPoint(x: 0, y: 180))
            ctx.cgContext.addLine(to: CGPoint(x: 0, y: 384))
            ctx.cgContext.closePath()
            ctx.cgContext.drawPath(using: .fill)
            
        }
        imageView.image = image
    }
    
    // Challange 2. - drawing TWIN on the screen
    func drawTwin() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        // calling image() method on renderer. It is a closure with one parameter called "ctx" (context)
        // this piece of code holds all the drawing
        let image = renderer.image { ctx in
            
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)

            //letter T:
             ctx.cgContext.move(to: CGPoint(x: 30, y: 55))
             ctx.cgContext.addLine(to: CGPoint(x: 131, y: 55))
             
             ctx.cgContext.move(to: CGPoint(x: 81, y: 50))
             ctx.cgContext.addLine(to: CGPoint(x: 81, y: 280))

             ctx.cgContext.drawPath(using: .stroke)

             //letter W:
             ctx.cgContext.move(to: CGPoint(x: 151, y: 50))
             ctx.cgContext.addLine(to: CGPoint(x: 165, y: 280))

             ctx.cgContext.move(to: CGPoint(x: 165, y: 280))
             ctx.cgContext.addLine(to: CGPoint(x: 180, y: 170))

             ctx.cgContext.move(to: CGPoint(x: 180, y: 170))
             ctx.cgContext.addLine(to: CGPoint(x: 195, y: 280))
             
             ctx.cgContext.move(to: CGPoint(x: 195, y: 280))
             ctx.cgContext.addLine(to: CGPoint(x: 210, y: 50))
            
            //letter I:
             ctx.cgContext.move(to: CGPoint(x: 250, y: 50))
             ctx.cgContext.addLine(to: CGPoint(x: 250, y: 280))
            
            //letter N:
             ctx.cgContext.move(to: CGPoint(x: 290, y: 50))
             ctx.cgContext.addLine(to: CGPoint(x: 290, y: 280))

             ctx.cgContext.move(to: CGPoint(x: 290, y: 50))
             ctx.cgContext.addLine(to: CGPoint(x: 330, y: 280))

             ctx.cgContext.move(to: CGPoint(x: 330, y: 280))
             ctx.cgContext.addLine(to: CGPoint(x: 330, y: 50))
             
             ctx.cgContext.drawPath(using: .stroke)
        }
        
        imageView.image = image
    }
    
}

