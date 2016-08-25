//
//  GameScene.swift
//  Subpar Soccer
//
//  Created by James Dassoulas on 2016-06-09.
//  Copyright (c) 2016 Jetliner. All rights reserved.
//

import SpriteKit
import AVFoundation


class GameScene: SKScene {
    
    var gameball : SKSpriteNode!
    let controlBallShape = SKShapeNode(circleOfRadius: 70)
    var controlBall : SKSpriteNode!
    var circleArray:[SKShapeNode] = [SKShapeNode]()
    var ballRollingFrames : [SKTexture]!
    
    let lineDots = SKShapeNode(circleOfRadius: 5)

    var initX: CGFloat = 0.0
    var initY: CGFloat = 0.0
    var initPos: CGPoint = CGPoint(x: 0.0, y: 0.0)
    var arrowPath = UIBezierPath()
    var firstTouch: CGPoint = CGPoint(x: 0.0, y: 0.0)
    var controlTouch: CGPoint = CGPoint(x: 0.0, y: 0.0)
    var nPoints = Int()
    var lineAngle = CGFloat()
    var distance = CGFloat()
    var dlx = CGFloat()
    var dly = CGFloat()
    var dotNodes : [SKShapeNode] = []
    var dotPath = CGPathCreateMutable()
    var dotLine = SKShapeNode()
    var touched:Bool = false
    var kicked:Bool = false
    var bounced:Bool = false
    var touchedControl:Bool = false
    var ballAngle: CGFloat = 0.0
    var shotSpeed: CGFloat = 0.0
    var shotAngle: CGFloat = 0.0
    var shotSpin: CGFloat = 0.0
    var angularDamping: CGFloat = 1.0
    var linearDamping: CGFloat = 0.5
    
    var ballSpeed: CGFloat = 0.0
    var vY: CGFloat = 0.0
    var vZ: CGFloat = 0.0
    var Z: CGFloat = 0.0
    var counter: Int = 1
//    var whistleSound : AVAudioPlayer?
//    var audioPlayer = AVAudioPlayer()
    let contactPoint = SKShapeNode(circleOfRadius: 10)
    
//    
//    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer?  {
//        //1
//        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
//        let url = NSURL.fileURLWithPath(path!)
//        
//        //2
//        var audioPlayer:AVAudioPlayer?
//        
//        // 3
//        do {
//            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
//        } catch {
//            print("Player not available")
//        }
//        
//        return audioPlayer
//    }
    

    
    func setupLevel(){
        gameball.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)-300)
        initPos = gameball.position
        initX = gameball.position.x
        initY = gameball.position.y
        gameball.zPosition = 1
        gameball.size = CGSize (width: 15, height: 15)
        gameball.name = "ball"
//        SKTexture(imageNamed: "ball.png")

        gameball.physicsBody = SKPhysicsBody(circleOfRadius: 7.5)
        gameball.physicsBody?.dynamic = true
        gameball.physicsBody?.affectedByGravity = false
        gameball.physicsBody?.allowsRotation = true
        gameball.physicsBody?.friction = 0.5
        gameball.physicsBody?.restitution = 0
        gameball.physicsBody?.linearDamping = linearDamping
        gameball.physicsBody?.angularDamping = angularDamping
        gameball.physicsBody?.mass = 4.3
        gameball.physicsBody?.velocity = CGVectorMake(0,0)
        addOpposition()
 
        
    }
    
    func addOpposition(){
        for node in circleArray
        {
            node.removeFromParent()
        }
        circleArray = [SKShapeNode]() 
        
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
            oppositionPlayer.fillColor = UIColor.redColor()
            oppositionPlayer.strokeColor = UIColor.blackColor()
            oppositionPlayer.lineWidth = 3
            oppositionPlayer.zPosition = 1
            oppositionPlayer.position = CGPoint(x:xPosition, y: yPosition)
            oppositionPlayer.name = names[i]
            self.addChild(oppositionPlayer)
            
            circleArray.append(oppositionPlayer)
        }
        
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */

