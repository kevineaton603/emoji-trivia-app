//
//  HighScoreViewController.swift
//  emoji-quiz
//
//  Created by Eaton, Kevin on 2/12/19.
//  Copyright © 2019 Eaton, Kevin. All rights reserved.
//

import UIKit
import FirebaseDatabase

class HighScoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    //Table View Function
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.HighScoreList.count
    }
    //Table View Function
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("In Table View")
        var cell: UITableViewCell = self.HighScoreTable.dequeueReusableCell(withIdentifier: "cell") as! UITableViewCell
        let cellInfo = self.HighScoreList[indexPath.row]
        print(cellInfo["Name"] ?? "")
        print(cellInfo["Score"] ?? "")
        cell.textLabel?.text = cellInfo["Name"]! + "  " + cellInfo["Score"]!
        return cell
    }
    @IBOutlet weak var HighScoreTable: UITableView!
    @IBOutlet weak var HighScores: UILabel!
    @IBOutlet weak var QuizSelectorSegment: UISegmentedControl!
    var databaseRef: DatabaseReference!
    var HighScoreList: [[String: String]] = [[String: String]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference()
        updateView(selector: "Countries")
        HighScoreTable.delegate = self
        HighScoreTable.dataSource = self
        self.HighScoreTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        if (QuizSelectorSegment.numberOfSegments != 3){
            QuizSelectorSegment.insertSegment(withTitle: "Games", at: 2, animated: true)
        }
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    func updateView(selector: String){
        let quizHighScore = self.databaseRef.child("score").child(selector.lowercased() as String)
        self.HighScoreList.removeAll()
        //Gets the high score from the database
        quizHighScore.observeSingleEvent(of: .value, with: {(snapshot) in
            if let value = snapshot.value as? [String: Any]{
                for (index, element) in value.enumerated(){
                    print(index, element)
                    let info = element.value as! NSDictionary
                    let name = info.value(forKey: "Name") as! String
                    let score = info.value(forKey: "Score") as! String
                    self.HighScoreList.append(["Name": name, "Score": score])
                    
                }
                //Sorts List if more than two elements exist
                if self.HighScoreList.count >= 2 {
                    self.HighScoreList = self.HighScoreList.sorted{$0["Score"]! > $1["Score"]!}
                }
                //Reloads the table
                self.HighScoreTable.reloadData()
                
            } else {
                //Displays if there is no high score
                self.HighScoreList.append(["Name": "No High Score Yet", "Score": ""])
                print("Value Error\n\n")
                self.HighScoreTable.reloadData()
            }
            
        }) { (error) in
            print(error)
            print(error.localizedDescription)
        }
    }
    @IBAction func SelectorTap(_ sender: UISegmentedControl) {
        let quizName = sender.titleForSegment(at: sender.selectedSegmentIndex)
        updateView(selector: quizName as! String)
    }

}
