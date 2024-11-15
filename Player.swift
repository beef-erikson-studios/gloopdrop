//
//  Player.swift
//  gloopdrop
//
//  Created by Troy Martin on 6/16/24.
//  Copyright © 2024 Beef Erikson Studios. All rights reserved.
//

import Foundation
import SpriteKit

// This enum lets you easily switch between animations
enum PlayerAnimationType : String {
    case walk
    case die
}

class Player : SKSpriteNode {
    // MARK: - PROPERTIES
    
    // Textures (Animation)
    private var walkTextures: [SKTexture]?
    private var dieTextures: [SKTexture]?
    
    // MARK: - INIT
    
    init() {
        
        // Set default texture
        let texture = SKTexture(imageNamed: "blob-walk_0")
        
        // Call to super.init
        super.init(texture: texture, color: .clear, size: texture.size())
        
        // Set up animation textures
        self.walkTextures = self.loadTextures(atlas: "blob", prefix: "blob-walk_", startsAt: 0, stopsAt: 2)
        self.dieTextures = self.loadTextures(atlas: "blob", prefix: "blob-die_", startsAt: 0, stopsAt: 0)
        
        // Set up other properties after init
        self.name = "player"
        self.setScale(1.0)
        self.anchorPoint = CGPoint(x: 0.5, y: 0.0) // center-bottom
        self.zPosition = Layer.player.rawValue
        
        // Add physics body
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size, center: CGPoint(x: 0.0, y: self.size.height / 2)) // offset
        self.physicsBody?.affectedByGravity = false
        
        // Set up physics categories for contacts
        self.physicsBody?.categoryBitMask = PhysicsCategory.player
        self.physicsBody?.contactTestBitMask = PhysicsCategory.collectible
        self.physicsBody?.collisionBitMask = PhysicsCategory.none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - METHODS
    
    // Player constraints
    func setupConstraints(floor: CGFloat) {
        let range = SKRange(lowerLimit: floor, upperLimit: floor)
        let lockToPlatform = SKConstraint.positionY(range)
        
        constraints = [ lockToPlatform ]
    }
    
    // Make the blob mumble
    func mumble() {
        let random = Int.random(in: 1...3)
        let playSound = SKAction.playSoundFileNamed("blob_mumble-\(random)", waitForCompletion: true)
        self.run(playSound, withKey: "mumble")
    }
    
    // Walking animation
    func walk() {
        // Load textures
        guard let walkTextures = walkTextures else {
            preconditionFailure("Could not find textures!")
        }
        
        // Stop the death animation
        removeAction(forKey: PlayerAnimationType.die.rawValue)
        
        // Run animation (forever)
        startAnimation(textures: walkTextures, speed: 0.25, 
                       name: PlayerAnimationType.walk.rawValue,
                       count: 0, resize: true, restore: true)
    }
    
    // Death animation
    func die() {
        // Check for textures
        guard let dieTextures = dieTextures else {
            preconditionFailure("Could not find textures!")
        }
        
        // Stop the walk animation
        removeAction(forKey: PlayerAnimationType.walk.rawValue)
        
        // Run death animation forever
        startAnimation(textures: dieTextures, speed: 0.25,
                       name: PlayerAnimationType.die.rawValue,
                       count: 0, resize: true, restore: true)
    }
    
    // Moves where touched
    func moveToPosition(pos: CGPoint, direction: String, speed: TimeInterval) {
        // Sprite facing direction
        switch direction {
        case "Left":
            xScale = -abs(xScale)
        default:
            xScale = abs(xScale)
        }
        
        // Move
        let moveAction = SKAction.move(to: pos, duration: speed)
        run(moveAction)
    }
}