//        audioPlayer = AVAudioPlayer(contentsOfURL: whistleSound, fileTypeHint: nil)
//        audioPlayer.prepareToPlay()

        controlBall = SKSpriteNode(texture: SKTexture(imageNamed: "ball.png"))
        controlBall.position = CGPoint(x:CGRectGetMidX(self.frame), y: 109)
//        controlBall.position = CGPoint(x:0, y:0)
        controlBall.zPosition = 1
        controlBallShape.name = "controlBall"
        controlBallShape.fillColor = UIColor.clearColor()
        controlBallShape.strokeColor = UIColor.blueColor()
        controlBallShape.lineWidth = 0
        controlBallShape.zPosition = 2
        controlBallShape.position = CGPoint(x:CGRectGetMidX(self.frame), y: 109)
        
        self.addChild(controlBall)
        self.addChild(controlBallShape)
        
        contactPoint.name = "contactPoint"
        contactPoint.fillColor = UIColor.clearColor()
        contactPoint.strokeColor = UIColor.redColor()
        contactPoint.lineWidth = 5
        contactPoint.position = controlBall.position
        controlTouch = controlBall.position
        contactPoint.zPosition = 3
        self.addChild(contactPoint)
        
        lineDots.zPosition = 1
        lineDots.strokeColor = SKColor.redColor()
        lineDots.fillColor = SKColor.redColor()
        
        
        let borderBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
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
        let rollball = SKAction.animateWithTextures(ballRollingFrames,
                                                    timePerFrame: 3,
                                                    resize: false,
                                                    restore: true)
        gameball.runAction(SKAction.repeatActionForever(rollball),withKey:"rollingInPlaceball")
        
    }
    
    /**
        Generates a random Int within a range.
        
        - Parameter start: The lower value of the range.
        - Parameter end: The upper value of the range.
     
        - Returns: A random integer between `start` and `end`.
    */
    func randomIntFrom(start: Int, to end: Int) -> Int {
        var a = start
        var b = end
        // swap to prevent negative integer crashes
        if a > b {
            swap(&a, &b)
        }
        return Int(arc4random_uniform(UInt32(b - a + 1))) + a
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        dlx = 0
        dly = 0

        let touch = touches.first
        let location = touch!.locationInNode(self)
        firstTouch = location;
//        let touchedNode = self.nodeAtPoint(location)
        
        if(controlBallShape.containsPoint(location)){
            controlTouch = location
        }else{
            touched = true
            CGPathMoveToPoint(dotPath, nil, gameball.position.x, gameball.position.y)
            CGPathAddLineToPoint(dotPath, nil, gameball.position.x-dlx, gameball.position.y-dly)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.locationInNode(self)
        
        if(controlBallShape.containsPoint(touchLocation) && !touched){
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
                dlx = dx
                dly = dy
                nPoints = Int(distance/40)
                lineAngle = atan2(dy,dx) //current angle
                lineAngle = (lineAngle >= 0 ? lineAngle : (2*CGFloat(M_PI) + lineAngle))
                lineDots.name = "line1"
                lineDots.position = CGPointMake(gameball.position.x-dlx, gameball.position.y-dly)
                
            }
        }
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
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
            gameball.physicsBody?.velocity = CGVectorMake(cos(ballAngle)*speed,sin(ballAngle)*speed);
            gameball.physicsBody?.angularVelocity = -0.5*shotSpin
            kicked = true


        }
        dotLine.removeFromParent()
        dotPath = CGPathCreateMutable()
        touched = false
        lineAngle = 0.0

        for node in dotNodes
        {
            node.removeFromParent()
        }
        
    }
    

   
    override func update(currentTime: CFTimeInterval) {
        
        let dy: CGFloat = (gameball.physicsBody?.velocity.dy)!
        let dx: CGFloat = (gameball.physicsBody?.velocity.dx)!
        Z = Z+(vZ*1)
        if(dx == 0 && dy == 0){
            vZ = 0.0
        }else{
            vZ = vZ - 0.05
        }
        ballSpeed = fabs(dx + dy)

        let ballLocation = gameball.position
        for i in 0 ..< 10 {
//            let oppLocation = circleArray[i].position
            if(circleArray[i].containsPoint(ballLocation)){
                self.setupLevel()
            }
        }
        
        
        if(Z > 1.0){
//            vZ = vZ - 3000*0.005
//            gameball.physicsBody?.linearDamping = linearDamping/10
            gameball.physicsBody?.angularDamping = angularDamping
        }else{
//            gameball.physicsBody?.linearDamping = linearDamping
            gameball.physicsBody?.angularDamping = angularDamping*1000
//            vZ = -0.6*vZ
            vZ = 0.0
            Z = 1.0
        }

        
//        print(vZ)
        if(Z <= 1.0){
        }else{
//            print(Z)
        }
        let spriteX: CGFloat = max(15, 15*0.1*Z)
        gameball.size = CGSize (width: spriteX, height: spriteX)
        
        contactPoint.runAction(SKAction.moveTo(controlTouch, duration: 0))
        
        let av: CGFloat = (gameball.physicsBody?.angularVelocity)!

        let speed: CGFloat = sqrt((dx*dx)+(dy*dy))
        gameball.speed = speed

        if(dx == 0 && dy == 0){
            if(kicked){
            controlTouch = controlBall.position
            }
            kicked = false
            Z=1.0
            vZ=0.0
            gameball.removeAllActions()
        }else{
        }

        
        var ca: CGFloat = atan2(dy,dx) //current angle
        ca = (ca >= 0 ? ca : (2*CGFloat(M_PI) + ca)) //remove possible -values
        
        var zSpin = ca-CGFloat(M_PI_2)
        zSpin = (zSpin > 2*CGFloat(M_PI) ? zSpin - (2*CGFloat(M_PI)) : zSpin)
        gameball.zRotation = zSpin
        
        let rotationDir: CGFloat = -av/av
        
        var rightAngle: CGFloat = ca+(CGFloat(M_PI_2)*rotationDir) // add or subtract 90 degrees
        rightAngle = (rightAngle > 2*CGFloat(M_PI) ? rightAngle - (2*CGFloat(M_PI)) : rightAngle)
        
        var deg: CGFloat = ca*180/CGFloat(M_PI)
        deg = deg%360
        
        lineDots.position = CGPointMake(gameball.position.x-dlx, gameball.position.y-dly)
        
        
        
        // apply Magnus force
        let rightAnglex: CGFloat = CGFloat(cosf(Float(rightAngle)))
        let rightAngley: CGFloat = CGFloat(sinf(Float(rightAngle)))
//        let magForce: CGFloat = -0.23*av*speed
            let magForce: CGFloat = -0.13*av*speed
        let force: CGVector = CGVectorMake(rightAnglex*magForce, rightAngley*magForce)
        gameball.physicsBody?.applyForce(force)
        
        if(touched){
            dotLine.removeFromParent()
            dotPath = CGPathCreateMutable()
            CGPathMoveToPoint(dotPath, nil, gameball.position.x, gameball.position.y)
            CGPathAddLineToPoint(dotPath, nil, gameball.position.x-dlx, gameball.position.y-dly)
            dotLine.path = dotPath
            dotLine.fillColor = UIColor.clearColor()

            dotLine.lineWidth = 4.5
            if(ballSpeed > 0.0){
                dotLine.strokeColor = UIColor.grayColor()
                dotLine.alpha = 0.7
            }else{
                dotLine.strokeColor = UIColor.redColor()
                dotLine.alpha = 1.0
            }
            let one : CGFloat = 1
            let two : CGFloat = 10
            let pattern = [one,two]
            let dashed = CGPathCreateCopyByDashingPath(dotPath,nil,0,pattern,2)
            dotLine.path = dashed
            dotLine.lineCap = CGLineCap.Round
            dotLine.zPosition = 1
            dotLine.name = "dotLine"
            self.addChild(dotLine)
            dotNodes.append(dotLine)
        }
        
        
        if(gameball.position.x < 28 || gameball.position.x > 722.5 || gameball.position.y < 241.5 || gameball.position.y > 1306 ){
            Z = 1.0
            vZ=0.0
//            whistleSound?.play()
            self.setupLevel()
        }

        /* Called before each frame is rendered */
    }
}


