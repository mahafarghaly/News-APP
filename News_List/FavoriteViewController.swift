//
//  FavoriteViewController.swift
//  News_List
//
//  Created by maha on 4/30/24.
//  Copyright © 2024 maha. All rights reserved.
//

import UIKit
import CoreData
import SDWebImage
class FavoriteViewController: UIViewController ,UITableViewDataSource , UITableViewDelegate {

    @IBOutlet weak var favTableView: UITableView!
     var newsItems: [News] = []
    override func viewDidLoad() {
       
    
        super.viewDidLoad()
        favTableView.dataSource = self
        favTableView.delegate = self
               favTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

  override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
     fetchNewsItems()
  }


    func fetchNewsItems() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NewsTable")
         newsItems.removeAll()
        do {
            let data = try context.fetch(fetchRequest)
            //newsItems = fetchedResults
            //as! [News]
          
            for item in data{
          let news = News()
                       news.title = item.value(forKey: "title") as? String
                       news.author = item.value(forKey: "author") as? String
                       news.desription = item.value(forKey: "desription") as? String
                       news.imageUrl = item.value(forKey: "image") as? String
//                       news.publishedAt = item.value(forKey: "publishedAt") as? String
                       newsItems.append(news)
                
            }
            
            favTableView.reloadData()
        } catch {
            print("Failed to fetch data: \(error)")
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let newsItem = newsItems[indexPath.row]
        cell.textLabel?.text = newsItem.title
        if let imageUrlString = newsItem.imageUrl, let imageUrl = URL(string: imageUrlString) {
            cell.imageView?.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "boy.jpeg"))
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        if let detailViewController = storyboard?.instantiateViewController(withIdentifier: "VC") as? ViewController {
     
            detailViewController.newsItem = newsItems[indexPath.row]
         
            navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
         
            newsItems.remove(at: indexPath.row)

      
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NewsTable")
            do {
                let data = try context.fetch(fetchRequest)
                context.delete(data[indexPath.row])
                try context.save()
            } catch {
                print("Failed to delete item: \(error)")
            }

            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

  
}

