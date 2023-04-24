//
//  GameViewController.swift
//  BubbleGame
//
//  Created by Chenling Zhang on 19/4/2023.
//

import Foundation
import UIKit

class GameViewController: UIViewController{
    var time: Int = 60
    var playerName: String? = ""
    var maxBubbleOnScreen: Int = 15
    var gamePrepareTime: Int = 3
    var gameTimer = Timer()
    var wakeUpTimer = Timer()
    var gameStartTimer = Timer()
    var randomRemoveTimer = Timer()
    var bubbleList: [Bubble] = []
    var currentScore: Int = 0
    var playersHighScore:[GameScore] = []
    var lastClickBubble:[Bubble] = []
    
    let DEFAULT = UserDefaults.standard
    let HIGH_SCORE_KEY = "bestScore"
    
    @IBOutlet weak var currentScoreLabel: UILabel!
    @IBOutlet weak var gameTimeLabel: UILabel!
    @IBOutlet weak var bestScoreLabel: UILabel!
    @IBOutlet weak var gameReadyLabel: UILabel!
    
    override func viewDidLoad() {
        if checkNavigationBarStatus() {
            self.navigationController!.setNavigationBarHidden(false, animated: true)
        }
        
        super.viewDidLoad()
        // Game Timer counting
        gameTimeLabel.text = String(time)
        bestScoreLabel.text = String(readPlayerInfo())
        
        // Game prepare timer start
        gameStartTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){
            timer in
            self.gameTimer.invalidate()
            self.gameReadyLabel.text = String(self.gamePrepareTime)
            self.gamePrepareTime -= 1
            if self.gamePrepareTime < 0 {
                self.gameReadyLabel.text = ""
                self.gameStartTimer.invalidate()
            }
        }
        
        wakeUpTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: false) {
            timer in
            self.timerWakeUp()
        }
        
        randomRemoveTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
            timer in
            self.randomRemove()
        }
    }
    
    func readPlayerInfo() -> Int{
        var score = 0
        playersHighScore = readScore()
        if playersHighScore.count != 0 {
            for gameScore in playersHighScore{
                if gameScore.name == playerName{
                    score = gameScore.score
                }
            }
        }
        return score
    }
    
    // This time used to wake up game timer
    func timerWakeUp(){
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){
            timer in
            self.getRemainTiming()
            self.generateBubbles()
        }
    }
    
    // This function used to counting down the time of the game, game will stopped when time become 0
    func getRemainTiming(){
        time -= 1
        gameTimeLabel.text = String(time)
        
        if time == 0 {
            // stop gameTimer and bubble create timer
            gameTimer.invalidate()
            randomRemoveTimer.invalidate()
            // save score if current score > best score
            if isNeedSave() {
                saveScore()
                print("score has been saved by the player name: \(String(describing: playerName)) score:\(String(describing: bestScoreLabel.text))")
            }
            // alert game result and redirect to the home page
            showGameOverAlert()
        }
    }
    
    // This function used to generate bubbles
    func generateBubbles(){
        if bubbleList.count < maxBubbleOnScreen{
            let numberOfCreate = maxBubbleOnScreen - bubbleList.count
            
            for _ in 0..<numberOfCreate{
                let newBubble = Bubble()
                newBubble.addTarget(self, action: #selector(bubbleOnclick), for: .touchUpInside)
                
                // Check new bubble is overlap to the other bubbles on the screen
                if !isOverlap(newBubble){
                    bubbleList.append(newBubble)
                    newBubble.animation()
                    view.addSubview(newBubble)
                }
                else{continue}
            }
        }
        
        else {
            return
        }
    }
    
    // This function used to set the operation about bubble onclick
    @objc func bubbleOnclick(_ sender: Bubble){
        var point = sender.value
        
        if lastClickBubble.count == 0 {
            lastClickBubble.append(sender)
        }
        else if (lastClickBubble[0].backgroundColor == sender.backgroundColor){
            point = point + Int(Double(point) * 1.5)
        }
        lastClickBubble[0] = sender
        
        // Add score and update to label
        currentScore += point
        updateCurrentScore()
        let bestScore = Int(bestScoreLabel.text!)
        if currentScore >= bestScore!{
            bestScoreLabel.text = String(currentScore)
        }
        
        // Add + value
        let valueLabel = UILabel(frame: CGRect(x: sender.frame.origin.x + sender.frame.width, y: sender.frame.origin.y - 20, width: 100, height: 20))
        if point > sender.value{
            valueLabel.text = "bones! +\(point)"
        }
        else{
            valueLabel.text = "+\(point)"
            
        }
        valueLabel.textColor = .orange
        valueLabel.textAlignment = .center
        valueLabel.font = UIFont.systemFont(ofSize: 20)
        
        // make sure the label will not out of safr area
        let safeAreaInsets = UIApplication.shared.windows.first?.safeAreaInsets ?? UIEdgeInsets.zero
        valueLabel.frame.origin.x = min(valueLabel.frame.origin.x, sender.superview!.frame.maxX - valueLabel.frame.width - safeAreaInsets.right)
        valueLabel.frame.origin.y = max(valueLabel.frame.origin.y, safeAreaInsets.top)
        view.addSubview(valueLabel)
        
        // remove from screen
        sender.flash()
        sender.removeFromSuperview()
        
        // remove the point label with arise animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.animate(withDuration: 0.5, animations: {
                valueLabel.frame.origin.y -= 20
                valueLabel.alpha = 0
            }, completion: { _ in
                valueLabel.removeFromSuperview()
            })
        }
        
        // remove from list
        if let index = bubbleList.firstIndex(of: sender){
            bubbleList.remove(at: index)
        }
    }
    
    // This function used to check is the new created bubble overlap with the bubble on screen
    func isOverlap(_ newBubble: Bubble) -> Bool{
        for bubble in bubbleList {
            if newBubble.frame.intersects(bubble.frame){
                return true
            }
        }
        return false
    }
    
    // This function used to update the current score label
    func updateCurrentScore(){
        currentScoreLabel.text = String(currentScore)
    }
    
    // save data 2 user default
    func saveScore(){
        let record = GameScore(name: playerName , score: currentScore)
        let gameRecorder = getPlayerInfo(record)
        
        if gameRecorder.name != nil {
            let index = playersHighScore.firstIndex(of: gameRecorder)
            playersHighScore[index!].score = record.score
        }
        
        else if gameRecorder.name == nil && gameRecorder.score == -1{
            playersHighScore.append(record)
        }
        
        DEFAULT.set(try? PropertyListEncoder().encode(playersHighScore), forKey: HIGH_SCORE_KEY)
    }
    
    // check is it need to save
    func isNeedSave() -> Bool{
        if (playersHighScore.count == 0) {return true}
        for gameScore in playersHighScore {
            if gameScore.name == playerName && gameScore.score < currentScore{
                return true
            }
            
            if gameScore.name == playerName && gameScore.score > currentScore {
                return false
            }
        }
        return true
    }
    
    // Get player name and score if exist
    func getPlayerInfo(_ record: GameScore) -> GameScore{
        for player in playersHighScore{
            if player.name == record.name {
                return player
            }
        }
        return GameScore(name: nil, score: -1)
    }
    
    // This function used to readomly remove some bubbles
    func randomRemove(){
        var i = 0
        while i < bubbleList.count {
            if Int.random(in: 0..<100) < 30 {
               let removeBubble = bubbleList[i]
                removeBubble.removeFromSuperview()
                bubbleList.remove(at: i)
                i += 1
            }
        }
    }
    
    func showGameOverAlert(){
        let alert = UIAlertController(title: "Game Over", message: "Your Current score is \(currentScore)", preferredStyle: .alert)
        let destnationView = self.storyboard?.instantiateViewController(withIdentifier: "HighScoreViewController") as! HighScoreViewController
        let action = UIAlertAction(title: "OK", style: .default) {
            _ in self.navigationController?.pushViewController(destnationView, animated: true)
        }
        alert.addAction(action)
        present(alert,animated: true,completion: nil)
    }
    
    func readScore() -> [GameScore]{
        if let saveData = DEFAULT.value(forKey: HIGH_SCORE_KEY) as? Data {
            if let savedGameHighScores = try? PropertyListDecoder().decode(Array<GameScore>.self, from: saveData){
                return savedGameHighScores
            }
        }
       
        return []
    }
    
    func checkNavigationBarStatus() -> Bool{
        return self.navigationController!.navigationBar.isHidden
    }
}

struct GameScore:Codable, Equatable{
    var name: String?
    var score: Int
    
    static func == (lhs: GameScore, rhs: GameScore) -> Bool {
        return lhs.name == rhs.name && lhs.score == rhs.score
    }
}
