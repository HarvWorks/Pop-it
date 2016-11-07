//
//  OptionsViewController.swift
//  Pop-It
//
//  Created by Harvey Chui on 11/7/16.
//  Copyright © 2016 Pokemon Kno. All rights reserved.
//

import UIKit

class OptionsViewController: UIViewController {
    
    var multiPlayer = Bool()
    var extremeMode = Bool()
    var easyMode = Bool()
    var practiceMode = Bool()
    @IBOutlet weak var Multi: UISwitch!
    @IBOutlet weak var Extreme: UISwitch!
    @IBOutlet weak var Easy: UISwitch!
    @IBOutlet weak var Practice: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Multi.setOn(multiPlayer, animated: true)
        Easy.setOn(easyMode, animated: true)
        Extreme.setOn(extremeMode, animated: true)
        Practice.setOn(practiceMode, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func MultiPlayerAction(_ sender: UISwitch) {
        multiPlayer = Multi.isOn
    }
    @IBAction func ExtremeMode(_ sender: UISwitch) {
        extremeMode = Extreme.isOn
        easyMode = false
        Easy.setOn(easyMode, animated: true)
    }
    @IBAction func EasyMode(_ sender: UISwitch) {
        easyMode = Easy.isOn
        extremeMode = false
        Extreme.setOn(extremeMode, animated: true)
    }
    @IBAction func PracticeMode(_ sender: UISwitch) {
        practiceMode = Practice.isOn
    }
    
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let newVC = segue.destination as! GameViewController
        newVC.multiPlayer = multiPlayer
        newVC.extremeMode = extremeMode
        newVC.easyMode = easyMode
        newVC.practiceMode = practiceMode
    }
    

}
