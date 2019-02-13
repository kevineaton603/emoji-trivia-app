//
//  ViewController.swift
//  emoji-quiz
//
//  Created by Eaton, Kevin on 2/10/19.
//  Copyright © 2019 Eaton, Kevin. All rights reserved.
//

import UIKit

class QuizController: UIViewController {
    @IBOutlet weak var QuizSelectorSegment: UISegmentedControl!
    @IBOutlet weak var QuizNameLabel: UILabel!
    @IBOutlet weak var LivesLabel: UILabel!
    @IBOutlet weak var QuestionLabel: UILabel!
    @IBOutlet weak var LivesStepper: UIStepper!
    @IBOutlet weak var QuestionStepper: UIStepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is QuizGameController{
            let vc = segue.destination as! QuizGameController
            let name = QuizNameLabel.text?.lowercased() ?? "movies"
            vc.quizName = name
            vc.numberOfLives = Int(LivesStepper.value)
            vc.numberOfQuestions = Int(QuestionStepper.value)
        }
    }
    
    @IBAction func LivesStep(_ sender: UIStepper) {
        LivesLabel.text=String(Int(sender.value))
    }
    @IBAction func QuestionStep(_ sender: UIStepper) {
        QuestionLabel.text=String(Int(sender.value))
    }
}
