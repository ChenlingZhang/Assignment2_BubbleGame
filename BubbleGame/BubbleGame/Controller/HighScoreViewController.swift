//
//  HighScoreViewController.swift
//  BubbleGame
//
//  Created by Chenling Zhang on 19/4/2023.
//

import Foundation
import UIKit

class HighScoreViewController: UIViewController{
    let HIGH_SCORE_KEY = "bestScore"
    var playerHighScore = [GameScore]()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        playerHighScore = readScore()
        
        playerHighScore.sort{
            $0.score > $1.score
        }
    }
    
    func readScore() -> [GameScore]{
        let defaults = UserDefaults.standard
        
        if let saveData = defaults.value(forKey: HIGH_SCORE_KEY) as? Data {
            if let savedGameHighScores = try? PropertyListDecoder().decode(Array<GameScore>.self, from: saveData){
                return savedGameHighScores
            }
        }
       
        return []
    }
}

extension HighScoreViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(playerHighScore[indexPath.row].name)
    }
}

extension HighScoreViewController:UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerHighScore.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let playerScore = playerHighScore[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "highScoreCell", for: indexPath)
        cell.textLabel?.text = playerScore.name
        cell.detailTextLabel?.text = "Score:\(playerScore.score)"
        return cell
    }
}

