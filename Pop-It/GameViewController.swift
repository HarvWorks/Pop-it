//
//  GameViewController.swift
//  Pop-It
//
//  Created by Harvey Chui on 11/6/16.
//  Copyright © 2016 Pokemon Kno. All rights reserved.
//





import UIKit
import CoreMotion
import Foundation
import AVFoundation

class GameViewController: UIViewController {
    
    
    // Instance Variables
    
    var currentMaxAccelX: Float64 = 0.0
    var currentMaxAccelY: Float64 = 0.0
    var currentMaxAccelZ: Float64 = 0.0
    var currentMaxRotX: Float64 = 0.0
    var currentMaxRotY: Float64 = 0.0
    var currentMaxRotZ: Float64 = 0.0
    
    var gravityX: Float64 = 0
    var gravityY: Float64 = 0
    var gravityZ: Float64 = 0
    
    var accelNoGravityX: Float64 = 0
    var accelNoGravityY: Float64 = 0
    var accelNoGravityZ: Float64 = 0
    
    var spinAmount: Float64 = 0
    var spinAccel: Float64 = 0
    var spinRate: Float64 = 0
    var spinTime: Float64 = NSDate().timeIntervalSince1970
    
    var twistAmount: Float64 = 0
    var twistAccel: Float64 = 0
    var twistRate: Float64 = 0
    var twistTime: Float64 = NSDate().timeIntervalSince1970
    
    var smashAmount: Float64 = 0
    var smashAccel: Float64 = 0
    var smashMax: Float64 = 0
    var smashRate: Float64 = 0
    var smashTime: Float64 = NSDate().timeIntervalSince1970
    
    var slideAmount: Float64 = 0
    var slideAccel: Float64 = 0
    var slideRate: Float64 = 0
    var slideTime: Float64 = NSDate().timeIntervalSince1970
    
    var raiseAmount: Float64 = 0
    var raiseAccel: Float64 = 0
    var raiseRate: Float64 = 0
    var raiseTime: Float64 = NSDate().timeIntervalSince1970
    
    var pushAmount: Float64 = 0
    var pushAccel: Float64 = 0
    var pushRate: Float64 = 0
    var pushTime: Float64 = NSDate().timeIntervalSince1970
    
    var incrementTimeAcc: Float64 = NSDate().timeIntervalSince1970
    var deltaTimeAcc: Float64 = 0
    
    var incrementTimeRot: Float64 = NSDate().timeIntervalSince1970
    var deltaTimeRot: Float64 = 0
    
    var CountOffTimer:Timer?
    var EndTimer:Timer?
    
    var screenDirection:Int = UIApplication.shared.statusBarOrientation.rawValue
    
    var currentAction:String = ""
    var randomAction: Int = 0
    var waitTimer: Float64 = 0
    var waitingAction = false
    var previousTimer = NSDate().timeIntervalSince1970
    var endGame = true
    var timer: Float64 = 0
    var speedup: Float64 = 0
    var tempCheck:String = ""
    var currentPopItBank: [String] = []
    var countDownTimer: Int = 3
    
    let popItBank: [String] = [
        "Pop It!",
        "Swipe It!",
        "Push It!",
        "Raise It!",
        "Slide Right!",
        "Slide Left!",
        "Spin It!",
        "Twist It!",
        "Smash It!",
        "Slide It!",
        "Pass It!"
    ]
    
    var multiPlayer = Bool()
    var extremeMode = Bool()
    var easyMode = Bool()
    var practiceMode = Bool()
    
    var motionManager = CMMotionManager()
    var player:AVAudioPlayer?;
    
    // Outlet
    
    @IBOutlet weak var CountDown: UILabel!
    @IBOutlet weak var ExitLabel: UIButton!
    
