//
//  SpriteKitHelper.swift
//  gloopdrop
//
//  Created by Troy Martin on 6/16/24.
//  Copyright © 2024 Beef Erikson Studios. All rights reserved.
//

import Foundation
import SpriteKit

// MARK: - SPRITEKIT HELPERS

// Set up shared z-positions
enum Layer: CGFloat {
    case background
    case foreground
    case player
    case collectible
    case ui
}

// SpriteKit physics categories
enum PhysicsCategory {
    static let none:        UInt32 = 0
    static let player:      UInt32 = 0b1   // 1
    static let collectible: UInt32 = 0b10  // 2
    static let foreground:  UInt32 = 0b100 // 4
}

// MARK: - SPRITEKIT EXTENSIONS

extension SKNode {
    // Used to set up an endless scroller
    func setupScrollingView(imageNamed name: String, layer: Layer, 
                            emitterNamed: String?, blocks: Int, speed: TimeInterval) {
        // Create sprite nodes; set positions based on the node's # and width
        for i in 0..<blocks {
            let spriteNode = SKSpriteNode(imageNamed: name)
            spriteNode.anchorPoint = CGPoint.zero
            spriteNode.position = CGPoint(x: CGFloat(i) * spriteNode.size.width, y: 0)
            spriteNode.zPosition = layer.rawValue
            spriteNode.name = name
            
            // Set up optional particles
            if let emitterNamed = emitterNamed,
               let particles = SKEmitterNode(fileNamed: emitterNamed) {
                particles.name = "particles"
                spriteNode.addChild(particles)
            }
            
            // Use the custom extension to scroll
            spriteNode.endlessScroll(speed: speed)
            
            // Add the sprite node to the container
            addChild(spriteNode)
        }
    }
}

extension SKSpriteNode {
    // Used to create an endless scrolling background
    func endlessScroll(speed: TimeInterval) {
        // Set up actions to move and reset nodes
        let moveAction = SKAction.moveBy(x: -self.size.width, y: 0, duration: speed)
        let resetAction = SKAction.moveBy(x: self.size.width, y: 0, duration: 0.0)
        
        // Set up a sequence of repeating actions
        let sequenceAction = SKAction.sequence([moveAction, resetAction])
        let repeatAction = SKAction.repeatForever(sequenceAction)
        
        // Run the repeating action
        self.run(repeatAction)
    }
    
    // Load textures from an atlas.
    func loadTextures(atlas: String, prefix: String, startsAt: Int, stopsAt: Int) -> [SKTexture] {
        var textureArray = [SKTexture]()
        let textureAtlas = SKTextureAtlas(named: atlas)
        for i in  startsAt...stopsAt {
            let textureName = "\(prefix)\(i)"
            let temp = textureAtlas.textureNamed(textureName)
            textureArray.append(temp)
        }
        
        return textureArray
    }
    
    // Start the animation using a name and a count (0 = repeat forever)
    func startAnimation(textures: [SKTexture], speed: Double, name: String, count: Int, resize: Bool, restore: Bool) {
        
        // Run animation if animation key doesn't exist
        if (action(forKey: name) == nil) {
            let animation = SKAction.animate(with: textures, timePerFrame: speed, resize: resize, restore: restore)
            
            if count == 0 {
                // Run animation until stopped
                let repeatAction = SKAction.repeatForever(animation)
                run(repeatAction, withKey: name)
            } else if count == 1 {
                run(animation, withKey: name)
            } else {
                let repeatAction = SKAction.repeat(animation, count: count)
                run(repeatAction, withKey: name)
            }
        }
    }
}

// Convert top and bottom to Scene coordinates
extension SKScene {
    // Top of view
    func viewTop() -> CGFloat {
        return convertPoint(fromView: CGPoint(x: 0.0, y: 0)).y
    }
    
    // Bottom of view
    func viewBottom() -> CGFloat {
        guard let view = view else { return 0.0 }
        return convertPoint(fromView: CGPoint(x: 0.0, y: view.bounds.size.height)).y
    }
}
