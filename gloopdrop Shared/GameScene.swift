import AVFoundation
import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // Player properties
    let player: Player = Player()
    let playerSpeed: CGFloat = 1.5
    var movingPlayer = false
    var lastPosition: CGPoint?
    
    // Game states
    var gameInProgress: Bool = false
    
    // Level and score property observers
    var level: Int = 1 {
        didSet {
            levelLabel.text = "Level: \(level)"
        }
    }
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    // Drop properties
    var numberOfDrops: Int = 10
    var dropsExpected: Int = 10
    var dropsCollected: Int = 0
    var dropSpeed: CGFloat = 1.0
    var minDropSpeed: CGFloat = 0.12 // fastest
    var maxDropSeed: CGFloat = 1.0 // slowest
    var previousDropLocation: CGFloat = 0.0
    
    // Label properties
    var scoreLabel: SKLabelNode = SKLabelNode()
    var levelLabel: SKLabelNode = SKLabelNode()
    
    // Audio nodes
    let musicAudioNode = SKAudioNode(fileNamed: "music.mp3")
    let bubblesAudioNode = SKAudioNode(fileNamed: "bubbles.mp3")
    
    // Start game button
    let startGameButton = SKSpriteNode(imageNamed: "start")
    
    // MARK: - Overrides
    
    override func didMove(to view: SKView) {
        // Decrease the audio engine's volume for fade-in
        audioEngine.mainMixerNode.outputVolume = 0.0
        
        // Set up the background music audio node
        musicAudioNode.autoplayLooped = true
        musicAudioNode.isPositional = false
        
        // Add audio node to the scene
        addChild(musicAudioNode)
        
        // Use an action to adjust the audio node's volume to 0
        musicAudioNode.run(SKAction.changeVolume(to: 0.0, duration: 0.0))
        
        // Run a delayed action on the scene that fades in the music
        run(SKAction.wait(forDuration: 1.0), completion: { [unowned self] in
            self.audioEngine.mainMixerNode.outputVolume = 1.0
            self.musicAudioNode.run(SKAction.changeVolume(to: 0.65, duration: 2.0))
        })
        
        // Run a delayed action to add bubble audio to the scene
        run(SKAction.wait(forDuration: 1.5), completion: { [unowned self] in
            self.bubblesAudioNode.autoplayLooped = true
            self.bubblesAudioNode.run(SKAction.changeVolume(to: 0.65, duration: 2.0))
            self.addChild(self.bubblesAudioNode)
        })
        
        // Set up the physcis world contact delegate
        physicsWorld.contactDelegate = self
        
        // Set up a background
        let background = SKSpriteNode(imageNamed: "backgroundSewer")
        background.name = "background"
        background.anchorPoint = CGPoint.zero
        background.zPosition = Layer.background.rawValue
        background.position = CGPoint.zero
        background.scale(to: CGSize(width: 1336, height: 1024))
        
        addChild(background)
        
        // Set up a foreground
        let foreground = SKSpriteNode(imageNamed: "foreground_1")
        foreground.name = "foreground"
        foreground.anchorPoint = CGPoint.zero
        foreground.zPosition = Layer.foreground.rawValue
        foreground.position = CGPoint.zero
        
        // Physics start
        foreground.physicsBody = SKPhysicsBody(edgeLoopFrom: foreground.frame)
        foreground.physicsBody?.affectedByGravity = false
        
        // Set up physics categories for contacts
        foreground.physicsBody?.categoryBitMask = PhysicsCategory.foreground
        foreground.physicsBody?.contactTestBitMask = PhysicsCategory.collectible
        foreground.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        addChild(foreground)
        
        // Set up the banner
        let banner = SKSpriteNode(imageNamed: "banner")
        banner.zPosition = Layer.background.rawValue + 1
        banner.position = CGPoint(x: frame.midX, y: viewTop() - 20)
        banner.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        addChild(banner)
        
        // Set up the UI
        setupLabels()
        setupStartButton()
        
        // Set up player
        player.position = CGPoint(x: size.width/2, y: foreground.frame.maxY)
        player.setupConstraints(floor: foreground.frame.maxY)
        addChild(player)
        
        // Show message
        showMessage("Tap to start game")
        
        // Set up the gloop flow
        setupGloopFlow()
    }
    
    
    // MARK: - Gloop Flow & Particle Effects
    
    func setupGloopFlow() {
        // Set up flowing goop
        let gloopFlow = SKNode()
        gloopFlow.name = "gloopFlow"
        gloopFlow.zPosition = Layer.foreground.rawValue
        gloopFlow.position = CGPoint(x: 0.0, y: -60)
        
        // Use extension for endless scrolling
        gloopFlow.setupScrollingView(imageNamed: "flow_1",
                                     layer: Layer.foreground,
                                     emitterNamed: "GloopFlow.sks",
                                     blocks: 3, speed: 30.0)
        
        // Add flow to the scene
        addChild(gloopFlow)
    }
    
    
    // MARK: - GAME FUNCTIONS
    
    /* ################################################## */
    /*             GAME FUNCTIONS START HERE              */
    /* ################################################## */
    
    func setupLabels() {
        /* SCORE LABEL */
        scoreLabel.name = "score"
        scoreLabel.fontName = "Nosifer"
        scoreLabel.fontColor = .blue
        scoreLabel.fontSize = 35.0
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.zPosition = Layer.ui.rawValue
        scoreLabel.position = CGPoint(x: frame.maxX - 50, y: viewTop() - 100)
        
        // Set the text and add the label node to the scene
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)
        
        /* LEVEL LABEL */
        levelLabel.name = "level"
        levelLabel.fontName = "Nosifer"
        levelLabel.fontColor = .blue
        levelLabel.fontSize = 35.0
        levelLabel.horizontalAlignmentMode = .left
        levelLabel.verticalAlignmentMode = .center
        levelLabel.zPosition = Layer.ui.rawValue
        levelLabel.position = CGPoint(x: frame.minX + 50, y: viewTop() - 100)
        
        // Set the text and add the label node to the scene
        levelLabel.text = "Level: \(level)"
        addChild(levelLabel)
    }
    
    ///  Sets position, scale, animation, and initialization of the start game button.
    func setupStartButton() {
        startGameButton.name = "start"
        startGameButton.setScale(0.55)
        startGameButton.zPosition = Layer.ui.rawValue
        startGameButton.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(startGameButton)
        
        // Animation
        let scaleUp = SKAction.scale(to: 0.55, duration: 0.65)
        let scaleDown = SKAction.scale(to: 0.50, duration: 0.65)
        let playBounce = SKAction.sequence([scaleDown, scaleUp])
        let bounceRepeat = SKAction.repeatForever(playBounce)
        startGameButton.run(bounceRepeat)
    }
    
    func showStartButton() {
        startGameButton.run(SKAction.fadeIn(withDuration: 0.25))
    }
    
    func hideStartButton() {
        startGameButton.run(SKAction.fadeOut(withDuration: 0.25))
    }
    
    func showMessage(_ message: String) {
        // Set up message label
        let messageLabel = SKLabelNode()
        messageLabel.name = "message"
        messageLabel.position = CGPoint(x: frame.midX, y: frame.midY + startGameButton.size.height/2)
        messageLabel.zPosition = Layer.ui.rawValue
        messageLabel.numberOfLines = 2
        
        // Set up attributed text
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.red,
            .backgroundColor: UIColor.clear,
            .font: UIFont(name: "Nosifer", size: 45.0)!,
            .paragraphStyle: paragraph
        ]
        
        messageLabel.attributedText = NSAttributedString(string: message, attributes: attributes)
        
        // Run a fade action and add the label to the scene
        messageLabel.run(SKAction.fadeIn(withDuration: 0.25))
        addChild(messageLabel)
    }
    
    func hideMessage() {
        // Remove message label if it exists
        if let messageLabel = childNode(withName: "//message") as? SKLabelNode {
            messageLabel.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.25),
                                                SKAction.removeFromParent()]))
        }
    }
    
    func spawnGloop() {
        let collectible = Collectible(collectibleType: CollectibleType.gloop)
        
        // Sets random gloop position
        let margin = collectible.size.width * 2
        let dropRange = SKRange(lowerLimit: frame.minX + margin, upperLimit: frame.maxX - margin)
        var randomX = CGFloat.random(in: dropRange.lowerLimit...dropRange.upperLimit)
        
        /* START ENHANCED DROP MOVEMENT - a "snake-like" pattern to ease difficulty */
        
        // Set a range
        let randomModifier = SKRange(lowerLimit: 50 + CGFloat(level),
                                     upperLimit: 60 * CGFloat(level))
        var modifier = CGFloat.random(in: randomModifier.lowerLimit...randomModifier.upperLimit)
        if modifier > 400 { modifier = 400 }
        
        // Set the previous drop location
        if previousDropLocation == 0.0 {
            previousDropLocation = randomX
        }
        
        // Clamp its x-position
        if previousDropLocation < randomX {
            randomX = previousDropLocation + modifier
        } else {
            randomX = previousDropLocation - modifier
        }
        
        // Make sure the collectible stays in frame
        if randomX <= (frame.minX + margin) {
            randomX = frame.minX + margin
        } else if randomX >= (frame.maxX - margin) {
            randomX = frame.maxX - margin
        }
        
        // Store the location
        previousDropLocation = randomX
        
        /* END ENHANCED DROP MOVEMENT*/
        
        // Add the number tag to the collectible drop
        let xLabel = SKLabelNode()
        xLabel.name = "dropNumber"
        xLabel.fontName = "AvenirNext-DemiBold"
        xLabel.fontColor = UIColor.red
        xLabel.fontSize = 22.0
        xLabel.text = "\(numberOfDrops)"
        xLabel.position = CGPoint(x: 0, y: 2)
        
        // Display the tag and decrease drop count
        collectible.addChild(xLabel)
        numberOfDrops -= 1
        
        // Spawns the collectible drop
        collectible.position = CGPoint(x: randomX, y: player.position.y * 2.5)
        addChild(collectible)
        
        collectible.drop(dropSpeed: TimeInterval(1.0), floorLevel: player.frame.minY)
    }
    
    func spawnMultipleGloops() {
        // Play the mumble sound
        player.mumble()
        
        // Reset walk cycle
        player.walk()
        
        // Reset the level and score
        if gameInProgress == false {
            score = 0
            level = 1
        }
        
        // Set number of drops based on the level
        switch level {
            case 1...5:
                numberOfDrops = level * 10
            case 6:
                numberOfDrops = 75
            case 7:
                numberOfDrops = 100
            case 8:
                numberOfDrops = 150
            default:
                numberOfDrops = 150
        }
        
        // Reset and update the collected and expected drop counts
        dropsCollected = 0
        dropsExpected = numberOfDrops
        
        // Set up drop speed based on level
        dropSpeed = 1 / (CGFloat(level) + (CGFloat(level) / CGFloat(numberOfDrops)))
        if dropSpeed < minDropSpeed {
            dropSpeed = minDropSpeed
        }
        else if dropSpeed > maxDropSeed {
            dropSpeed = maxDropSeed
        }
        
        // Set up repeating action
        let wait = SKAction.wait(forDuration: TimeInterval(dropSpeed))
        let spawn = SKAction.run { [unowned self] in self.spawnGloop() }
        let sequence = SKAction.sequence([wait, spawn])
        let repeatAction = SKAction.repeat(sequence, count: numberOfDrops)
        
        // Update game state
        gameInProgress = true
        
        // Run action
        run(repeatAction, withKey: "gloop")
        
        // Hide center message and start button
        hideMessage()
        hideStartButton()
    }
    
    func checkForRemainingDrops() {
        if dropsCollected == dropsExpected {
            nextLevel()
        }
    }
    
    // Player passed level
    func nextLevel() {
        // Show message
        showMessage("Get Ready!")
        
        let wait = SKAction.wait(forDuration: 2.25)
        run(wait, completion: {[unowned self] in self.level += 1
            self.spawnMultipleGloops()})
    }
    
    // Player lost
    func gameOver() {
        // Show message
        showMessage("Game Over\nTap to try again")
        
        // Update game status
        gameInProgress = false
        
        // Start player death animation
        player.die()
        
        // Reset game
        resetPlayerPosition()
        popRemainingDrops()
        showStartButton()
        
        // Remove repeatable action on main scene
        removeAction(forKey: "gloop")
        
        // Loop through child nodes and stop actions on collectibles
        enumerateChildNodes(withName: "//co_*") {
            (node, stop) in
            
            // Stop and remove drops
            node.removeAction(forKey: "drop") // remove action
            node.physicsBody = nil // remove body so no collisions occur
        }
    }
    
    func resetPlayerPosition() {
        let resetPoint = CGPoint(x: frame.midX, y: player.position.y)
        let distance = hypot(resetPoint.x - player.position.x, 0)
        let calculatedSpeed = TimeInterval(distance / (playerSpeed * 2)) / 255
        
        if player.position.x > frame.midX {
            player.moveToPosition(pos: resetPoint, direction: "L", speed: calculatedSpeed)
        } else {
            player.moveToPosition(pos: resetPoint, direction: "R", speed: calculatedSpeed)
        }
    }
    
    func popRemainingDrops() {
        var i = 0
        enumerateChildNodes(withName: "//co_*") {
            (node, stop) in
            
            // Pop remaining drops in sequence
            let initialWait = SKAction.wait(forDuration: 1.0)
            let wait = SKAction.wait(forDuration: TimeInterval(0.15 * CGFloat(i)))
            let removeFromParent = SKAction.removeFromParent()
            
            let actionSequence = SKAction.sequence([initialWait, wait, removeFromParent])
            
            node.run(actionSequence)
            
            i += 1
        }
    }

    
    // MARK: - TOUCH HANDLING
    
    // Detects if player should move
    func touchDown(atPoint pos: CGPoint) {
        let touchedNodes = nodes(at: pos)
        for touchedNode in touchedNodes {
            if touchedNode.name == "player" && gameInProgress == true {
                movingPlayer = true
            }
            else if touchedNode == startGameButton && gameInProgress == false {
                spawnMultipleGloops()
                return
            }
        }
    }
    
    // Moves the player
    func touchMoved(toPoint pos: CGPoint) {
        if movingPlayer == true {
            // Clamp position to floor
            let newPos = CGPoint(x: pos.x, y: player.position.y)
            player.position = newPos
            
            // Check last position; if empty set it to player position
            let recordedPosition = lastPosition ?? player.position
            if recordedPosition.x > newPos.x {
                player.xScale = -abs(xScale)
            } else {
                player.xScale = abs(xScale)
            }
            
            // Save last known position
            lastPosition = newPos
        }
    }
    
    // Stop player - touch released
    func touchUp(atPoint pos: CGPoint) {
        movingPlayer = false
    }
    
    
    // Touch start
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    // Touch move
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    // Touch stopped
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    // Touch cancelled
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
}

