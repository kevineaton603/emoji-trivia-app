//
//  QuizGameController.swift
//  emoji-quiz
//
//  Created by Eaton, Kevin on 2/10/19.
//  Copyright © 2019 Eaton, Kevin. All rights reserved.
//

import UIKit
import FirebaseDatabase
import AVFoundation

class QuizGameController: UIViewController {
    @IBOutlet var AlphabetSoup: [UIButton]!
    @IBOutlet weak var NextQuestion: UIButton!
    @IBOutlet weak var ScoreLabel: UILabel!
    @IBOutlet weak var LivesLabel: UILabel!
    @IBOutlet weak var HintLabel: UILabel!
    @IBOutlet weak var AnswerLabel: UILabel!
    public var quiz: Quiz = Quiz()
    var quizName = ""
    var numberOfQuestions = 5
    var numberOfLives = 3
    var player: AVAudioPlayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        print(quizName)
        let qref = Database.database().reference().child("questions")
        qref.observeSingleEvent(of: .value, with: {(snapshot) in
            if let value = snapshot.value as? [String: NSArray]{
                print(value)
                //let jsonDecoder = JSONDecoder()
                let quizData = value[self.quizName]
                var questions = [Question]()
                for questionData in quizData ?? NSArray() {
                    let question = questionData as! NSDictionary
                    questions.append(Question(mAnswer: question.value(forKey: "mAnswer") as! String, mHint: question.value(forKey: "mHint") as! String))
                }
                print(questions)
                self.quiz.addQuestions(q: questions)
                self.updateUI()
                
            } else {
                print("Value Error\n\n")
            }
            
        }) { (error) in
            print(error)
            print(error.localizedDescription)
        }
        // Do any additional setup after loading the view.
        
    }
    @IBAction func buttonTaped(_ sender:UIButton){
        let letter = sender.titleLabel?.text ?? ""
        print(letter)
        quiz.mLetterGuessed.append(letter)
        if !quiz.getQuestion(index: quiz.mCurrentQuestion).mAnswer.contains(letter.uppercased()) && !quiz.getQuestion(index: quiz.mCurrentQuestion).mAnswer.contains(letter.lowercased()){
            do{
                if let url = Bundle.main.url(forResource: "doh", withExtension: "mp3"){
                    player = try AVAudioPlayer(contentsOf: url)
                    player.play()
                }
            } catch {
                print("Error\n")
            }
            quiz.mLives-=1
        }
        sender.isEnabled = false
        self.updateUI()
        
    }
    @IBAction func NextQuestionTap(_ sender: Any) {
        quiz.mLetterGuessed.removeAll()
        quiz.mCurrentQuestion+=1
        quiz.mScore += 1
        
        if(quiz.mCurrentQuestion >= quiz.mMaxQuestion || quiz.mCurrentQuestion >= numberOfQuestions){
            let alert = UIAlertController(title: "Enter Score", message: "Please Enter Your Name", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
                print(alert.textFields![0].text! as String)
                do{
                    
                    let quizData: [String: String] = ["Name":alert.textFields![0].text! as String, "Score": String(self.quiz.mScore)]
                    //create encoder then encode
                    let jsonEncoder = JSONEncoder()
                    let jsonData: Data = try jsonEncoder.encode(quizData)
                    //Use this is serialize to jsonObject
                    let json = try JSONSerialization.jsonObject(with: jsonData, options:[]) as! [String: String]
                    let qref = Database.database().reference()
                    qref.child("score").child(self.quizName).childByAutoId().setValue(json)
                } catch {
                    print(error.localizedDescription)
                }
            }))
            alert.addTextField { (TextField) in
                TextField.placeholder = "Enter Your Name"
            }
            self.present(alert, animated: true, completion: nil)
            
        } else {
            for button in AlphabetSoup{
                button.isEnabled = true
                updateUI()
            }
        }
        
        
    }
    func updateUI(){
        LivesLabel.text = String(repeating: "❤️", count: quiz.mLives)
        if(HintLabel.text != quiz.getQuestion(index: quiz.mCurrentQuestion).mHint){
            //Fade Out
            UIView.animate(withDuration: 1.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.HintLabel.alpha = 0.0
            }, completion: {
                (finished: Bool) -> Void in
                self.HintLabel.text = self.quiz.getQuestion(index: self.quiz.mCurrentQuestion).mHint
                // Fade in
                UIView.animate(withDuration: 1.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    self.HintLabel.alpha = 1.0
                }, completion: nil)
            })
        }
        ScoreLabel.text = String(quiz.mScore)
        var answerDisplayed: String = ""
        var wordComplete: Bool = true
        for char in quiz.getQuestion(index: quiz.mCurrentQuestion).mAnswer{
            //print("char:" + String(char))
            if quiz.mLetterGuessed.contains(String(char).lowercased()) || quiz.mLetterGuessed.contains(String(char).uppercased()){
                //print("char exists")
                answerDisplayed += (String(char) + " ")
            } else if (char == " "){
                answerDisplayed += (" ")
            }
            else{
                answerDisplayed += ("_ ")
                wordComplete = false
            }
        }
        AnswerLabel.text = answerDisplayed
        if(wordComplete){
            do{
                if let url = Bundle.main.url(forResource: "woohoo", withExtension: "mp3"){
                    player = try AVAudioPlayer(contentsOf: url)
                    player.play()
                }
            } catch {
                print("Error\n")
            }
            NextQuestion.isEnabled=true
        } else {
            NextQuestion.isEnabled=false
        }
    }
    
}
