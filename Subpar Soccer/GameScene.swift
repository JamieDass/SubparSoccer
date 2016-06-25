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

    var bearWalkingFrames : [SKTexture]!
    
    let lineDots = SKShapeNode(circleOfRadius: 5)

    var initX: CGFloat = 0.0
    var initY: CGFloat = 0.0
    var initPos: CGPoint = CGPoint(x: 0.0, y: 0.0)
    var arrowPath = UIBezierPath()
    var firstTouch: CGPoint = CGPoint(x: 0.0, y: 0.0)
    var controlTouch: CGPoint = CGPoint(x: 0.0, y: 0.0)
    var shapeTrack = SKShapeNode()
    var triangle = SKShapeNode()
    var line = SKShapeNode()
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
    var shotAngle: CGFloat = 0.0
    var shotSpin: CGFloat = 0.0
    var angularDamping: CGFloat = 1.0
    var linearDamping: CGFloat = 0.5
    
    var ballSpeed: CGFloat = 0.0
    var vY: CGFloat = 0.0
    var vZ: CGFloat = 0.0
    var Z: CGFloat = 0.0
    var counter: Int = 1
    var whistleSound : AVAudioPlayer?
//    var whistleSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Whistle", ofType: "wav")!)
    var audioPlayer = AVAudioPlayer()
    let contactPoint = SKShapeNode(circleOfRadius: 10)
    
    
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer?  {
        //1
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        
        //2
        var audioPlayer:AVAudioPlayer?
        
        // 3
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch {
            print("Player not available")
        }
        
        return audioPlayer
    }
    

    
    func setupLevel(){
        gameball.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)-300)
        initPos = gameball.position
        initX = gameball.position.x
        initY = gameball.position.y
        gameball.zPosition = 1
        gameball.size = CGSize (width: 10, height: 10)
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
        
 
        
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */

//        audioPlayer = AVAudioPlayer(contentsOfURL: whistleSound, fileTypeHint: nil)
//        audioPlayer.prepareToPlay()
        controlBall = SKSpriteNode(texture: SKTexture(imageNamed: "ball.png"))
        controlBall.position = CGPoint(x:CGRectGetMidX(self.frame), y: 109)
//        controlBall.position = CGPoint(x:0, y:0)
        controlBall.zPosition = 1
//        controlBall.fillTexture = SKTexture(imageNamed: "ball.png")
        controlBallShape.name = "controlBall"
        controlBallShape.fillColor = UIColor.clearColor()
        controlBallShape.strokeColor = UIColor.blueColor()
        controlBallShape.lineWidth = 0
        controlBallShape.zPosition = 2
        controlBallShape.position = CGPoint(x:CGRectGetMidX(self.frame), y: 109)
        
        
//        controlBallShape.addChild(controlBall)
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
        
        if let whistleSound = self.setupAudioPlayerWithFile("Whistle", type:"wav") {
            self.whistleSound = whistleSound
        }
        
        lineDots.strokeColor = SKColor.redColor()
        lineDots.fillColor = SKColor.redColor()
        
//        self.view?.showsPhysics = true
        
        let borderBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
        

        
//        let tex1: SKTexture = SKTexture()
//        self.addChild(gameball)
//                gameball.runAction(SKAction.rotateByAngle(CGFloat(M_PI_2), duration: 4.0))
        
