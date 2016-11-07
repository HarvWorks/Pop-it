//
//  ViewController.swift
//  Pop-It
//
//  Created by Harvey Chui on 11/6/16.
//  Copyright © 2016 Pokemon Kno. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let multiPlayer: Bool = true
    let extremeMode: Bool = false
    let easyMode: Bool = false
    let practiceMode: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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


}

