//
//  quiz.swift
//  emoji-quiz
//
//  Created by Eaton, Kevin on 2/10/19.
//  Copyright © 2019 Eaton, Kevin. All rights reserved.
//

import Foundation
struct Question {
    var mAnswer: String
    var mHint: String
}
struct Quiz{
    var mUsername: String
    var mLives: Int
    var mScore: Int
    var mQuestions: [Question]
    
    mutating func addQuestion(q: Question)->Void{
        self.mQuestions.append(q)
    }
    mutating func addQuestions(q: [Question])->Void{
        self.mQuestions.append(contentsOf: q)
    }
    mutating func clearQuestions()->Void{
        self.mQuestions.removeAll()
    }
    func getQuestion(index: Int)->Question{
        return self.mQuestions[index]
    }
    
    mutating func setUsername(username: String){
        self.mUsername = username
    }
    func getUsername()->String{
        return self.mUsername
    }
    mutating func setLives(lives: Int)->Void{
        mLives = lives
    }
    func getLives()->Int{
        return self.mLives
    }
    mutating func setScore(score: Int){
        self.mScore = score
    }
    func getScore()->Int{
        return self.mScore
    }
    mutating func reset(){
        mUsername = ""
        mLives = 3
        mScore = 0
        clearQuestions()
    }
}
