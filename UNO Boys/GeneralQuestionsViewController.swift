//
//  GeneralQuestionsViewController.swift
//  UNO Boys
//
//  Created by Allan Zhang on 7/13/19.
//  Copyright © 2019 UNO Boys. All rights reserved.
//

import UIKit

class GeneralQuestionsViewController: UITableViewController {

    var genre = ""
    var questionArray = [[String: String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Trivia Questions"
        var genreNum = 0
        if genre == "Sports" {
            genreNum = 21
        } else if genre == "History" {
            genreNum = 23
        } else if genre == "Science" {
            genreNum = 17
        } else if genre == "Music" {
            genreNum = 12
        } else if genre == "Politics" {
            genreNum = 24
        }
        let query = "https://opentdb.com/api.php?amount=30&category=\(genreNum)&difficulty=medium&type=multiple"
        DispatchQueue.global(qos: .userInitiated).async { //work on separate thread
            [unowned self] in
            if let url = URL(string: query) {
                if let data = try? Data(contentsOf: url) {
                    let json = try! JSON(data: data)
                    if json["response_code"] == 0 {
                        self.parse(json: json)
                        return
                    }
                }
            }
            self.loadError()
        }
    }
    
    func parse(json: JSON) {
        for i in 0...14 {
            let result = json["results"][i]
            let question = result["question"].stringValue.stringByDecodingHTMLEntities
            let correct = result["correct_answer"].stringValue.stringByDecodingHTMLEntities
            let wrong1 = result["incorrect_answers"][0].stringValue.stringByDecodingHTMLEntities
            let wrong2 = result["incorrect_answers"][1].stringValue.stringByDecodingHTMLEntities
            let wrong3 = result["incorrect_answers"][2].stringValue.stringByDecodingHTMLEntities
            let source = ["question": question, "correct": correct, "wrong1": wrong1, "wrong2": wrong2, "wrong3": wrong3]
            questionArray.append(source)
        }
        DispatchQueue.main.async { //comes back to main thread
            [unowned self] in
            self.tableView.reloadData()
        }
    }
    
    func loadError() {
        DispatchQueue.main.async { //work on separate thread
            [unowned self] in
            let alert = UIAlertController(title: "Loading Error",
                                          message: "There was a problem loading trivia",
                                          preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "Question \(indexPath.row + 1)"
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dvc = segue.destination as! ActualQuestionViewController
        let index = tableView.indexPathForSelectedRow?.row
        dvc.question = questionArray[index!]
    }
}

private let characterEntities : [ Substring : Character ] = [
    // XML predefined entities:
    "&quot;"    : "\"",
    "&amp;"     : "&",
    "&apos;"    : "'",
    "&lt;"      : "<",
    "&gt;"      : ">",
    
    // HTML character entity references:
    "&nbsp;"    : "\u{00a0}",
    // ...
    "&diams;"   : "♦",
]

extension String {
    
    /// Returns a new string made by replacing in the `String`
    /// all HTML character entity references with the corresponding
    /// character.
    var stringByDecodingHTMLEntities : String {
        
        // ===== Utility functions =====
        
        // Convert the number in the string to the corresponding
        // Unicode character, e.g.
        //    decodeNumeric("64", 10)   --> "@"
        //    decodeNumeric("20ac", 16) --> "€"
        func decodeNumeric(_ string : Substring, base : Int) -> Character? {
            guard let code = UInt32(string, radix: base),
                let uniScalar = UnicodeScalar(code) else { return nil }
            return Character(uniScalar)
        }
        
        // Decode the HTML character entity to the corresponding
        // Unicode character, return `nil` for invalid input.
        //     decode("&#64;")    --> "@"
        //     decode("&#x20ac;") --> "€"
        //     decode("&lt;")     --> "<"
        //     decode("&foo;")    --> nil
        func decode(_ entity : Substring) -> Character? {
            
            if entity.hasPrefix("&#x") || entity.hasPrefix("&#X") {
                return decodeNumeric(entity.dropFirst(3).dropLast(), base: 16)
            } else if entity.hasPrefix("&#") {
                return decodeNumeric(entity.dropFirst(2).dropLast(), base: 10)
            } else {
                return characterEntities[entity]
            }
        }
        
        // ===== Method starts here =====
        
        var result = ""
        var position = startIndex
        
        // Find the next '&' and copy the characters preceding it to `result`:
        while let ampRange = self[position...].range(of: "&") {
            result.append(contentsOf: self[position ..< ampRange.lowerBound])
            position = ampRange.lowerBound
            
            // Find the next ';' and copy everything from '&' to ';' into `entity`
            guard let semiRange = self[position...].range(of: ";") else {
                // No matching ';'.
                break
            }
            let entity = self[position ..< semiRange.upperBound]
            position = semiRange.upperBound
            
            if let decoded = decode(entity) {
                // Replace by decoded character:
                result.append(decoded)
            } else {
                // Invalid entity, copy verbatim:
                result.append(contentsOf: entity)
            }
        }
        // Copy remaining characters to `result`:
        result.append(contentsOf: self[position...])
        return result
    }
}
