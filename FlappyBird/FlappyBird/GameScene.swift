//
//  GameScene.swift
//  FlappyBird
//
//  Created by Kagen Zhao on 2016/9/29.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

import SpriteKit


struct LayerMode {
    static let background: CGFloat = 0.0
    static let obstacles: CGFloat = 1.0
    static let foreground: CGFloat = 2.0
    static let player: CGFloat = 3.0
    static let ui: CGFloat = 4.0
}

enum GameStatus {
    case menu
    case tutorial
    case game
    case drop
    case scores
    case gameOver
}

struct PhysicsLayer {
    static let none: UInt32      = 0
    static let player: UInt32    = 1 << 1
    static let obstacles: UInt32 = 1 << 2
    static let ground: UInt32    = 1 << 3
}

class GameScene: SKScene {
    
    let studayLink = ""
    let appStoreLink = ""
    
    let kForegroundFloorCount = 2
    let kFloorMoveSpeed: CGFloat = -150.0
    let kGravity: CGFloat = -1500.0
    let kUpSpeed: CGFloat = 400.0
    let kBottomObstaclesMinScale: CGFloat = 0.1
    let kBottomObstaclesMaxScale: CGFloat = 0.6
    let kBreakScale: CGFloat = 3.5
    let kFirstCreateObstaclesDelay: TimeInterval = 1.75
    let kFirstResetObstaclesDelay: TimeInterval = 1.5
    let kAnimationDelay: TimeInterval = 0.3
    let kTopSpace: CGFloat = 20.0
    let kFontName = "AmericanTypewriter-Bold"
    let kAnimationFrames = 4
    
    var scoreLabel: SKLabelNode!
    var currentScore = 0
    
    var playerSpeed = CGPoint.zero
    var beatGround = false
    var beatObstacles = false
    var currentGameStatus = GameStatus.game
    
    let gameWord = SKNode()
    var gameBeginPosition: CGFloat = 0.0
    var gameZoneHeight: CGFloat = 0.0
    let protagonist = SKSpriteNode(imageNamed: "Bird0")
    let hat = SKSpriteNode(imageNamed: "Sombrero")
    var lastUpdateTime: TimeInterval = 0.0
    var dt: TimeInterval = 0.0
    
    let dingSound = SKAction.playSoundFileNamed("ding.wav", waitForCompletion: false)
    let flappingSound = SKAction.playSoundFileNamed("flapping.wav", waitForCompletion: false)
    let whackSound = SKAction.playSoundFileNamed("whack.wav", waitForCompletion: false)
    let fallingSound = SKAction.playSoundFileNamed("falling.wav", waitForCompletion: false)
    let hitGroundSound = SKAction.playSoundFileNamed("hitGround.wav", waitForCompletion: false)
    let popSound = SKAction.playSoundFileNamed("pop.wav", waitForCompletion: false)
    let coinSound = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
    
