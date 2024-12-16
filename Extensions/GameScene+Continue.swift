//
//  GameScene+Continue.swift
//  gloopdrop
//
//  Created by Troy Martin on 12/16/24.
//  Copyright © 2024 Beef Erikson Studios. All rights reserved.
//

import SpriteKit

extension GameScene {
    
    /// Sets up the Continue and Ad buttons.
    func setupContunues() {
        watchAdButton.name = "watchAd"
        watchAdButton.setScale(0.75)
        watchAdButton.zPosition = Layer.ui.rawValue
        watchAdButton.position = CGPoint(x: startGameButton.frame.maxX + 75,
                                         y: startGameButton.frame.midY - 25)
        addChild(watchAdButton)
        
        continueGameButton.name = "continue"
        continueGameButton.setScale(0.85)
        continueGameButton.zPosition = Layer.ui.rawValue
        continueGameButton.position = CGPoint(x: frame.maxX - 75,
                                              y: viewBottom() + 60)
        addChild(continueGameButton)
        
        updateContinueButton()
    }
    
    func updateContinueButton() {
        if numberOfFreeContinues > maxNumberOfContinues {
            let texture = SKTexture(imageNamed: "continueRemaining-max")
            continueGameButton.texture = texture
        } else {
            let texture = SKTexture(imageNamed: "continueRemaining-\(numberOfFreeContinues)")
            continueGameButton.texture = texture
        }
    }
}
