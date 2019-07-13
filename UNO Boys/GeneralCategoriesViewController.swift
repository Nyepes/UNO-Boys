//
//  GeneralCategoriesViewController.swift
//  UNO Boys
//
//  Created by Allan Zhang on 7/13/19.
//  Copyright © 2019 UNO Boys. All rights reserved.
//

import UIKit

class GeneralCategoriesViewController: UITableViewController {

    var genre = ["Sports", "History", "Science", "Music", "Politics"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Trivia!"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return genre.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = genre[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dvc = segue.destination as! GeneralQuestionsViewController
        let index = tableView.indexPathForSelectedRow?.row
        dvc.genre = genre[index!]
    }

}
