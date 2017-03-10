//
//  GameScene.swift
//  Subpar Soccer
//
//  Created by James Dassoulas on 2016-06-09.
//  Copyright (c) 2016 Jetliner. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var gameball : SKSpriteNode! // The sprite of the game ball
    let controlBallShape = SKShapeNode(circleOfRadius: 70) // The node to draw a circle around the control ball
    var controlBall : SKSpriteNode! // The control ball node itself
    var oppositionArray:[SKShapeNode] = [SKShapeNode]() // Array to contain the nodes of the opposition players
    var ballRollingFrames : [SKTexture]! // Texture for the rolling ball animation
    var firstTouch: CGPoint = CGPoint(x: 0.0, y: 0.0)
    var controlTouch: CGPoint = CGPoint(x: 0.0, y: 0.0)
    var distance = CGFloat() // Distance from the initial touch to the dragged location
    let lineDots = SKShapeNode(circleOfRadius: 5) // Initial node to draw the projected path of the ball
    var lineAngle = CGFloat() // Angle of the initial projected path
    var dx1 = CGFloat(), dy1 = CGFloat() // Distance from initial touch `x` and `y` to dragged co-ordinates
    var dotNodes : [SKShapeNode] = [] // Array to hold all nodes in the projected path
    var dotPath = CGMutablePath() // Initial projected path
    var dotLine = SKShapeNode() // The drawn line of the initial projected path
    var touched:Bool = false // Is there an active touch
    var kicked:Bool = false // Has the ball been kicked
    var ballAngle: CGFloat = 0.0, ballSpeed: CGFloat = 0.0, shotAngle: CGFloat = 0.0, shotSpeed: CGFloat = 0.0, shotSpin: CGFloat = 0.0 // Initial values of the ball's kinematic properties
    var angularDamping: CGFloat = 1.0, linearDamping: CGFloat = 0.5 // Initial values of the ball's physical properties
    var vZ: CGFloat = 0.0 // Velocity of the ball in the z-plane
    var Z: CGFloat = 0.0 // Position of the ball in the z-plane
    let contactPoint = SKShapeNode(circleOfRadius: 10) // Reticle of the contact point on the ball
    
    func setupLevel(){
        initGameBall()
        addOpposition()
    }
    
    /**
     Set-up the initial properties of the game ball sprite as well as its physics properties.
     */
     func initGameBall(){
        gameball.position = CGPoint(x: self.frame.midX, y: self.frame.midY-300)
        gameball.zPosition = 1
        gameball.size = CGSize (width: 15, height: 15)
        gameball.name = "ball"
        
        gameball.physicsBody = SKPhysicsBody(circleOfRadius: 7.5)
        gameball.physicsBody?.isDynamic = true
        gameball.physicsBody?.affectedByGravity = false
        gameball.physicsBody?.allowsRotation = true
        gameball.physicsBody?.friction = 0.5
        gameball.physicsBody?.restitution = 0
        gameball.physicsBody?.linearDamping = linearDamping
        gameball.physicsBody?.angularDamping = angularDamping
        gameball.physicsBody?.mass = 4.3
        gameball.physicsBody?.velocity = CGVector(dx: 0,dy: 0)
    }
    
    /**
     Add 10 opposing 'players' as circuular SKShapeNodes in a roughly 4-4-2 formation. The location of the players is randomly assigned within the bounds of that player's position on the pitch.
     */
    func addOpposition(){
        for node in oppositionArray
        {
            node.removeFromParent()
        }
        oppositionArray = [SKShapeNode]() 
        
        let x1s: Array<Float> = [0.0,165.0,330.0,495.0,
                                 0.0,165.0,330.0,495.0,
                                 165.0,330.0]
        let x2s: Array<Float> = [165.0,330.0,495.0,660.0,
                                 165.0,330.0,495.0,660.0,
                                 330.0,495.0]
        let y1s: Array<Float> = [688.0,688.0,688.0,688.0,
                                 430.0,430.0,430.0,430.0,
                                 200.0,200.0]
        let y2s: Array<Float> = [860.0,860.0,860.0,860.0,
                                 688.0,688.0,688.0,688.0,
                                 344.0,344.0]
        let names: Array<String> = ["DR","DCR","DCL","DL",
                                    "MR","MCR","MCL","ML",
                                    "FR","FL"]
        let xOffset: Int = 45
        let yOffset: Int = 258
        
        for i in 0 ..< 10 {
            let xlow: Int = Int(x1s[i])+xOffset
            let xhigh: Int = Int(x2s[i])+xOffset
            let ylow: Int = Int(y1s[i])+yOffset
            let yhigh: Int = Int(y2s[i])+yOffset
            let xPosition = CGFloat(randomIntFrom(xlow, to: xhigh))
            let yPosition = CGFloat(randomIntFrom(ylow, to: yhigh))
            let oppositionPlayer = SKShapeNode(circleOfRadius: 15)
            oppositionPlayer.fillColor = UIColor.red
            oppositionPlayer.strokeColor = UIColor.black
            oppositionPlayer.lineWidth = 3
            oppositionPlayer.zPosition = 1
            oppositionPlayer.position = CGPoint(x:xPosition, y: yPosition)
            oppositionPlayer.name = names[i]
            self.addChild(oppositionPlayer)
            
            oppositionArray.append(oppositionPlayer)
        }
        
    }
    
    /**
     Add initial nodes and setup the level.
     */
    override func didMove(to view: SKView) {
        controlBall = SKSpriteNode(texture: SKTexture(imageNamed: "ball.png"))
        controlBall.position = CGPoint(x:self.frame.midX, y: 109)
        controlBall.zPosition = 1
        self.addChild(controlBall)
        
        controlBallShape.name = "controlBall"
        controlBallShape.fillColor = UIColor.clear
        controlBallShape.strokeColor = UIColor.blue
        controlBallShape.lineWidth = 0
        controlBallShape.zPosition = 2
        controlBallShape.position = CGPoint(x:self.frame.midX, y: 109)
        self.addChild(controlBallShape)
        
        contactPoint.name = "contactPoint"
        contactPoint.fillColor = UIColor.clear
        contactPoint.strokeColor = UIColor.red
        contactPoint.lineWidth = 5
        contactPoint.position = controlBall.position
        controlTouch = controlBall.position
        contactPoint.zPosition = 3
        self.addChild(contactPoint)
        
        lineDots.zPosition = 1
        lineDots.strokeColor = SKColor.red
        lineDots.fillColor = SKColor.red
        
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody

        let ballAnimatedAtlas = SKTextureAtlas(named: "rollingBall")
        var rollFrames = [SKTexture]()
        
        for ballTexture in ballAnimatedAtlas.textureNames{
            rollFrames.append(ballAnimatedAtlas.textureNamed(ballTexture))
        }
        
        ballRollingFrames = rollFrames
        let firstFrame = ballRollingFrames[0]
        gameball = SKSpriteNode(texture: firstFrame)
        setupLevel()
        self.addChild(gameball)
        
    }
    
    /**
     Animates the rolling of the ball in motion.
     */
    func rollingball() {
        let rollball = SKAction.animate(with: ballRollingFrames,
                                                    timePerFrame: 3,
                                                    resize: false,
                                                    restore: true)
        gameball.run(SKAction.repeatForever(rollball),withKey:"rollingInPlaceball")
    }
    
    /**
     Generates a random Int within a range.
    
     - Parameter start: The lower value of the range.
     - Parameter end: The upper value of the range.
 
     - Returns: A random integer between `start` and `end`.
     */
    func randomIntFrom(_ start: Int, to end: Int) -> Int {
        var a = start
        var b = end
        // swap to prevent negative integer crashes
        if a > b {
            swap(&a, &b)
        }
        return Int(arc4random_uniform(UInt32(b - a + 1))) + a
    }
    
    // Locate initial touch. If on the control ball, move the reticle to the touched location, otherwise draw the pojected initial path of the ball.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
        dx1 = 0
        dy1 = 0

        let touch = touches.first
        let location = touch!.location(in: self)
        firstTouch = location;

        if(controlBallShape.contains(location)){
            controlTouch = location
        }else{
            touched = true
            CGPathMoveToPoint(dotPath, nil, gameball.position.x, gameball.position.y)
            CGPathAddLineToPoint(dotPath, nil, gameball.position.x-dx1, gameball.position.y-dy1)
        }
    }
    
    
    // Track a moving touch in order to calculate ball trajectory and redraw projected initial path.
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        
        if(controlBallShape.contains(touchLocation) && !touched){
            controlTouch = touchLocation

        }else{
            if(touched){
                let x1: CGFloat = firstTouch.x
                let y1: CGFloat = firstTouch.y
                let x2: CGFloat = touchLocation.x
                let y2: CGFloat = touchLocation.y
                let dx: CGFloat = x2-x1
                let dy: CGFloat = y2-y1
                distance = sqrt((dx*dx)+(dy*dy))
                dx1 = dx
                dy1 = dy
                lineAngle = atan2(dy,dx) //current angle
                lineAngle = (lineAngle >= 0 ? lineAngle : (2*CGFloat(M_PI) + lineAngle))
                lineDots.name = "line1"
                lineDots.position = CGPoint(x: gameball.position.x-dx1, y: gameball.position.y-dy1)
            }
        }
    }
    
    /**
     Ball is 'kicked' once the touch ends. Velocity and spin of the ball is defined.
     The drawing of the projected initial path of the ball is removed.
     */
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if(touched && distance > 10.0 && ballSpeed == 0.0){
            let speed: CGFloat = distance*0.5
            shotSpeed = speed
            ballAngle = lineAngle-CGFloat(M_PI)
            rollingball()
            shotAngle = controlBallShape.position.y-contactPoint.position.y
            shotSpin = controlBallShape.position.x-contactPoint.position.x
            vZ = speed*sin(shotAngle*CGFloat(M_PI)/180)*0.01
            vZ = speed*sin(shotAngle*CGFloat(M_PI)/180)*0.01*0.5
            Z = gameball.zPosition
            gameball.physicsBody?.velocity = CGVector(dx: cos(ballAngle)*speed,dy: sin(ballAngle)*speed);
            gameball.physicsBody?.angularVelocity = -0.5*shotSpin
            kicked = true
        }
        dotLine.removeFromParent()
        dotPath = CGMutablePath()
        touched = false
        lineAngle = 0.0

        for node in dotNodes
        {
            node.removeFromParent()
        }
        
    }
    
    /**
     Update the game scene. In this case, animate the motion of the ball in `x` and `y` co-ordinates, and simulate motion in `z` by modifying z position of ball sprite as well as its size. [IN PROGRESS]
     */
    override func update(_ currentTime: TimeInterval) {

       drawProjectedPath()
        
        // Get the ball's velocity in `x` and `y` directions.
        let dy: CGFloat = (gameball.physicsBody?.velocity.dy)!
        let dx: CGFloat = (gameball.physicsBody?.velocity.dx)!
        ballSpeed = fabs(dx + dy)
        
        // Calculate ball's position in the z-plane.
        Z += vZ
        
        // If the ball overlaps with the opponents, player has been tackled. Reset the level.
        let ballLocation = gameball.position
        for i in 0 ..< 10 {
            if(oppositionArray[i].contains(ballLocation)){
                self.setupLevel()
            }
        }
        
        /**
         Increase angular damping if the ball is 'on the ground' to slow the spinning.
         Remove all velocity in z-plane from the ball (i.e. stop the ball bouncing). [TO BE ADDED: REALISTIC BOUNCE PHYSICS]
         */
        if(Z > 1.0){
            gameball.physicsBody?.angularDamping = angularDamping
        }else{
            gameball.physicsBody?.angularDamping = angularDamping*1000
            vZ = 0.0
            Z = 1.0
        }
        
        // Increase ball sprite size in proportion to position in the z-plane to simulate height.
        let spriteX: CGFloat = max(15, 15*0.1*Z)
        gameball.size = CGSize (width: spriteX, height: spriteX)
        
        // If the player is dragging the control reticle, move the reticle with the drag.
        contactPoint.run(SKAction.move(to: controlTouch, duration: 0))
        
        /**
            If the ball has come to a stop, reset the reticle to the (0,0) co-ordinate of the control ball.
            Also remove any velocity in the z-plane and stop any actions acting on the ball.
            If the ball is still in motion, reduce the velocity in the z-plane with each frame.
         */
        if(dx == 0 && dy == 0){
            if(kicked){
                controlTouch = controlBall.position
            }
            kicked = false
            Z=1.0
            vZ=0.0
            gameball.removeAllActions()
        }else{
            vZ = vZ - 0.05
        }

        // Apply the speed to the ball's sprite in order to animate rolling at correct rate.
        let speed: CGFloat = sqrt((dx*dx)+(dy*dy))
        gameball.speed = speed
        
        // Calculate the direction in which the ball is moving (arctangent of velocity in `x` and `y`).
        var currentAngle: CGFloat = atan2(dy,dx)
        // Remove negative values in radial geometry
        currentAngle = (currentAngle >= 0 ? currentAngle : (2*CGFloat(M_PI) + currentAngle))
        
        // Calculate the direction of motion of the ball in radians and rotate ball to roll in that direction.
        var zSpin = currentAngle-CGFloat(M_PI_2)
        zSpin = (zSpin > 2*CGFloat(M_PI) ? zSpin - (2*CGFloat(M_PI)) : zSpin)
        gameball.zRotation = zSpin
        
        // Get the angular velocity of the ball and determine its orientation (left or right).
        let angVelocity: CGFloat = (gameball.physicsBody?.angularVelocity)!

        // Apply the Magnus force to the ball. This curves a spinning object in the direction perpendicular to its direction of motion.
        let magnusForce = calcMagnusForce(speed, direction: currentAngle, angularVelocity: angVelocity)
        gameball.physicsBody?.applyForce(magnusForce)
        
        if(gameball.position.x < 28 || gameball.position.x > 722.5 || gameball.position.y < 241.5 || gameball.position.y > 1306 ){
            ballOutOfPlay()
        }
    }
    
    /**
     Draw the projected initial path of the ball as a series of dots, the length of which is proportional to how far the touch is dragged.
     */
    func drawProjectedPath(){
        lineDots.position = CGPoint(x: gameball.position.x-dx1, y: gameball.position.y-dy1)
        if(touched){
            dotLine.removeFromParent()
            dotPath = CGMutablePath()
            CGPathMoveToPoint(dotPath, nil, gameball.position.x, gameball.position.y)
            CGPathAddLineToPoint(dotPath, nil, gameball.position.x-dx1, gameball.position.y-dy1)
            dotLine.path = dotPath
            dotLine.fillColor = UIColor.clear
            dotLine.lineWidth = 4.5
            
            if(ballSpeed > 0.0){
                dotLine.strokeColor = UIColor.gray
                dotLine.alpha = 0.7
            }else{
                dotLine.strokeColor = UIColor.red
                dotLine.alpha = 1.0
            }
            let one : CGFloat = 1
            let two : CGFloat = 10
            let pattern = [one,two]
            let dashed = CGPath(__byDashing: dotPath,transform: nil,phase: 0,lengths: pattern,count: 2)
            dotLine.path = dashed
            dotLine.lineCap = CGLineCap.round
            dotLine.zPosition = 1
            dotLine.name = "dotLine"
            self.addChild(dotLine)
            dotNodes.append(dotLine)
        }
    }
    
    /**
     Calculate the Magnus force which affects spinning objects, causing motion perpendicular to the direction of travel. This is how the ball curves to the left or right and depends on the angular momentum and speed of the ball.
     
     - Parameter speed: The speed of the object.
     - Parameter perpendicular: The angle perpendicular to the object's direction of motion.
     - Parameter angularVelocity: The angular velocity of the object.
     
     - Returns: The Magnus force to be applied to the object as a `CGVector`.
     */
    func calcMagnusForce(_ speed: CGFloat, direction: CGFloat, angularVelocity: CGFloat) -> CGVector {
        let rotationDir: CGFloat = -angularVelocity/angularVelocity
        
        // Calculate the right angle with respect to the ball's direction of motion. The direction of the right angle is determined by the angular velocity and its orientation with respect to the ball's motion.
        var rightAngle: CGFloat = direction+(CGFloat(M_PI_2)*rotationDir)
        rightAngle = (rightAngle > 2*CGFloat(M_PI) ? rightAngle - (2*CGFloat(M_PI)) : rightAngle)
        let rightAnglex: CGFloat = CGFloat(cosf(Float(rightAngle)))
        let rightAngley: CGFloat = CGFloat(sinf(Float(rightAngle)))
        
        let magnusMagnitude: CGFloat = -0.13*angularVelocity*speed
        let magnusForce: CGVector = CGVector(dx: rightAnglex*magnusMagnitude, dy: rightAngley*magnusMagnitude)
        return magnusForce
    }
    
    /**
     Reset the level if the ball goes out of play.
     */
    func ballOutOfPlay(){
        Z = 1.0
        vZ=0.0
        self.setupLevel()
    }
}


