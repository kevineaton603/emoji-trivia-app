//
//  ViewController.swift
//  emoji-quiz
//
//  Created by Eaton, Kevin on 2/10/19.
//  Copyright © 2019 Eaton, Kevin. All rights reserved.
//

import UIKit
import FirebaseDatabase

class QuizMainController: UIViewController {
    @IBOutlet weak var QuizSelectorSegment: UISegmentedControl!
    @IBOutlet weak var QuizNameLabel: UILabel!
    var ref: DatabaseReference!
    var quiz: Quiz = Quiz()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = Database.database().reference()
        quiz.addQuestion(q: Question(mAnswer: "canada", mHint:"🇨🇦"))
        //How to store encode data to send to FireBase
        var json: [String: Any] = [String: Any]()
        var jsonData: Data=Data()
        do{
            //create encoder then encode
            let jsonEncoder = JSONEncoder()
            jsonData = try jsonEncoder.encode(quiz)
            //Use this is serialize to jsonObject
            json = try JSONSerialization.jsonObject(with: jsonData, options:[]) as! [String: Any]
            //How to decode information from FireBase will be used later
            let jsonDecoder = JSONDecoder()
            let quizinfo = try jsonDecoder.decode(Quiz.self, from: jsonData)
            print(quizinfo.getQuestion(index: 0).mAnswer)
        } catch {
            print(error.localizedDescription)
        }
        //set values to Firebase
        self.ref.child("question").setValue(json)
        self.ref.child("questions").setValue(["questions": "america"])
        //get values from Firebase
        self.ref.child("questions").observeSingleEvent(of: .value, with: {(snapshot) in
            let value = snapshot.value as? NSDictionary
            let username = value?["username"] as? String ?? ""
            print(username)
        }) { (error) in
            print(error)
            print(error.localizedDescription)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if (QuizSelectorSegment.numberOfSegments != 3){
            QuizSelectorSegment.insertSegment(withTitle: "Games", at: 2, animated: true)
        }
    }
    @IBAction func indexChanged(_ sender: Any) {
        switch QuizSelectorSegment.selectedSegmentIndex
        {
        case 0:
            QuizNameLabel.text = "Countries"
        case 1:
            QuizNameLabel.text = "Movies"
        case 2:
            QuizNameLabel.text = "Games"
        default:
            break
        }
    }
    
}