//        gameball = self.childNodeWithName("ball")
//        gameball.zRotation = (90 * CGFloat(M_PI) / 180.0)

        let bearAnimatedAtlas = SKTextureAtlas(named: "rollingBall")
        var walkFrames = [SKTexture]()
        
        let numImages = bearAnimatedAtlas.textureNames.count
        for var i=1; i<=numImages; i++ {
            let bearTextureName = "ball_\(i)"
            walkFrames.append(bearAnimatedAtlas.textureNamed(bearTextureName))
        }
        
        bearWalkingFrames = walkFrames
        let firstFrame = bearWalkingFrames[0]
        gameball = SKSpriteNode(texture: firstFrame)
        setupLevel()
        self.addChild(gameball)
        
    }
    
    func walkingBear() {
        //This is our general runAction method to make our bear walk.

        let walkBear = SKAction.animateWithTextures(bearWalkingFrames,
                                                    timePerFrame: 3,
                                                    resize: false,
                                                    restore: true)
//        walkBear.timingMode = SKActionTimingMode.EaseOut
        
        
        
//        gameball.zRotation = (lineAngle-CGFloat(M_PI_2))+CGFloat(M_PI)
        
        gameball.runAction(SKAction.repeatActionForever(walkBear),withKey:"walkingInPlaceBear")
        
    }
    
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
        if(location.y > 206){
            CGPathMoveToPoint(dotPath, nil, gameball.position.x, gameball.position.y)
            CGPathAddLineToPoint(dotPath, nil, gameball.position.x-dlx, gameball.position.y-dly)
        }
        let touchedNode = self.nodeAtPoint(location)
        if(controlBallShape.containsPoint(location)){
            controlTouch = location
        }
        

    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.locationInNode(self)

        
        let touchedNode = self.nodeAtPoint(touchLocation)
        if(controlBallShape.containsPoint(touchLocation)){
            controlTouch = touchLocation
        }

        
        if(touchLocation.y > 206){
        touched = true
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
//        print(distance)
        lineAngle = atan2(dy,dx) //current angle
        lineAngle = (lineAngle >= 0 ? lineAngle : (2*CGFloat(M_PI) + lineAngle))
        lineDots.name = "line1"
        lineDots.position = CGPointMake(gameball.position.x-dlx, gameball.position.y-dly)
        lineDots.zPosition = 1
        }else{ // if touch goes below line, cancel hit
            dotLine.removeFromParent()
            dotPath = CGPathCreateMutable()
            touched = false
            lineAngle = 0.0
            
            for node in dotNodes
            {
                node.removeFromParent()
            }
        }
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.locationInNode(self)
        
        
        if(touchLocation.y > 206){
        let speed: CGFloat = distance*0.5
        ballSpeed = speed
//            print(speed)

        ballAngle = lineAngle-CGFloat(M_PI)
        
//            print(180*ballAngle/CGFloat(M_PI))
        if(touched){
            walkingBear()
            shotAngle = controlBallShape.position.y-contactPoint.position.y
            shotSpin = controlBallShape.position.x-contactPoint.position.x
//            print(speed)
            vZ = speed*sin(shotAngle*CGFloat(M_PI)/180)*0.01
            vZ = speed*sin(shotAngle*CGFloat(M_PI)/180)*0.01*0.5
//            print(vZ)
//            print("kick")
            Z = gameball.zPosition
            gameball.physicsBody?.velocity = CGVectorMake(cos(ballAngle)*speed,sin(ballAngle)*speed);
            gameball.physicsBody?.angularVelocity = -0.5*shotSpin
            kicked = true

            }
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
//        print(Z)

        if(dx == 0 && dy == 0){
            vZ = 0.0
        }else{
//            vZ = vZ - 0.1635
            vZ = vZ - 0.05
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
        let spriteX: CGFloat = max(10, 10*0.1*Z)
        gameball.size = CGSize (width: spriteX, height: spriteX)
        
        contactPoint.runAction(SKAction.moveTo(controlTouch, duration: 0))
        
        let av: CGFloat = (gameball.physicsBody?.angularVelocity)!
//        let av: CGFloat


        let speed: CGFloat = sqrt((dx*dx)+(dy*dy))
        gameball.speed = speed

        if(dx == 0 && dy == 0){
//            contactPoint.position = controlBall.position
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
            dotLine.strokeColor = UIColor.redColor()
            dotLine.lineWidth = 4.5
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
            whistleSound?.play()
            self.setupLevel()
        }

        /* Called before each frame is rendered */
    }
}


