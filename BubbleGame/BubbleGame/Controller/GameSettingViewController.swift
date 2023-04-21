//
//  GameSettingViewController.swift
//  BubbleGame
//
//  Created by Chenling Zhang on 19/4/2023.
//

import Foundation
import UIKit

class GameSettingViewController: UIViewController {
    var currentMaxTime: Int = 30
    var currentMaxBubble: Int = 10
    
    @IBOutlet weak var playerName: UITextField!
    @IBOutlet weak var maxTime: UILabel!
    @IBOutlet weak var maxBubbles: UILabel!
    
    override func viewDidLoad() {
        if checkNavigationBarStatus() {
            self.navigationController!.setNavigationBarHidden(false, animated: true)
        }
        
        super.viewDidLoad()
        maxTime.text = String(currentMaxTime)
        maxBubbles.text = String(currentMaxBubble)
    }
    
    @IBAction func maxBubbleSlider(_ sender: UISlider) {
        currentMaxBubble = Int(sender.value)
        maxBubbles.text = String(currentMaxBubble)
    }
    
    @IBAction func timeLimitSlider(_ sender: UISlider) {
        currentMaxTime = Int(sender.value)
        maxTime.text = String(currentMaxTime)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startGame" {
            let destination = segue.destination as! GameViewController
            destination.maxBubbleOnScreen = currentMaxBubble
            destination.time = currentMaxTime
            destination.playerName = playerName.text
        }
    }
    
    func checkNavigationBarStatus() -> Bool{
        return self.navigationController!.navigationBar.isHidden
    }
}
