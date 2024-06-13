//
//  ContentView.swift
//  WordScramble
//
//  Created by Alfredo Perry on 6/10/24.
//

import SwiftUI


struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var showRules = false

    
    var body: some View {
        NavigationStack{
            List{
                Section{
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section{
                    ForEach(usedWords, id: \.self) { word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
                
                Section{
                    Text("Score: \(score)")
                }
                
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError){
                Button("OK"){ }
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading){
                    Button(action: {showRules = true},
                           label: {
                        Image(systemName: "info.circle")
                            .font(.title2)
                    })
                }
                ToolbarItem{
                    Button("Restart", action: startGame)
                }
            }
            .sheet(isPresented: $showRules){
                Rules(showRules: $showRules)
            }
        }
        
    }
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else{
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isRootWord(word: answer) else{
            wordError(title: "Word is the rootword", message: "You can't use your answer because it is the rootword!")
            return
        }
                
        withAnimation{
            usedWords.insert(answer, at: 0)
        }
        addScore(word: answer)
        newWord = ""
    }
    
    func startGame(){
        score = 0
        usedWords = []
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isRootWord(word:String) -> Bool{
        if(word == rootWord){
            return false
        }
        return true
    }
    
    func isOriginal(word:String) -> Bool{
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool{
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            } else{
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
    
    func wordError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func addScore(word: String){
        if((usedWords.count + 1) % 5 == 0){
            score += 5
        }
        score += word.count
    }
    
    struct Rules: View{
        @Binding var showRules: Bool
        
        var body: some View{

            VStack{
                Group{
                    Text("Rules:")
                    Text("You must make new words using the letters of the root word at the top.")
                    Text("Every five words you get an extra 5 points.")
                    Text("If you can make a word using all the letters you get two extra points.")
                }
                .frame(alignment: .center)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.secondary)
                    .shadow(radius:5)
            )
            
            Button(action: {showRules = false}, label: {
                Image(systemName: "xmark")
            })
            .padding()
        }
    }
    
}

#Preview {
    ContentView()
}
