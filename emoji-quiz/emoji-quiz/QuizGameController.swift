//
//  QuizGameController.swift
//  emoji-quiz
//
//  Created by Eaton, Kevin on 2/10/19.
//  Copyright © 2019 Eaton, Kevin. All rights reserved.
//

import UIKit
import FirebaseDatabase

class QuizGameController: UIViewController {
    @IBOutlet var AlphabetSoup: [UIButton]!
    @IBOutlet weak var NextQuestion: UIButton!
    public var quiz: Quiz = Quiz()
    var quizName = ""
    @IBOutlet weak var LivesLabel: UILabel!
    @IBOutlet weak var HintLabel: UILabel!
    @IBOutlet weak var AnswerLabel: UILabel!
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
        quiz.letterGuessed.append(letter)
        if !quiz.getQuestion(index: quiz.currentQuestion).mAnswer.contains(letter.uppercased()) && !quiz.getQuestion(index: quiz.currentQuestion).mAnswer.contains(letter.lowercased()){
            quiz.mLives-=1
        }
        sender.isEnabled = false
        print(quiz.letterGuessed)
        self.updateUI()
        
    }
    @IBAction func NextQuestionTap(_ sender: Any) {
        quiz.letterGuessed.removeAll()
        quiz.currentQuestion+=1
        for button in AlphabetSoup{
            button.isEnabled = true
        }
        updateUI()
    }
    func updateUI(){
        LivesLabel.text = String(repeating: "❤️", count: quiz.mLives)
        HintLabel.text = quiz.getQuestion(index: quiz.currentQuestion).mHint
        AnswerLabel.text = quiz.getQuestion(index: quiz.currentQuestion).mAnswer
        var answerDisplayed: String = ""
        var wordComplete: Bool = true
        for char in quiz.getQuestion(index: quiz.currentQuestion).mAnswer{
            print("char:" + String(char))
            if quiz.letterGuessed.contains(String(char).lowercased()) || quiz.letterGuessed.contains(String(char).uppercased()){
                print("char exists")
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
            NextQuestion.isEnabled=true
        } else {
            NextQuestion.isEnabled=false
        }
    }
    
}