// MARK: - COLLISION DETECTION

/* ########################################################## */
/*           COLLISION DETECTION METHODS START HERE           */
/* ########################################################## */

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        // Check collision bodies
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        // Did the [PLAYER] collide with the [COLLECTIBLE]?
        if collision == PhysicsCategory.player | PhysicsCategory.collectible {
            // Find out which body is attached to the collectible node
            let body = contact.bodyA.categoryBitMask == PhysicsCategory.collectible ? 
              contact.bodyA.node :
              contact.bodyB.node
            
            // Verify the object is a collectible
            if let sprite = body as? Collectible {
                sprite.collected()
                dropsCollected += 1
                score += level
                checkForRemainingDrops()
                
                // Add the 'chomp' text at the player's position
                let chomp = SKLabelNode(fontNamed: "Nosifer")
                chomp.name = "chomp"
                chomp.alpha = 0.0
                chomp.fontSize = 22.0
                chomp.text = "gloop"
                chomp.horizontalAlignmentMode = .center
                chomp.verticalAlignmentMode = .bottom
                chomp.position = CGPoint(x: player.position.x, y: player.frame.maxY + 25)
                chomp.zRotation = CGFloat.random(in: -0.15...0.15)
                addChild(chomp)
                
                // Add actions to fade in, rise up, and fade out
                let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.05)
                let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.45)
                let moveUp = SKAction.moveBy(x: 0.0, y: 45.0, duration: 0.45)
                let groupAction = SKAction.group([fadeOut, moveUp])
                let removeFromParent = SKAction.removeFromParent()
                let chompAction = SKAction.sequence([fadeIn, groupAction, removeFromParent])
                chomp.run(chompAction)
            }
        }
        
        // Or did the [COLLECTIBLE] collide with the [FOREGROUND]?
        if collision == PhysicsCategory.foreground | PhysicsCategory.collectible {
            // Find out which body is attached to the collectible node
            let body = contact.bodyA.categoryBitMask == PhysicsCategory.collectible ? 
              contact.bodyA.node :
              contact.bodyB.node
            
            // Verify the object is a collectible
            if let sprite = body as? Collectible {
                sprite.missed()
                gameOver()
            }
        }
    }
}
