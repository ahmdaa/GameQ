//
//  GameProfileViewController.swift
//  GameQ
//
//  Created by Ahmed Abdalla on 11/25/20.
//

import UIKit
import AVFoundation
import CoreData

class GameProfileViewController: UICollectionViewController,
                                 UICollectionViewDelegateFlowLayout, GameDetailsDelegate {
    
    // Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var audioPlayer: AVAudioPlayer?
    var searchResult: SearchResult?
    var favoritedGame: Game?
    var gameDetails: GameDetails?

    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    var favorited = false;
    
    var isLoading = false
    var dataTask: URLSessionDataTask?
    
    struct CollectionView {
        struct CellIdentifiers {
            static let loadingCollection = "LoadingCollection"
            static let titleCell = "TitleCell"
            static let imageCell = "ImageCell"
            static let overviewCell = "OverviewCell"
            static let descriptionCell = "DescriptionCell"
            static let moreCell = "MoreCell"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // self.navigationController?.hidesBarsOnSwipe = true
        navigationController?.navigationBar.barStyle = .black
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getGameDetails(gameSlug: searchResult?.gameSlug ?? "")
        
        // Check if game is in favorites
        let request: NSFetchRequest<Game> = Game.fetchRequest()
        request.predicate = NSPredicate(format: "name = %@", searchResult!.gameName)
        
        do {
            let test = try context.fetch(request)
            if test.count == 1 {
                favoritedGame = test[0]
                favorited = true
                updateFavorite()
            }
        } catch {}
        
        // Loading Cell from Nib
        let cellNib = UINib(nibName: CollectionView.CellIdentifiers.loadingCollection, bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: CollectionView.CellIdentifiers.loadingCollection)
    }
    
    @IBAction func favoriteTapped(_ sender: Any) {
        
        if favorited == true {
            
            if let gameToRemove = favoritedGame {
                // Remove the game
                self.context.delete(gameToRemove)
                
                // Save the data
                do {
                    try self.context.save()
                } catch {}
                
                favorited = false
                updateFavorite()
            }
        } else {
            // Play a sound effect
            let pathToSound = Bundle.main.path(forResource: "swiftly", ofType: "mp3")!
            let url = URL(fileURLWithPath: pathToSound)
                        
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            } catch {
                print("Error: cannot play audio.")
            }
            
            // Create a new game object
            let newGame = Game(context: self.context)
            newGame.name = gameDetails?.name
            newGame.slug = gameDetails?.slug
            newGame.image = gameDetails?.background_image
            favoritedGame = newGame
            
            // Save the data
            do {
                try self.context.save()
            } catch {}
            
            favorited = true
            updateFavorite()
        }
    }
    
    func updateFavorite() {
        if favorited {
            favoriteButton.image = UIImage(systemName: "star.fill")
        } else {
            favoriteButton.image = UIImage(systemName: "star")
        }
    }
    
    // MARK:- Helper Methods
    
    func checkIfFavorited(name: String) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Game")
        request.predicate = NSPredicate(format: "name = %d", name)
        request.includesSubentities = false
        
        var entitiesCount = 0
        
        do {
            entitiesCount = try context.count(for: request)
        } catch { print("Error executing fetch") }
        
        return entitiesCount > 0
    }
    
    func getGameDetails(gameSlug: String) {
        let urlString = String(format: "https://rawg.io/api/games/%@", gameSlug)
        let url = URL(string: urlString)
        dataTask?.cancel()
        isLoading = true
        collectionView.reloadData()
        
        let gameURL = url!
        
        let headers = [
            "content-type": "application/json",
            "token": "478652684d7a433fbe62973b7fdfd7ba"
        ]
        
        var request = URLRequest(url: gameURL,
                              cachePolicy: .useProtocolCachePolicy,
                              timeoutInterval: 10.0)
        
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        dataTask = session.dataTask(with: request,
                                     completionHandler: { data, response, error in
            if let error = error as NSError?, error.code == -999 {
                return
            } else if let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 {
                if let data = data {
                    self.gameDetails = self.parse(data: data)
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.collectionView.reloadData()
                    }
                    return
                }
            } else {
                print("Failure! \(response!)")
            }
            DispatchQueue.main.async {
                self.isLoading = false
                self.collectionView.reloadData()
                self.showNetworkError()
            }
        })
        dataTask?.resume()
    }
    
    func parse(data: Data) -> GameDetails? {
      do {
        let decoder = JSONDecoder()
        let details = try decoder.decode(GameDetails.self, from:data)
        return details
      } catch {
        print("JSON Error: \(error)")
        return nil
      }
    }

    func showNetworkError() {
        let alert = makeAlert(title: "Network Error", message: "Please try again", actionTitle: "OK")
        present(alert, animated: true, completion: nil)
    }

    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isLoading {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionView.CellIdentifiers.loadingCollection, for: indexPath)
            
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            
            return cell
        } else if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionView.CellIdentifiers.titleCell, for: indexPath) as! TitleCollectionViewCell
            
            cell.gameTitle.text = searchResult?.gameName
            
            return cell
        } else if indexPath.item == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionView.CellIdentifiers.imageCell, for: indexPath) as! ImageCollectionViewCell
            
            if gameDetails?.background_image != nil {
                cell.setImage(for: gameDetails!)
            } else {
                cell.gameImage.image = UIImage(named: "placeholder")
            }
            
            return cell
        } else if indexPath.item == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionView.CellIdentifiers.overviewCell, for: indexPath) as! OverviewCollectionViewCell
            
            cell.ratingLabel.text = String(gameDetails?.rating ?? 0.0)
            cell.releasedLabel.text = gameDetails?.released ?? "Not Available"
            
            if let playtime = gameDetails?.playtime {
                if playtime == 1 {
                    let text = String(playtime) + " hour"
                    cell.playtimeLabel.text = text
                }
                else{
                    let text = String(playtime) + " hours"
                    cell.playtimeLabel.text = text
                }
            } else {
                let text = "Not Available"
                cell.playtimeLabel.text = text
            }
                        
            if let genres = gameDetails?.genres {
                var genreList = ""
                for genre in genres{
                    if genre.id == genres.last?.id {
                        genreList.append(genre.name)
                    }
                    else {
                        genreList.append(genre.name + ", ")
                    }
                }
                cell.genresLabel.text = genreList
            }
            
            if let developers = gameDetails?.developers {
                var devList = ""
                for developer in developers{
                    if developer.id == developers.last?.id  {
                        devList.append(developer.name)
                    }
                    else {
                        devList.append(developer.name + ", ")
                    }
                }
                cell.developerLabel.text = devList
            }
            
            if let score = gameDetails?.metacritic {
                cell.metascoreLabel.text = String(score)
                cell.metacriticImage.image = UIImage(named: "metacritic")
            } else {
                cell.metascoreLabel.text = ""
            }
            
            if let esrb = gameDetails?.esrb_rating {
                if esrb.id == 1 {
                    cell.esrbImage.image = UIImage(named: "esrb-e")
                } else if esrb.id == 2 {
                    cell.esrbImage.image = UIImage(named: "esrb-e-10")
                } else if esrb.id == 3 {
                    cell.esrbImage.image = UIImage(named: "esrb-t")
                } else if esrb.id == 4 {
                    cell.esrbImage.image = UIImage(named: "esrb-m")
                } else if esrb.id == 5 {
                    cell.esrbImage.image = UIImage(named: "esrb-a")
                }
            }
            
            cell.viewController = self
            cell.websiteURL = gameDetails?.website
            cell.metacriticURL = gameDetails?.metacritic_url
            
            return cell
        } else if indexPath.item == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionView.CellIdentifiers.descriptionCell, for: indexPath) as! DescriptionCollectionViewCell
            
            var text = gameDetails?.description ?? ""
            text = text.replacingOccurrences(of: "<br />", with: "\n")
            text = text.replacingOccurrences(of: "<br/>", with: "\n")
            text = text.replacingOccurrences(of: "<br>", with: "\n")
            text = text.replacingOccurrences(of: "<p>", with: "")
            text = text.replacingOccurrences(of: "</p>", with: "")
            text = text.replacingOccurrences(of: "</li>", with: "\n")
            text = text.replacingOccurrences(of: "<li>", with: "- ")
            text = text.replacingOccurrences(of: "<ul>", with: "\n")
            text = text.replacingOccurrences(of: "</ul>", with: "")
            text = text.replacingOccurrences(of: "<h3>", with: "\n")
            text = text.replacingOccurrences(of: "</h3>", with: ":")
            text = text.replacingOccurrences(of: "<strong>", with: "")
            text = text.replacingOccurrences(of: "</strong>", with: "")
            text = text.replacingOccurrences(of: "&amp;", with: "&")
            text = text.replacingOccurrences(of: "&#39;", with: "'")
            text = text.replacingOccurrences(of: "&quot;", with: "'")

            cell.descriptionTextView.text = text
            
            return cell
        } else if indexPath.item == 4 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionView.CellIdentifiers.moreCell, for: indexPath) as! MoreCollectionViewCell
            
            if let platforms = gameDetails?.platforms {
                var platformList = ""
                for plt in platforms{
                    if plt.platform.id == platforms.last?.platform.id  {
                        platformList.append(plt.platform.name)
                    }
                    else {
                        platformList.append(plt.platform.name + ", ")
                    }
                }
                cell.platformsLabel.text = platformList
            } else {
                cell.platformsLabel.text = "Not Available"
            }
            
            if let stores = gameDetails?.stores {
                var storeList = ""
                for store in stores{
                    if store.id == stores.last?.id {
                        storeList.append(store.store.name)
                        
                        if store.store.id == 1 {
                            cell.steamURL = store.url
                        }
                    }
                    else {
                        storeList.append(store.store.name + ", ")
                        
                        if store.store.id == 1 {
                            cell.steamURL = store.url
                        }
                    }
                }
                cell.storesLabel.text = storeList
            } else {
                cell.storesLabel.text = "Not Available"
            }
            
            if let redditTitle = gameDetails?.reddit_name {
                if(redditTitle != ""){
                    cell.redditTitleLabel.text = redditTitle
                } else {
                    cell.redditTitleLabel.text = "Not Available"
                }
            } else {
                cell.redditTitleLabel.text = "Not Available"
            }
            
            cell.viewController = self
            cell.redditURL = gameDetails?.reddit_url
            cell.gameName = gameDetails?.name ?? ""
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionView.CellIdentifiers.titleCell, for: indexPath) as! TitleCollectionViewCell
            
            return cell
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Title Cell
        if indexPath.item == 0 {
            return CGSize(width: view.frame.width, height: 75)
        }
        // Game Image Cell
        else if indexPath.item == 1 {
            return CGSize(width: view.frame.width, height: 250) // Width: 345 for round
        }
        // Overview Cell
        else if indexPath.item == 2 {
            return CGSize(width: view.frame.width, height: 180)
        }
        // Description Cell
        else if indexPath.item == 3 {
            return CGSize(width: view.frame.width, height: 250)
        }
        // Social Cell
        else if indexPath.item == 4 {
            return CGSize(width: view.frame.width, height: 180)
        }
        // Placeholder Cell
        else {
            return CGSize(width: view.frame.width, height: 100)
        }
    }
}

