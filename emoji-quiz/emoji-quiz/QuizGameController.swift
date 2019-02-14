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
    var databaseReference : DatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Gets database reference
        databaseReference = Database.database().reference()
        
        // Sets the quiz lives to the number of lives indicated by the user
        if(numberOfLives < quiz.mLives){
            quiz.mLives = numberOfLives
        }
        //Pulls down the questions from the database and stores them
        //in the Quiz object
        let questionsReference = databaseReference.child("questions")
        questionsReference.observeSingleEvent(of: .value, with: {(snapshot) in
            if let value = snapshot.value as? [String: NSArray]{
                let quizData = value[self.quizName]
                var questions = [Question]()
                for questionData in quizData ?? NSArray() {
                    let question = questionData as! NSDictionary
                    questions.append(Question(mAnswer: question.value(forKey: "mAnswer") as! String, mHint: question.value(forKey: "mHint") as! String))
                }
                self.quiz.addQuestions(q: questions)
                //Shuffles the questions
                self.quiz.mQuestions.shuffle()
                //Updates General UI
                self.updateUI()
                
            } else {
                print("Value Error\n\n")
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    // This action happens when one of the keyboard buttons is tapped
    @IBAction func buttonTaped(_ sender:UIButton){
        let letter = sender.titleLabel?.text ?? "" //Gets the letter
        quiz.mLetterGuessed.append(letter)
        //Checks if the answer cotains either the uppercase or lowercase of the letter
        if !quiz.getQuestion(index: quiz.mCurrentQuestion).mAnswer.contains(letter.uppercased()) && !quiz.getQuestion(index: quiz.mCurrentQuestion).mAnswer.contains(letter.lowercased()){
            playSound(name: "doh", withExtension: "mp3") //incorrect sound
            quiz.mLives-=1
            if quiz.mLives == 0 {
                endGame()
                enableKeyboard(state: false)
            }
        }
        sender.isEnabled = false //Disables the button from being pressed again
        self.updateUI() //Updates the UI
        
    }
    @IBAction func NextQuestionTap(_ sender: Any) {
        // Removes all the letters guessed in preparation for the next question
        quiz.mLetterGuessed.removeAll()
        quiz.mScore += 1
        if(quiz.mCurrentQuestion >= quiz.mMaxQuestion - 1 || quiz.mCurrentQuestion >= numberOfQuestions - 1){
            //Enters end games state
            endGame()
            enableKeyboard(state: false)
        } else {
            quiz.mCurrentQuestion+=1
            enableKeyboard(state: true)
        }
    }
    func updateUI(){
        var answerDisplayed: String = ""
        var wordComplete: Bool = true
        //Updates Current lives
        LivesLabel.text = String(repeating: "❤️", count: quiz.mLives)
        //Updates Score
        ScoreLabel.text = String(quiz.mScore)
        //If the questions changes change the hint with animation
        if(HintLabel.text != quiz.getQuestion(index: quiz.mCurrentQuestion).mHint){
            //Fade Out
            UIView.animate(withDuration: 1.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.HintLabel.alpha = 0.0
            }, completion: {
                (finished: Bool) -> Void in
                // Changes the the text while not visible
                self.HintLabel.text = self.quiz.getQuestion(index: self.quiz.mCurrentQuestion).mHint
                // Fade in
                UIView.animate(withDuration: 1.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    self.HintLabel.alpha = 1.0
                }, completion: nil)
            })
        }
        //Generates the String for the current state of the answer
        for char in quiz.getQuestion(index: quiz.mCurrentQuestion).mAnswer{
            if quiz.mLetterGuessed.contains(String(char).lowercased()) || quiz.mLetterGuessed.contains(String(char).uppercased()){
                answerDisplayed += (String(char) + " ")
            } else if (char == " "){
                answerDisplayed += ("  ")
            }
            else{
                answerDisplayed += ("_ ")
                wordComplete = false
            }
        }
        AnswerLabel.text = answerDisplayed // Displays Answer
        if(wordComplete){
            playSound(name: "woohoo", withExtension: "mp3") //plays win sound
            NextQuestion.isEnabled=true // allows user to go to next question
            
            //Disables keyboard
            for button in AlphabetSoup{
                button.isEnabled = false
            }
        } else {
            NextQuestion.isEnabled=false
        }
    }
    //This is the end game state
    func endGame(){
        //Create alert so that the user can enter their name
        let alert = UIAlertController(title: "Enter Score", message: "Please Enter Your Name", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            do{
                let quizData: [String: String] = ["Name":alert.textFields![0].text! as String, "Score": String(self.quiz.mScore)]
                let jsonEncoder = JSONEncoder()
                let jsonData: Data = try jsonEncoder.encode(quizData)
                let json = try JSONSerialization.jsonObject(with: jsonData, options:[]) as! [String: String]
                self.databaseReference.child("score").child(self.quizName).childByAutoId().setValue(json)
            } catch {
                print(error.localizedDescription)
            }
        }))
        alert.addTextField { (TextField) in
            TextField.placeholder = "Enter Your Name"
        }
        self.present(alert, animated: true, completion: nil)
        enableKeyboard(state: false)
        
    }
    //Enable or Disable KeyBoard
    func enableKeyboard(state: Bool){
        for button in AlphabetSoup{
            button.isEnabled = state
            updateUI()
        }
    }
    //Plays a sound
    func playSound(name: String, withExtension: String){
        do{
            if let url = Bundle.main.url(forResource: name, withExtension: withExtension){
                player = try AVAudioPlayer(contentsOf: url)
                player.play()
            }
        } catch {
            print("Error\n")
        }
    }
}