    var playBtn: SKSpriteNode?
    var rateBtn: SKSpriteNode?
    var learnBtn: SKSpriteNode?
    var okBtn: SKSpriteNode?
    var shareBtn: SKSpriteNode?
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        addChild(gameWord)
        switchMenu()
    }
    
    func setupMenu() {
        
        let mainMenuName = "mainMenu"
        
        let logo = SKSpriteNode(imageNamed: "Logo")
        logo.position = .init(x: size.width / 2, y: size.height * 0.8)
        logo.name = mainMenuName
        logo.zPosition = LayerMode.ui
        gameWord.addChild(logo)
        
        let startButton = SKSpriteNode(imageNamed: "Button")
        startButton.position = .init(x: size.width * 0.5/* * 0.25 */, y: size.height * 0.25)
        startButton.name = mainMenuName
        startButton.zPosition = LayerMode.ui
        gameWord.addChild(startButton)
        
        let game = SKSpriteNode(imageNamed: "play")
        game.position = .zero
        startButton.addChild(game)
        
//        let evaluateButton = SKSpriteNode(imageNamed: "Button")
//        evaluateButton.position = .init(x: size.width * 0.75, y: size.height * 0.25)
//        evaluateButton.zPosition = LayerMode.ui
//        evaluateButton.name = mainMenuName
//        gameWord.addChild(evaluateButton)
//        
//        let evaluate = SKSpriteNode(imageNamed: "Rate")
//        evaluate.position = .zero
//        evaluateButton.addChild(evaluate)
//        
//        let learnButton = SKSpriteNode(imageNamed: "button_learn")
//        learnButton.position = .init(x: size.width * 0.5, y: learnButton.size.height / 2 + kTopSpace)
//        learnButton.zPosition = LayerMode.ui
//        learnButton.name = mainMenuName
//        gameWord.addChild(learnButton)
        
//        let zoomIn = SKAction.scale(to: 1.05, duration: 0.75)
//        zoomIn.timingMode = .easeInEaseOut
//        
//        let zoomOut = SKAction.scale(to: 0.95, duration: 0.75)
//        zoomOut.timingMode = .easeInEaseOut
//        
//        learnButton.run(.repeatForever(.sequence([zoomIn, zoomOut])), withKey: mainMenuName)
        
        playBtn = startButton
//        rateBtn = evaluateButton
//        learnBtn = learnButton
    }
    
    func setupTutorial() {
        
        let tutorialName = "tutorial"
        
        let tutorial = SKSpriteNode(imageNamed: "Tutorial")
        tutorial.position = .init(x: size.width * 0.5, y: gameZoneHeight * 0.4 + gameBeginPosition)
        tutorial.name =  tutorialName
        tutorial.zPosition = LayerMode.ui
        gameWord.addChild(tutorial)
        
        let ready = SKSpriteNode(imageNamed: "Ready")
        ready.position = .init(x: size.width * 0.5, y: gameZoneHeight * 0.7 + gameBeginPosition)
        ready.name = tutorialName
        ready.zPosition = LayerMode.ui
        gameWord.addChild(ready)
        
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 0.4)
        moveUp.timingMode = .easeInEaseOut
        let moveDown = moveUp.reversed()
        
        protagonist.run(.repeatForever(.sequence([moveUp, moveDown])), withKey: "fly")
        
        var playerTextures: [SKTexture] = []
        playerTextures.append(contentsOf: (0..<kAnimationFrames).map({ SKTexture(imageNamed: "Bird\($0)") }))
        playerTextures.append(contentsOf: stride(from: (kAnimationFrames - 1), to: 0, by: -1).map({SKTexture(imageNamed: "Bird\($0)")}))
        
        let flyAnimate = SKAction.animate(with: playerTextures, timePerFrame: 0.07)
        protagonist.run(.repeatForever(flyAnimate))
    }
    
    func setupBackground() {
        let background = SKSpriteNode(imageNamed: "Background")
        background.anchorPoint = .init(x: 0.5, y: 1.0)
        background.position = .init(x: size.width / 2, y: size.height)
        background.zPosition = LayerMode.background
        gameWord.addChild(background)
        
        gameBeginPosition = size.height - background.size.height
        gameZoneHeight = background.size.height
        
        let leftBottom = CGPoint(x: 0, y: gameBeginPosition)
        let rightBottom = CGPoint(x: size.width, y: gameBeginPosition)
        
        physicsBody = SKPhysicsBody.init(edgeFrom: leftBottom, to: rightBottom)
        physicsBody?.categoryBitMask = PhysicsLayer.ground
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = PhysicsLayer.player
    }
    
    func setupProtagonist() {
        protagonist.position = .init(x: size.width * 0.2, y: gameZoneHeight * 0.4 + gameBeginPosition)
        protagonist.zPosition = LayerMode.player
        
        let offsetX = protagonist.size.width * protagonist.anchorPoint.x
        let offsetY = protagonist.size.height * protagonist.anchorPoint.y
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 3 - offsetX, y: 12 - offsetY))
        path.addLine(to: CGPoint(x: 18 - offsetX, y: 22 - offsetY))
        path.addLine(to: CGPoint(x: 28 - offsetX, y: 27 - offsetY))
        path.addLine(to: CGPoint(x: 39 - offsetX, y: 23 - offsetY))
        path.addLine(to: CGPoint(x: 39 - offsetX, y: 9 - offsetY))
        path.addLine(to: CGPoint(x: 25 - offsetX, y: 4 - offsetY))
        path.addLine(to: CGPoint(x: 5 - offsetX, y: 2 - offsetY))
        path.closeSubpath()
        
        protagonist.physicsBody = SKPhysicsBody(polygonFrom: path)
        protagonist.physicsBody?.categoryBitMask = PhysicsLayer.player
        protagonist.physicsBody?.collisionBitMask = 0
        protagonist.physicsBody?.contactTestBitMask = PhysicsLayer.ground | PhysicsLayer.obstacles
        
        gameWord.addChild(protagonist)
    }
    
    func setupForeground() {
        for i in 0..<kForegroundFloorCount {
            let foreground = SKSpriteNode(imageNamed: "Ground")
            foreground.anchorPoint = CGPoint(x: 0, y: 1.0)
            foreground.position = .init(x: CGFloat(i) * foreground.size.width, y: gameBeginPosition)
            foreground.zPosition = LayerMode.foreground
            foreground.name = "foreground"
            gameWord.addChild(foreground)
        }
    }
    
    func setupHat() {
        hat.position = .init(x: 31 - hat.size.width / 2 , y: 29 - hat.size.height / 2)
        hat.zPosition = LayerMode.player
        protagonist.addChild(hat)
    }
    
    func setupScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: kFontName)
        scoreLabel.fontColor = SKColor(red: 101.0 / 255.0, green: 71.0 / 255.0, blue: 73.0 / 255, alpha: 1.0)
        scoreLabel.position = .init(x: size.width / 2, y: size.height - kTopSpace)
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.text = "0"
        scoreLabel.zPosition = LayerMode.ui
        gameWord.addChild(scoreLabel)
    }
    
    func setupScoreCard() {
        if currentScore > maxScore() {
            setMaxScore(currentScore)
        }
        
        let scoreCard = SKSpriteNode(imageNamed: "ScoreCard")
        scoreCard.position = .init(x: size.width / 2, y: size.height / 2)
        scoreCard.zPosition = LayerMode.ui
        gameWord.addChild(scoreCard)
        
        let currentScoreLabel = SKLabelNode(fontNamed: kFontName)
        currentScoreLabel.fontColor = SKColor(red: 101.0/255.0, green: 71.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        currentScoreLabel.position = .init(x: -scoreCard.size.width / 4, y: -scoreCard.size.height / 3)
        currentScoreLabel.text = "\(currentScore)"
        currentScoreLabel.zPosition = LayerMode.ui
        scoreCard.addChild(currentScoreLabel)
        
        let maxScoreLabel = SKLabelNode(fontNamed: kFontName)
        maxScoreLabel.fontColor = SKColor(red: 101.0/255.0, green: 71.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        maxScoreLabel.position = .init(x: scoreCard.size.width / 4, y: -scoreCard.size.height / 3)
        maxScoreLabel.text = "\(maxScore())"
        maxScoreLabel.zPosition = LayerMode.ui
        scoreCard.addChild(maxScoreLabel)
        
        let gameOver = SKSpriteNode(imageNamed: "GameOver")
        gameOver.position = .init(x: size.width / 2, y: size.height / 2 + scoreCard.size.height / 2 + kTopSpace + gameOver.size.height / 2)
        gameOver.zPosition = LayerMode.ui
        gameWord.addChild(gameOver)
        
        let okButton = SKSpriteNode(imageNamed: "Button")
        okButton.position = .init(x: size.width / 2 /* / 4 */, y: size.height / 2 - scoreCard.size.height / 2 - kTopSpace - okButton.size.height / 2)
        okButton.zPosition = LayerMode.ui
        gameWord.addChild(okButton)
        
        let ok = SKSpriteNode(imageNamed: "OK")
        ok.position = .zero
        ok.zPosition = LayerMode.ui
        okButton.addChild(ok)
//        
//        let shareButton = SKSpriteNode(imageNamed: "Button")
//        shareButton.position = .init(x: size.width * 0.75, y: size.height / 2 - scoreCard.size.height / 2 - kTopSpace - shareButton.size.height / 2)
//        shareButton.zPosition = LayerMode.ui
//        gameWord.addChild(shareButton)
//        
//        let share = SKSpriteNode(imageNamed: "Share")
//        share.position = .zero
//        share.zPosition = LayerMode.ui
//        shareButton.addChild(share)
        
        gameOver.setScale(0)
        gameOver.alpha = 0
        let animationGroup = SKAction.group([.fadeIn(withDuration: kAnimationDelay),
                                             .scale(to: 1.0, duration: kAnimationDelay)])
        animationGroup.timingMode = .easeInEaseOut
        gameOver.run(.sequence([.wait(forDuration: kAnimationDelay),
                                animationGroup]))
        
        scoreCard.position = .init(x: size.width / 2, y: -scoreCard.size.height / 2)
        let moveUpAnimate = SKAction.move(to: .init(x: size.width / 2, y: size.height / 2), duration: kAnimationDelay)
        moveUpAnimate.timingMode = .easeInEaseOut
        scoreCard.run(.sequence([.wait(forDuration: kAnimationDelay),
                                 moveUpAnimate]))
        
        okButton.alpha = 0
//        shareButton.alpha = 0
        
        let fadeAnimate = SKAction.sequence([.wait(forDuration: kAnimationDelay * 3),
                                             .fadeIn(withDuration: kAnimationDelay)])
        okButton.run(fadeAnimate)
//        shareButton.run(fadeAnimate)
        
        let sound = SKAction.sequence([.wait(forDuration: kAnimationDelay),
                                       popSound,
                                       .wait(forDuration: kAnimationDelay),
                                       popSound,
                                       .wait(forDuration: kAnimationDelay),
                                       popSound,
                                       SKAction.run(switchGameOver)])
        run(sound)
        
        okBtn = okButton
//        shareBtn = shareButton
    }
    
    func createObstacles(imageNamed imageName: String) -> SKSpriteNode {
        let obstacles = SKSpriteNode(imageNamed: imageName)
        obstacles.zPosition = LayerMode.obstacles
        obstacles.userData = NSMutableDictionary()
        
        let offsetX = obstacles.size.width * obstacles.anchorPoint.x
        let offsetY = obstacles.size.height * obstacles.anchorPoint.y
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 4 - offsetX, y: 0 - offsetY))
        path.addLine(to: CGPoint(x: 7 - offsetX, y: 307 - offsetY))
        path.addLine(to: CGPoint(x: 47 - offsetX, y: 308 - offsetY))
        path.addLine(to: CGPoint(x: 48 - offsetX, y: 1 - offsetY))
        path.closeSubpath()
        
        obstacles.physicsBody = SKPhysicsBody(polygonFrom: path)
        obstacles.physicsBody?.categoryBitMask = PhysicsLayer.obstacles
        obstacles.physicsBody?.collisionBitMask = 0
        obstacles.physicsBody?.contactTestBitMask = PhysicsLayer.player
        
        return obstacles
    }
    
    func setupObstacles() {
        let bottomObstacles = createObstacles(imageNamed: "CactusBottom")
        let beginX = size.width + bottomObstacles.size.width / 2
        
        let minY = (gameBeginPosition - bottomObstacles.size.height / 2) + gameZoneHeight * kBottomObstaclesMinScale
        let maxY = (gameBeginPosition - bottomObstacles.size.height / 2) + gameZoneHeight * kBottomObstaclesMaxScale
        
        bottomObstacles.position = .init(x: beginX, y: CGFloat.random(min: minY, max: maxY))
        bottomObstacles.name = "bottomObstacles"
        gameWord.addChild(bottomObstacles)
        
        let topObstacles = createObstacles(imageNamed: "CactusTop")
        topObstacles.zRotation = CGFloat(180).degreesToRadians()
        topObstacles.position = .init(x: beginX, y: bottomObstacles.position.y + bottomObstacles.size.height / 2 + topObstacles.size.height / 2 + protagonist.size.height * kBreakScale)
        topObstacles.name = "topObstacles"
        gameWord.addChild(topObstacles)
        
        let moveDistanceX = -(size.width + bottomObstacles.size.width)
        let moveTimeInterval = moveDistanceX / kFloorMoveSpeed
        
        let moveAction = SKAction.sequence([.moveBy(x: moveDistanceX, y: 0, duration: TimeInterval(moveTimeInterval)),
                                            .removeFromParent()])
        topObstacles.run(moveAction)
        bottomObstacles.run(moveAction)
    }
    
    func repeatCreateObstacles() {
        let firstDelay = SKAction.wait(forDuration: kFirstCreateObstaclesDelay)
        let recreateObstacles = SKAction.run(setupObstacles)
        let recreateTimeInterval = SKAction.wait(forDuration: kFirstResetObstaclesDelay)
        let recreateAction = SKAction.sequence([recreateObstacles, recreateTimeInterval])
        let repeatCreate = SKAction.repeatForever(recreateAction)
        let allAction = SKAction.sequence([firstDelay, repeatCreate])
        run(allAction, withKey: "resetObstacles")
    }
    
    func stopCreateObstacles() {
        removeAction(forKey: "resetObstacles")
        
        gameWord.enumerateChildNodes(withName: "topObstacles") { node, _ in
            node.removeAllActions()
        }
        gameWord.enumerateChildNodes(withName: "bottomObstacles") { node, _ in
            node.removeAllActions()
        }
    }
    
    func onceFly() {
        playerSpeed = .init(x: 0, y: kUpSpeed)
        let moveUp = SKAction.moveBy(x: 0, y: 12, duration: 0.15)
        let moveDown = moveUp.reversed()
        hat.run(.sequence([moveUp, moveDown]))
        
        run(flappingSound)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchPosition = touch.location(in: self)
        
        switch currentGameStatus {
        case .menu:
            if let playBtn = playBtn {
                let playBtnRect = CGRect(origin: CGPoint(x: playBtn.position.x - playBtn.size.width / 2, y: playBtn.position.y - playBtn.size.height / 2), size: playBtn.size)
                if playBtnRect.contains(touchPosition) { switchTutorial() }
            }
            
            if let rateBtn = rateBtn {
                let rateBtnRect = CGRect(origin: CGPoint(x: rateBtn.position.x - rateBtn.size.width / 2, y: rateBtn.position.y - rateBtn.size.height / 2), size: rateBtn.size)
                if rateBtnRect.contains(touchPosition) { gotoEvaluation() }
            }
            
            if let learnBtn = learnBtn {
                let learnBtnRect = CGRect(origin: CGPoint(x: learnBtn.position.x - learnBtn.size.width / 2, y: learnBtn.position.y - learnBtn.size.height / 2), size: learnBtn.size)
                if learnBtnRect.contains(touchPosition) { gotoLearn() }
            }
        case .tutorial: switchGameing()
        case .game: onceFly()
        case .gameOver:
            if let okBtn = okBtn {
                let okBtnRect = CGRect(origin: CGPoint(x: okBtn.position.x - okBtn.size.width / 2, y: okBtn.position.y - okBtn.size.height / 2), size: okBtn.size)
                if okBtnRect.contains(touchPosition) { switchNewGame() }
            }
            if let shareBtn = shareBtn {
                let _ = CGRect(origin: CGPoint(x: shareBtn.position.x - shareBtn.size.width / 2, y: shareBtn.position.y - shareBtn.size.height / 2), size: shareBtn.size)
            }
        case .drop, .scores: break
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 { dt = currentTime - lastUpdateTime }
        else { dt = 0 }
        
        lastUpdateTime = currentTime
        
        switch currentGameStatus {
        case .game:
            updateForeground()
            updateProtagonist()
            checkObstacles()
            checkGround()
            updateScore()
        case .drop:
            updateProtagonist()
            checkGround()
        case .scores, .gameOver, .menu, .tutorial: break
        }
        
    }
    
    func updateProtagonist() {
        let acceleration = CGPoint(x: 0, y: kGravity)
        playerSpeed = playerSpeed + acceleration * CGFloat(dt)
        protagonist.position = protagonist.position + playerSpeed * CGFloat(dt)
        
        if protagonist.position.y - protagonist.size.height / 2 < gameBeginPosition {
            protagonist.position = .init(x: protagonist.position.x, y: gameBeginPosition + protagonist.size.height / 2)
        }
    }
    
    func updateForeground() {
        gameWord.enumerateChildNodes(withName: "foreground") { (node, _) in
            if let foreground = node as? SKSpriteNode {
                let floorMoveSpeed = CGPoint(x: self.kFloorMoveSpeed, y: 0)
                foreground.position += floorMoveSpeed * CGFloat(self.dt)
                
                if foreground.position.x < -foreground.size.width {
                    foreground.position += CGPoint(x: foreground.size.width * CGFloat(self.kForegroundFloorCount), y: 0)
                }
            }
        }
    }
    
    func checkObstacles() {
        if beatObstacles {
            beatObstacles = false
            switchDrop()
        }
    }
    
    func checkGround() {
        if beatGround {
            beatGround = false
            playerSpeed = .zero
            protagonist.zRotation = CGFloat(-90).degreesToRadians()
            protagonist.position = CGPoint(x: protagonist.position.x, y: gameBeginPosition + protagonist.size.width / 2)
            run(hitGroundSound)
            switchScores()
        }
    }
    
    func updateScore() {
        gameWord.enumerateChildNodes(withName: "topObstacles") { (node, _) in
            if let obstacles = node as? SKSpriteNode {
                if let isThrough = obstacles.userData?["isThrough"] as? NSNumber {
                    if isThrough.boolValue {
                        return
                    }
                }
                if self.protagonist.position.x > obstacles.position.x + obstacles.size.width / 2 {
                    self.currentScore += 1
                    self.scoreLabel.text = "\(self.currentScore)"
                    self.run(self.coinSound)
                    obstacles.userData?["isThrough"] = NSNumber(booleanLiteral: true)
                }
            }
        }
    }

    func switchMenu() {
        currentGameStatus = .menu
        setupBackground()
        setupForeground()
        setupProtagonist()
        setupHat()
        setupMenu()
    }
    
    func switchTutorial() {
        currentGameStatus = .tutorial
        gameWord.enumerateChildNodes(withName: "mainMenu") { (node, _) in
            node.run(.sequence([.fadeOut(withDuration: 0.05),
                                .removeFromParent()]))
        }
        setupScoreLabel()
        setupTutorial()
    }
    
    func switchNewGame() {
        run(popSound)
        let newScene = GameScene(size: size)
        let transition = SKTransition.fade(with: SKColor.black, duration: 0.05)
        view?.presentScene(newScene, transition: transition)
    }
    
    func switchGameing() {
        currentGameStatus = .game
        gameWord.enumerateChildNodes(withName: "tutorial") { (node, _) in
            node.run(.sequence([.fadeOut(withDuration: 0.05),
                                .removeFromParent()]))
        }
        protagonist.removeAction(forKey: "fly")
        repeatCreateObstacles()
        onceFly()
    }
    
    func switchDrop() {
        currentGameStatus = .drop
        run(.sequence([whackSound,
                       .wait(forDuration: 0.1),
                       fallingSound]))
        protagonist.removeAllActions()
        stopCreateObstacles()
    }
    
    func switchGameOver() {
        currentGameStatus = .gameOver
    }
    
    func gotoLearn() {
        let url = URL(string: studayLink)
        UIApplication.shared.open(url!, completionHandler: nil)
    }
    
    func gotoEvaluation() {
        let url = URL(string: appStoreLink)
        UIApplication.shared.open(url!, completionHandler: nil)
    }
    
    func switchScores() {
        currentGameStatus = .scores
        protagonist.removeAllActions()
        stopCreateObstacles()
        setupScoreCard()
    }
    
    func maxScore() -> Int {
        return UserDefaults.standard.integer(forKey: "maxScore")
    }
    
    func setMaxScore(_ score: Int) {
        UserDefaults.standard.set(score, forKey: "maxScore")
        UserDefaults.standard.synchronize()
    }
}

extension GameScene : SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let obstacles = contact.bodyA.categoryBitMask == PhysicsLayer.player ? contact.bodyB : contact.bodyA
        if obstacles.categoryBitMask == PhysicsLayer.ground { beatGround = true }
        if obstacles.categoryBitMask == PhysicsLayer.obstacles { beatObstacles = true }
    }
    
    
}
