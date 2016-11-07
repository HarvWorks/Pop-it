//
//  ViewController.swift
//  Pop-It
//
//  Created by Harvey Chui on 11/6/16.
//  Copyright © 2016 Pokemon Kno. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var backgroundMusicPlayer = AVAudioPlayer()
    
    let multiPlayer: Bool = true
    let extremeMode: Bool = false
    let easyMode: Bool = false
    let practiceMode: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        playBackgroundMusic()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!){
        if (segue.identifier == "toOptionsMenu") {
            let newVC = segue.destination as! OptionsViewController
            newVC.multiPlayer = multiPlayer
            newVC.extremeMode = extremeMode
            newVC.easyMode = easyMode
            newVC.practiceMode = practiceMode
        }
        else {
            let newVC = segue.destination as! GameViewController
            newVC.multiPlayer = multiPlayer
            newVC.extremeMode = extremeMode
            newVC.easyMode = easyMode
            newVC.practiceMode = practiceMode
        }
    }
    
    func playBackgroundMusic() {
        let url = Bundle.main.url(forResource: "Audio/BackgroundMusic", withExtension: "wav")
        guard let newURL = url else {
            print("Could not find file: BackgroundMusic")
            return
        }
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: newURL)
            backgroundMusicPlayer.volume = 0.20
            backgroundMusicPlayer.numberOfLoops = -1
            backgroundMusicPlayer.prepareToPlay()
            backgroundMusicPlayer.play()
        } catch let error as NSError {
            print(error.description)
        }
    }


}