    @IBAction func ExitPracticeMode(_ sender: UIButton) {
        if practiceMode {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func PopIt(_ sender: UIButton) {
        if !endGame {
            currentAction = "Pop It!"
        }
    }
    
    @IBAction func SwipeRight(_ sender: UISwipeGestureRecognizer) {
        if !endGame{
            currentAction = "Swipe It!"
        }
    }
    
    @IBAction func SwipeLeft(_ sender: UISwipeGestureRecognizer) {
        if !endGame {
            currentAction = "Swipe It!"
        }
    }
    
    func randomNumber() {
        randomAction = Int(arc4random_uniform(UInt32(currentPopItBank.count)))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if practiceMode {
            ExitLabel.alpha = 1
        }
        
        motionManager.gyroUpdateInterval = 0.2
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.deviceMotionUpdateInterval = 0.1
        
        //Start Recording Data
        
        motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler:{ deviceManager, error in
            self.outputAccData(motion: (deviceManager?.gravity)!)
        })
        
        motionManager.startGyroUpdates(to: OperationQueue.current!, withHandler: { (gyroData: CMGyroData?, NSError) -> Void in
            self.outputRotData(rotation: gyroData!.rotationRate)
            if (NSError != nil){
                print("\(NSError)")
            }
            
        })
        
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (accelerometerData: CMAccelerometerData?, NSError) -> Void in
            
            self.outputAccData(acceleration: accelerometerData!.acceleration)
            if(NSError != nil) {
                print("\(NSError)")
            }
        }
        
        CountOffTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameViewController.CountOff), userInfo: nil, repeats: true)
    }
    
    func outputAccData(motion: CMAcceleration) {
        
        if !endGame {
            gravityX = motion.x
            gravityY = motion.y
            gravityZ = motion.z
            
            screenDirection = UIApplication.shared.statusBarOrientation.rawValue
        }
        
    }
    
    func outputAccData(acceleration: CMAcceleration){
        
        if !endGame {
            deltaTimeAcc = NSDate().timeIntervalSince1970 - incrementTimeAcc
            incrementTimeAcc = NSDate().timeIntervalSince1970
            
            accelNoGravityX = acceleration.x - gravityX
            accelNoGravityY = acceleration.y - gravityY
            accelNoGravityZ = acceleration.z - gravityZ
            
            CalcAccel()
            SlideIt()
            RaiseIt()
            PushIt ()
            Game()
        }
        
    }
    
    func outputRotData(rotation: CMRotationRate){
        if !endGame {
            deltaTimeRot = NSDate().timeIntervalSince1970 - incrementTimeRot
            incrementTimeRot = NSDate().timeIntervalSince1970
            
            spinAccel = fabs(rotation.z)
            
            if screenDirection == 1 || screenDirection == 2 {
                twistAccel = fabs(rotation.y)
                smashAccel = fabs(rotation.x)
            }
            else {
                twistAccel = fabs(rotation.x)
                smashAccel = fabs(rotation.y)
            }
            
            SpinIt()
            TwistIt()
            SmashIt()
        }
        
    }
    
    func CalcAccel () {
        if smashAccel < 2 || smashRate < 0.5 {
            if screenDirection == 1 || screenDirection == 2 {
                slideAccel = accelNoGravityX * 10
                raiseAccel = -accelNoGravityY * 10
                pushAccel = accelNoGravityZ * 10
                
                if fabs(gravityZ) > fabs(gravityX) && fabs(gravityZ) > fabs(gravityY) {
                    raiseAccel = accelNoGravityZ * 10
                    pushAccel = accelNoGravityZ * 10
                    
                    if gravityZ > 0 {
                        raiseAccel = -raiseAccel
                        pushAccel = -pushAccel
                    }
                }
                
                if screenDirection == 2 {
                    raiseAccel = -raiseAccel
                    slideAccel = -slideAccel
                }
            }
            else {
                slideAccel = accelNoGravityY * 10
                raiseAccel = accelNoGravityX * 10
                pushAccel = accelNoGravityZ * 10
                
                if fabs(gravityZ) > fabs(gravityX) && fabs(gravityZ) > fabs(gravityY) {
                    raiseAccel = accelNoGravityZ * 10
                    pushAccel = accelNoGravityZ * 10
                    
                    if gravityZ > 0 {
                        raiseAccel = -raiseAccel
                        pushAccel = -pushAccel
                    }
                }
                
                if screenDirection == 3 {
                    raiseAccel = -raiseAccel
                    slideAccel = -slideAccel
                }
            }
        }
        else {
            slideAccel = 0
            raiseAccel = 0
            pushAccel = 0
            resetLinear()
        }
    }
    
    func SlideIt () {
        slideRate = deltaTimeAcc * slideAccel
        
        slideAmount = slideAmount + slideRate * deltaTimeAcc
        
        if slideTime < NSDate().timeIntervalSince1970 - 0.150 && fabs(slideAccel) < 0.03 {
            slideRate = 0
            slideAmount = 0
            slideTime = NSDate().timeIntervalSince1970
        }
        
        if fabs(slideAccel) > 0.03 {
            slideTime = NSDate().timeIntervalSince1970
        }
        
        if slideAmount > 0.17 {
            currentAction = "Slide Right!"
            resetActions()
        }
        
        if slideAmount < -0.17 {
            currentAction = "Slide Left!"
            resetActions()
        }
    }
    
    func RaiseIt (){
        raiseRate = deltaTimeAcc * raiseAccel
        
        raiseAmount = raiseAmount + raiseRate * deltaTimeAcc
        
        if raiseTime < NSDate().timeIntervalSince1970 - 0.150 && fabs(raiseAccel) < 0.03{
            raiseRate = 0
            raiseAmount = 0
            raiseTime = NSDate().timeIntervalSince1970
        }
        
        if raiseAccel > 0.03 {
            raiseTime = NSDate().timeIntervalSince1970
        }
        
        if raiseAmount > 0.19 {
            currentAction = "Raise It!"
            resetActions()
        }
    }
    
    func PushIt () {
        pushRate = deltaTimeAcc * pushAccel
        
        pushAmount = pushAmount + pushRate * deltaTimeAcc
        
        if pushTime < NSDate().timeIntervalSince1970 - 0.100 && pushAccel > -0.03 {
            pushRate = 0
            pushAmount = 0
            pushTime = NSDate().timeIntervalSince1970
        }
        
        if pushAccel < -0.03 {
            pushTime = NSDate().timeIntervalSince1970
        }
        
        if pushAmount < -0.22 {
            currentAction = "Push It!"
            resetActions()
        }
    }
    
    func SpinIt () {
        spinRate = deltaTimeRot * spinAccel
        
        spinAmount = spinAmount + spinRate * deltaTimeRot
        
        if spinTime < NSDate().timeIntervalSince1970 - 0.100 && spinAccel < 0.1 {
            spinRate = 0
            spinAmount = 0
            spinTime = NSDate().timeIntervalSince1970
        }
        
        if spinAccel > 0.1 {
            spinTime = NSDate().timeIntervalSince1970
        }
        
        if spinAccel > 3 {
            resetLinear ()
        }
        
        if spinAmount > 0.7 {
            currentAction = "Spin It!"
            resetActions()
            
        }
    }
    
    func TwistIt () {
        twistRate = deltaTimeRot * twistAccel
        
        twistAmount = twistAmount + fabs(twistRate) * deltaTimeRot
        
        if twistTime < NSDate().timeIntervalSince1970 - 0.100 && fabs(twistAccel) < 0.1 {
            twistRate = 0
            twistAmount = 0
            twistTime = NSDate().timeIntervalSince1970
        }
        
        if twistAccel > 0.1 {
            twistTime = NSDate().timeIntervalSince1970
        }
        
        if twistAccel > 3 {
            resetLinear ()
        }
        
        if twistAmount > 0.80 {
            currentAction = "Twist It!"
            resetActions()
        }
    }
    
    func SmashIt () {
        if smashAccel > smashMax {
            smashMax = smashAccel
        }
        
        smashRate = deltaTimeRot * smashAccel
        
        if smashRate > 1 {
            smashAmount = smashAmount + smashRate * deltaTimeRot
        }
        else {
            smashAmount = 0
            smashRate = 0
        }
        
        if smashTime < NSDate().timeIntervalSince1970 - 0.100 && smashAccel < 0.1 {
            smashRate = 0
            smashAmount = 0
            smashTime = NSDate().timeIntervalSince1970
        }
        
        if smashAccel > 0.1 {
            smashTime = NSDate().timeIntervalSince1970
        }
        
        if smashAmount > 0.15 &&  smashMax > 10 {
            currentAction = "Smash It!"
            resetActions()
            
        }
    }
    
    func Game () {
        if !practiceMode {
            if !waitingAction {
                if previousTimer < NSDate().timeIntervalSince1970 - timer {
                    randomNumber()
                    playCommand(string: currentPopItBank[randomAction])
                    currentAction = ""
                    waitTimer = 0
                    waitingAction = true
                    timer = 1.5 - speedup/2
                    previousTimer = NSDate().timeIntervalSince1970
                }
            }
            else {
                if previousTimer > NSDate().timeIntervalSince1970 - timer{
                    checkAction()
                    if currentAction == currentPopItBank[randomAction]{
                        playNoise(string: currentAction)
                        previousTimer = NSDate().timeIntervalSince1970
                        waitingAction = false
                        currentAction = ""
                        if speedup < 1.0 {
                            speedup = speedup + 0.02
                        }
                        timer = 1.5 - speedup
                    }
                }
                else {
                    endGame = true
                    EndGame()
                }
            }
        }
        else {
            if currentAction != "" {
                CountDown.text = currentAction
                playNoise(string: currentAction)
                currentAction = ""
            }
        }
    }
    
    func checkAction () {
        if currentPopItBank[randomAction] == "Pass It!" && previousTimer < NSDate().timeIntervalSince1970 - timer/2{
            currentAction = "Pass It!"
        }
        if currentPopItBank[randomAction] == "Slide It!" && (currentAction == "Slide Right!" || currentAction == "Slide Right!") {
            currentAction = "Slide It!"
        }
        if currentAction != currentPopItBank[randomAction] && waitTimer == 0  && currentAction != ""{
            waitTimer = NSDate().timeIntervalSince1970
        }
        if waitTimer != 0 {
            if waitTimer > NSDate().timeIntervalSince1970 - 0.200 && currentAction == currentPopItBank[randomAction] {
                waitTimer = 0
            }
            if waitTimer < NSDate().timeIntervalSince1970 - 0.200 {
                endGame = true
                EndGame()
            }
        }
    }
    
    func EndGame () {
        CountDown.text = "GameOver!"
        EndTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(GameViewController.SwitchScreen), userInfo: nil, repeats: false)
    }
    
    func SwitchScreen () {
        EndTimer?.invalidate()
        self.dismiss(animated: true, completion: {() -> Void in
             self.performSegue(withIdentifier: "GameOver", sender: nil)
        })
    }
    
    func playCommand (string: String) {
        
        if string == "Pop It!" {
            let url = Bundle.main.url(forResource: "Audio/PopCommand", withExtension: "m4a")!
            
            do {
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
        else if string == "Swipe It!" {
            let url = Bundle.main.url(forResource: "Audio/SwipeCommand", withExtension: "m4a")!
            
            do {
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
        else if string == "Push It!" {
            let url = Bundle.main.url(forResource: "Audio/PushCommand", withExtension: "m4a")!
            
            do {
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
        else if string == "Raise It!" {
            let url = Bundle.main.url(forResource: "Audio/RaiseCommand", withExtension: "m4a")!
            
            do {
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
        else if string == "Slide Right!" {
            let url = Bundle.main.url(forResource: "Audio/SlideRightCommand", withExtension: "m4a")!
            
            do {
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
        else if string == "Slide Left!" {
            let url = Bundle.main.url(forResource: "Audio/SlideLeftCommand", withExtension: "m4a")!
            
            do {
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
        else if string == "Slide It!" {
            let url = Bundle.main.url(forResource: "Audio/SlideCommand", withExtension: "m4a")!
            
            do {
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
        else if string == "Spin It!" {
            let url = Bundle.main.url(forResource: "Audio/SpinCommand", withExtension: "m4a")!
            
            do {
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
        else if string == "Twist It!" {
            let url = Bundle.main.url(forResource: "Audio/TwistCommand", withExtension: "m4a")!
            
            do {
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
        else if string == "Smash It!" {
            let url = Bundle.main.url(forResource: "Audio/SmashCommand", withExtension: "m4a")!
            
            do {
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
        else if string == "Pass It!" {
            let url = Bundle.main.url(forResource: "Audio/PassCommand", withExtension: "m4a")!
            
            do {
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
    }
    
    func playNoise (string: String) {
        
        if string == "Pop It!" {
            let url = Bundle.main.url(forResource: "Audio/PopNoise", withExtension: "m4a")!
            
            do {
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
        else if string == "Swipe It!" {
            let url = Bundle.main.url(forResource: "Audio/SwipeNoise", withExtension: "m4a")!
            
            do {
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
        else if string == "Push It!" {
            let url = Bundle.main.url(forResource: "Audio/PushNoise", withExtension: "m4a")!
            
            do {
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
        else if string == "Raise It!" {
            let url = Bundle.main.url(forResource: "Audio/RaiseNoise", withExtension: "m4a")!
            
            do {
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
        else if string == "Slide Right!" {
            let url = Bundle.main.url(forResource: "Audio/SlideRightNoise", withExtension: "m4a")!
            
            do {
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
        else if string == "Slide Left!" {
            let url = Bundle.main.url(forResource: "Audio/SlideLeftNoise", withExtension: "m4a")!
            
            do {
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
        else if string == "Slide It!" {
            let url = Bundle.main.url(forResource: "Audio/SlideNoise", withExtension: "m4a")!
            
            do {
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
        else if string == "Spin It!" {
            let url = Bundle.main.url(forResource: "Audio/SpinNoise", withExtension: "m4a")!
            
            do {
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
        else if string == "Twist It!" {
            let url = Bundle.main.url(forResource: "Audio/TwistNoise", withExtension: "m4a")!
            
            do {
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
        else if string == "Smash It!" {
            let url = Bundle.main.url(forResource: "Audio/SmashNoise", withExtension: "m4a")!
            
            do {
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
        else if string == "Pass It!" {
            let url = Bundle.main.url(forResource: "Audio/PassNoise", withExtension: "m4a")!
            
            do {
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
    }
    
    func GameInit () {
        currentAction = ""
        randomAction = 0
        waitTimer = 0
        waitingAction = false
        previousTimer = NSDate().timeIntervalSince1970
        endGame = false
        timer = 3
        speedup = 0
        tempCheck = ""
        if easyMode {
            currentPopItBank.append(popItBank[1])
            currentPopItBank.append(popItBank[2])
            currentPopItBank.append(popItBank[3])
            currentPopItBank.append(popItBank[6])
        }
        else if extremeMode {
            for i in 0...popItBank.count - 3 {
                currentPopItBank.append(popItBank[i])
            }
        }
        else {
            currentPopItBank.append(popItBank[1])
            currentPopItBank.append(popItBank[2])
            currentPopItBank.append(popItBank[3])
            currentPopItBank.append(popItBank[4])
            currentPopItBank.append(popItBank[6])
            currentPopItBank.append(popItBank[7])
            currentPopItBank.append(popItBank[8])
            currentPopItBank.append(popItBank[9])
        }
        if multiPlayer {
            currentPopItBank.append(popItBank[10])
        }
        currentPopItBank = popItBank
        countDownTimer = 3
    }
    
    func resetLinear () {
        slideRate = 0
        slideAmount = 0
        raiseRate = 0
        raiseAmount = 0
        pushRate = 0
        pushAmount = 0
    }
    
    func resetActions() {
        spinRate = 0
        spinAmount = 0
        twistRate = 0
        twistAmount = 0
        smashRate = 0
        smashAmount = 0
        slideRate = 0
        slideAmount = 0
        raiseRate = 0
        raiseAmount = 0
        pushRate = 0
        pushAmount = 0
    }
    
    func CountOff () {
        CountDown.text = "Starting in " + String(countDownTimer) + "!"
        countDownTimer = countDownTimer - 1
        if countDownTimer < 0 {
            CountOffTimer?.invalidate()
            CountDown.text = ""
            GameInit()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

