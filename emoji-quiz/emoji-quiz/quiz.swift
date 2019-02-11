//
//  quiz.swift
//  emoji-quiz
//
//  Created by Eaton, Kevin on 2/10/19.
//  Copyright © 2019 Eaton, Kevin. All rights reserved.
//

import Foundation
//Extends to Codable to be convert to JSON later
struct Question: Codable {
    var mAnswer: String
    var mHint: String
}
//Extends to Codable to be convert to JSON later
struct Quiz: Codable{
    var mUsername: String=""
    var mLives: Int=3
    var mScore: Int=0
    var mQuestions: [Question]=[]
    //Question Methods
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
    //Username Methods
    mutating func setUsername(username: String){
        self.mUsername = username
    }
    func getUsername()->String{
        return self.mUsername
    }
    //Live Methods
    mutating func setLives(lives: Int)->Void{
        mLives = lives
    }
    func getLives()->Int{
        return self.mLives
    }
    //Score Methods
    mutating func setScore(score: Int){
        self.mScore = score
    }
    func getScore()->Int{
        return self.mScore
    }
    //Reset Quiz Method
    mutating func reset(){
        mUsername = ""
        mLives = 3
        mScore = 0
        clearQuestions()
    }
}
