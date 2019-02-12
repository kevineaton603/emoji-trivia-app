//
//  ViewController.swift
//  emoji-quiz
//
//  Created by Eaton, Kevin on 2/10/19.
//  Copyright © 2019 Eaton, Kevin. All rights reserved.
//

import UIKit
import FirebaseDatabase

class QuizController: UIViewController {
    @IBOutlet weak var QuizSelectorSegment: UISegmentedControl!
    @IBOutlet weak var QuizNameLabel: UILabel!
    @IBOutlet weak var LivesLabel: UILabel!
    @IBOutlet weak var QuestionLabel: UILabel!
    
    var ref: DatabaseReference!
    var quiz: Quiz = Quiz()
    var countries: [Question] =  [Question]()
    var movies: [Question] =  [Question]()
    var games: [Question] =  [Question]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = Database.database().reference()
        quiz.addQuestion(q: Question(mAnswer: "canada", mHint:"🍁🇨🇦"))
        /*countries.append(quiz.getQuestion(index: 0))
        countries.append(Question(mAnswer: "America", mHint: "🦅🏈"))
        countries.append(Question(mAnswer: "United Kingdom", mHint: "☕️💂‍♂️"))
        countries.append(Question(mAnswer: "Dominican Republic", mHint: "🇩🇴"))
        countries.append(Question(mAnswer: "Italy", mHint: "🍕🍝"))
        
        movies.append(Question(mAnswer: "Jaws", mHint: "🦈⛵️"))
        movies.append(Question(mAnswer: "The Exorcist", mHint: "🧟‍♀️⛪️"))
        movies.append(Question(mAnswer: "Batman", mHint: "🦇🤵"))
        movies.append(Question(mAnswer: "Jurassic Park", mHint: "🦖🎟"))
        movies.append(Question(mAnswer: "Ghostbusters", mHint: "👻🚫"))
        
        games.append(Question(mAnswer: "Wii Sports", mHint: "🎳🏌️‍♂️"))
        games.append(Question(mAnswer: "Skyrim", mHint: "🧙‍♂️⚔️"))
        games.append(Question(mAnswer: "Minecraft", mHint: "⛏🛠"))
        games.append(Question(mAnswer: "Assassin's Creed", mHint: "🗡🙏"))
        games.append(Question(mAnswer: "Rocket League", mHint: "🚀⚽️"))
        

        //How to store encode data to send to FireBase
        let questions: [String: [Question]] = [
            "countries": countries,
            "movies": movies,
            "games": games
        ]
        var jsonQuestions: [String: Any] = [String:Any]()
        //var json: [String: Any] = [String: Any]()
        //var jsonData: Data=Data()
        var jsonDataQuestions: Data=Data()
        do{
            //create encoder then encode
            let jsonEncoder = JSONEncoder()
            //jsonData = try jsonEncoder.encode(quiz)
            //Use this is serialize to jsonObject
            jsonDataQuestions = try jsonEncoder.encode(questions)
            jsonQuestions = try JSONSerialization.jsonObject(with: jsonDataQuestions, options: []) as! [String: Any]
            //json = try JSONSerialization.jsonObject(with: jsonData, options:[]) as! [String: Any]
            //How to decode information from FireBase will be used later
            //let jsonDecoder = JSONDecoder()
            //let quizinfo = try jsonDecoder.decode(Quiz.self, from: jsonData)
            //print(quizinfo.getQuestion(index: 0).mAnswer)
        } catch {
            print(error.localizedDescription)
        }
        //set values to Firebase
        self.ref.child("questions").setValue(jsonQuestions)*/
        //get values from Firebase
        self.ref.child("questions").observeSingleEvent(of: .value, with: {(snapshot) in
            if let value = snapshot.value as? [String: NSArray]{
                print(value)
                //let jsonDecoder = JSONDecoder()
                let countries = value["countries"]
                var questions = [Question]()
                for country in countries ?? NSArray() {
                    print(country)
                    let question = country as! NSDictionary
                    questions.append(Question(mAnswer: question.value(forKey: "mAnswer") as! String, mHint: question.value(forKey: "mHint") as! String))
                }
                print(questions)
                
            } else {
                print("Value Error\n\n")
            }
            
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
