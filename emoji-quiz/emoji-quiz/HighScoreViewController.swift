//
//  HighScoreViewController.swift
//  emoji-quiz
//
//  Created by Eaton, Kevin on 2/12/19.
//  Copyright © 2019 Eaton, Kevin. All rights reserved.
//

import UIKit
import FirebaseDatabase

class HighScoreViewController: UIViewController {

    @IBOutlet weak var HighScores: UILabel!
    @IBOutlet weak var QuizSelectorSegment: UISegmentedControl!
    var databaseRef: DatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference()

        
        // Do any additional setup after loading the view.
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if (QuizSelectorSegment.numberOfSegments != 3){
            QuizSelectorSegment.insertSegment(withTitle: "Games", at: 2, animated: true)
        }
    }

    @IBAction func SelectorTap(_ sender: UISegmentedControl) {
        let quizName = sender.titleForSegment(at: sender.selectedSegmentIndex)
        print(quizName ?? "Nope")
        let quizHighScore = self.databaseRef.child("score").child(quizName!.lowercased() as String)
        var scoresDisplay = ""
        quizHighScore.observeSingleEvent(of: .value, with: {(snapshot) in
            if let value = snapshot.value as? [String: Any]{
                for (index, element) in value.enumerated(){
                    print(index, element)
                    let info = element.value as! NSDictionary
                    let name = info.value(forKey: "Name") as! String
                    let score = info.value(forKey: "Score") as! String
                    scoresDisplay += (name + "\t" + score + "\n")
                    print(info.value(forKey: "Name")!)
                    
                }
                print(scoresDisplay)
                self.HighScores.text=scoresDisplay
                
            } else {
                self.HighScores.text="No High Scores Yet"
                print("Value Error\n\n")
            }
            
        }) { (error) in
            print(error)
            print(error.localizedDescription)
        }
    }

}
