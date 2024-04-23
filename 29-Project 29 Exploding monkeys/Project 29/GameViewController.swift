//
//  GameViewController.swift
//  Project 29
//
//  Created by Aleksandra Sobot on 1.4.24..
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    // we are creating reference to GameScene so the to controllers could communicate, it already has strong reference, so the reference of ViewController in GameScene will be weak
    var currentGame: GameScene?
    

    @IBOutlet var angleSlider: UISlider!
    @IBOutlet var velocitySlider: UISlider!
    @IBOutlet var angleLabel: UILabel!
    @IBOutlet var velocityLabel: UILabel!
    @IBOutlet var playerNumber: UILabel!
    @IBOutlet var launchButton: UIButton!
    
    @IBOutlet var player1ScoreLabel: UILabel!
    @IBOutlet var player2ScoreLabel: UILabel!
    
    @IBOutlet var windLabel: UILabel!
    
    // Challange 1. - Tracking players score throught levels
    var player1Score = 0 {
        didSet {
            player1ScoreLabel.text = "Score: \(player1Score)"
        }
    }
    
    var player2Score = 0 {
        didSet {
            player2ScoreLabel.text = "Score: \(player2Score)"
        }
    }
    
    var isGameOver = false
  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                
                currentGame = scene as? GameScene
                if isGameOver == false {
                    currentGame?.viewController = self
                    
                    player1ScoreLabel.text = "Score: 0"
                    player2ScoreLabel.text = "Score: 0"   
                    currentGame?.generateRandomWind()
                }
                
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        angleChanged(self)
        velocityChanged(self)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func angleChanged(_ sender: Any) {
        angleLabel.text = "Angle: \(Int(angleSlider.value))°"
    }
    
    @IBAction func velocityChanged(_ sender: Any) {
        velocityLabel.text = "Velocity: \(Int(velocitySlider.value))"
    }
    
    @IBAction func launch(_ sender: Any) {
        angleSlider.isHidden = true
        angleLabel.isHidden = true
        velocitySlider.isHidden = true
        velocityLabel.isHidden = true
//        player1ScoreLabel.isHidden = true
//        player2ScoreLabel.isHidden = true
        windLabel.isHidden = true
        
        launchButton.isHidden = true
        
        currentGame?.launch(angle: Int(angleSlider.value), velocity: Int(velocitySlider.value))
        
    }
    
    func activatePlayer(number: Int) {
        if number == 1 {
            playerNumber.text = "<<< PLAYER ONE"
        } else {
            playerNumber.text = "PLAYER TWO >>>"
        }
        
        angleSlider.isHidden = false
        angleLabel.isHidden = false
        velocitySlider.isHidden = false
        velocityLabel.isHidden = false
        player1ScoreLabel.isHidden = false
        player2ScoreLabel.isHidden = false
        windLabel.isHidden = false
        
        launchButton.isHidden = false
    }
    
}
