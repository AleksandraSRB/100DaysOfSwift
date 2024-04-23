//
//  ViewController.swift
//  Challange 28, 29, 30
//
//  Created by Aleksandra Sobot on 8.4.24..
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet var buttonsView: UIView!
    @IBOutlet var player1: UILabel!
    @IBOutlet var player2: UILabel!
    @IBOutlet var playerNumber: UILabel!
    
    
    var cardButtons = [UIButton]()
    var images = [String]()
//    var images2 = ["kiss-face", "laughter-face", "lying-face", "melting-face", "monkey-face", "monocle-face", "nerd-face", "partying-face", "sunglasses-face", "thermometer-face"]
    
    var selectedImages = [UIButton]()
    var guessedImages = [UIButton]()

    var currentPlayer = 1
 
    var player1Score = 0 {
        didSet {
            player1.text = "PLAYER 1 SCORE: \(player1Score)"
        }
    }
    
    var player2Score = 0 {
        didSet {
            player2.text = "PLAYER 2 SCORE: \(player2Score)"
        }
    }
  

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadGame()
        
        player1.text = "PLAYER 1 SCORE: 0"
        player2.text = "PLAYER 2 SCORE: 0"
    
    }
    
    func setupButtons() {
        view.backgroundColor = UIColor(hue: 0.7, saturation: 0.5, brightness: 0.6, alpha: 1)
        buttonsView.backgroundColor = UIColor(hue: 0.7, saturation: 0.5, brightness: 0.6, alpha: 1)
        
        let widthSpace = 70
        let heightSpace = 10
        let width = 100
        let height = 130
        
        for row in 0..<4 {
            for column in 0..<5 {
                let cardButton = UIButton(type: .system)
                cardButton.layer.cornerRadius = 20
                cardButton.layer.borderWidth = 2
                
                
                if !images.isEmpty {
                    cardButton.setImage(UIImage(named: images[0]), for: .normal)
                    cardButton.setTitle(images[0], for: .normal)
                    cardButton.setImage(UIImage(named: "back"), for: .normal)
                    cardButton.imageView?.contentMode = .scaleAspectFill
                    cardButton.clipsToBounds = true
                    cardButton.backgroundColor = .white
                    images.remove(at: 0)
                    
                }
                
                cardButton.addTarget(self, action: #selector(cardButtonTapped), for: .touchUpInside)
                
                let frame = CGRect(x: column * (width + widthSpace), y: row * (height + heightSpace), width: width, height: height)
                cardButton.frame = frame
                
                cardButtons.append(cardButton)
                buttonsView.addSubview(cardButton)
                
            }
        }
        
    }
    
    
    @objc func cardButtonTapped(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            sender.transform = CGAffineTransform(scaleX: 0.001, y: 1)
            
        }, completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                sender.setImage(UIImage(named: (sender.titleLabel?.text)!), for: .normal)
            }
        })
        
        UIView.animate(withDuration: 0.2, delay: 0.3, options: [], animations: {
            sender.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
        
       
        selectedImages.append(sender)
        
        if selectedImages.count == 2 {
            for button in cardButtons {
                button.isEnabled = false
            }
            if selectedImages[0].title(for: .normal) == selectedImages[1].title(for: .normal) {
                guessedImages.append(selectedImages[0])
                guessedImages.append(selectedImages[1])
           
                for _ in selectedImages {
                    selectedImages.removeAll()

                    for image in guessedImages {
                        hideCard(image)
                    }
                    
                }
                if currentPlayer == 1 {
                    player1Score += 1
                } else {
                   player2Score += 1
                }
                changePlayer()
            } else {
                flipBackCard()
                changePlayer()
                for button in cardButtons {
                    button.isEnabled = true
                }
            }
            
        }
        
        if guessedImages.count == 20 {
            gameOver()
        }
    }
      
    
    func loadGame() {
        
        cardButtons.removeAll()
        images.removeAll()
        selectedImages.removeAll()
        guessedImages.removeAll()
        images = ["angel-face", "angry-face", "clown-face", "cold-face", "coveredEars-monkey", "coveredMouth-monkey", "coverEyes-monkey", "cowboy-hat-face", "crying-face", "heartEyes-face", "angel-face", "angry-face", "clown-face", "cold-face", "coveredEars-monkey", "coveredMouth-monkey", "coverEyes-monkey", "cowboy-hat-face", "crying-face", "heartEyes-face"]
        images.shuffle()
        setupButtons()
        
        player1Score = 0
        player2Score = 0
    }
    
    func flipBackCard() {

        for image in selectedImages {
            UIView.animate(withDuration: 0.2, delay: 2, options: [], animations: {
                image.transform = CGAffineTransform(scaleX: 0.001, y: 1)
            }, completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    image.setImage(UIImage(named: ("back")), for: .normal)
                }
               
            })
            
            UIView.animate(withDuration: 0.2, delay: 2.5, options: [], animations: {
                image.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.selectedImages.removeAll()
            })

        }
        
    }
    
    func hideCard(_: UIButton) {
        for item in guessedImages {
            UIView.animate(withDuration: 0.5, delay: 1, options: [], animations: {
                item.transform = CGAffineTransform(scaleX: 0.001, y: 1)
            }, completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    item.isHidden = true
                }
            })
        }
    }
    
    func changePlayer() {
        for button in cardButtons {
            button.isEnabled = true
        }
        if currentPlayer == 1 {
            currentPlayer = 2
        } else {
            currentPlayer = 1
        }
        activatePlayer(number: currentPlayer)
    }
   
    
    func activatePlayer(number: Int) {
        if number == 1 {
            playerNumber.text = "<<< PLAYER ONE"
        } else {
            playerNumber.text = "PLAYER TWO >>>"
        }
    }
    
    func gameOver() {
        
        let ac = UIAlertController(title: "GREAT JOB!", message: "Do you want to start a new game?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "NEW GAME", style: .default) {
            [weak self] _ in
            self?.loadGame()
        })
        ac.addAction(UIAlertAction(title: "QUIT", style: .cancel))
        present(ac, animated: true)
        
    }

}



