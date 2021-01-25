//
//  ContentView.swift
//  WordScramble
//
//  Created by Zaid Raza on 09/09/2020.
//  Copyright © 2020 Zaid Raza. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State private var showingError = false
    
    @State private var usedWords = [String]()
    
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    
    @State private var score = 0
    @State private var offsetToSet = 160
    
    var body: some View {
        
        NavigationView{
            VStack{
                TextField("Enter your word " ,text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                
                List(usedWords , id: \.self){ word in
                    HStack{
                        Image(systemName: "\(word.count).circle")
                        Text(word)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibility(label: Text("\(word), \(word.count) letters"))
                    .offset(x: CGFloat(self.offsetToSet))
                }
                Text("Score: \(score)").font(.headline)
            }
            .navigationBarTitle(rootWord)
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .navigationBarItems(leading: Button(action: startGame){
                Text("Start")
            })
        }
    }
    
    func addNewWord(){
        
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't a real word.")
            return
        }
        
        guard !isThreeLetter(word: answer) else {
            wordError(title: "No 3 letter word", message: "Use more alphabets.")
            return
        }
        
        guard !isSame(word: answer) else {
            wordError(title: "Same word", message: "You can't use that, can you?")
            return
        }
        
        score += answer.count
        usedWords.insert(answer, at: 0)
        withAnimation{
            self.offsetToSet = 0
        }
        newWord = ""
    }
    
    func startGame(){
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: ".txt"){
            
            if let startWords = try? String(contentsOf: startWordsURL){
                
                let allWords = startWords.components(separatedBy: "\n")
                
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool{
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool{
        
        var tempWord = rootWord
        
        for alphabet in word {
            if let pos = tempWord.firstIndex(of: alphabet){
                tempWord.remove(at: pos)
            }
            else{
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool{
        let checker = UITextChecker()
        
        let range = NSRange(location: 0, length: word.utf16.count)
        
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func isThreeLetter(word: String) -> Bool{
        word.count<4
    }
    
    func isSame(word: String) -> Bool {
        word == rootWord
    }
    
    func wordError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
