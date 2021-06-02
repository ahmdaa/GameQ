//
//  FavoritesViewController.swift
//  GameQ
//
//  Created by Ahmed Abdalla on 11/25/20.
//

import UIKit
import CoreData

class FavoritesViewController: UITableViewController {
    @IBOutlet weak var titleOnlyButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
    
    // Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Data for the table
    var games:[Game]?
    
    // User defaults
    let defaults = UserDefaults.standard
    var sort = false;
    var titleOnly = false;
    
    override func viewWillAppear(_ animated: Bool) {
        sort = defaults.bool(forKey: "sort")
        titleOnly = defaults.bool(forKey: "titleOnly")
        
        updateTitleOnlyButton()
        updateSortButton()
        
        // Get items from Core Data
        fetchGames()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func fetchGames() {
        
        // Fetch game data from Core Data to display in the tableview
        do {
            if sort == true {
                // Get all games sorted in ascending order
                let request = Game.fetchRequest() as NSFetchRequest<Game>
                
                let sorting = NSSortDescriptor(key: "name", ascending: true)
                request.sortDescriptors = [sorting]
                
                self.games = try context.fetch(request)
                
            } else {
                // Get all games
                self.games = try context.fetch(Game.fetchRequest())
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {}
    }

    @IBAction func sortButtonTapped(_ sender: Any) {
        if sort == true {
            defaults.setValue(false, forKey: "sort")
            sort = false;
            updateSortButton()
            fetchGames()
        } else {
            defaults.setValue(true, forKey: "sort")
            sort = true;
            updateSortButton()
            fetchGames()
        }
    }
    
    @IBAction func titleOnlyButtonTapped(_ sender: Any) {
        // rectangle.split.1x2
        // rectangle.split.1x2.fill
        if titleOnly == true {
            defaults.setValue(false, forKey: "titleOnly")
            titleOnly = false;
            updateTitleOnlyButton()
            tableView.reloadData()
        } else {
            defaults.setValue(true, forKey: "titleOnly")
            titleOnly = true;
            updateTitleOnlyButton()
            tableView.reloadData()
        }
    }
    
    func updateTitleOnlyButton() {
        if titleOnly {
            let image = UIImage(systemName: "rectangle.split.1x2.fill")
            titleOnlyButton.setImage(image, for: .normal)
        } else {
            let image = UIImage(systemName: "rectangle.split.1x2")
            titleOnlyButton.setImage(image, for: .normal)
        }
    }
    
    func updateSortButton() {
        if sort {
            let image = UIImage(systemName: "arrow.up.circle.fill")
            sortButton.setImage(image, for: .normal)
        } else {
            let image = UIImage(systemName: "arrow.up.circle")
            sortButton.setImage(image, for: .normal)
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Return the number of games
        return self.games?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if titleOnly == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GameTitleCell", for: indexPath) as! GameTableViewCell
            
            // Get game from array and set the label
            let game = self.games![indexPath.row]
            
            cell.nameLabel.text = game.name

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as! GameTableViewCell
            
            // Get game from array and set the label
            let game = self.games![indexPath.row]
            
            cell.nameLabel.text = game.name
            cell.setImage(for: game)

            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowFavoriteGameProfile", sender: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Create swipe action
        let action = UIContextualAction(style: .destructive, title: "Remove") { (action, view, completionHandler) in
            
            // Which game to remove
            let gameToRemove = self.games![indexPath.row]
            
            // Remove the game
            self.context.delete(gameToRemove)
            
            // Save the data
            do {
                try self.context.save()
            } catch {}
            
            // Re-fetch the data
            self.fetchGames()
        }
        
        // Return swipe actions
        return UISwipeActionsConfiguration(actions: [action])
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        if segue.identifier == "ShowFavoriteGameProfile" {
            let gameProfileViewController = segue.destination as! GameProfileViewController
            let indexPath = sender as! IndexPath
            let searchResult = SearchResult()
            searchResult.gameName = (games?[indexPath.row].name)!
            searchResult.gameSlug = (games?[indexPath.row].slug)!
            gameProfileViewController.favoritedGame = games?[indexPath.row]
            gameProfileViewController.searchResult = searchResult
        }
    }

}
