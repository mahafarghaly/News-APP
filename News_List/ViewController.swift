//
//  ViewController.swift
//  News_List
//
//  Created by maha on 4/29/24.
//  Copyright © 2024 maha. All rights reserved.
//

import UIKit
import CoreData
class ViewController: UIViewController {
    var newsItem: News?

    @IBOutlet weak var favImage: UIButton!
    @IBOutlet weak var newImage: UIImageView!
    @IBOutlet weak var authorLB: UILabel!
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var decTextView: UITextView!
    var isInFavorites: Bool = false

    override func viewDidLoad() {
          //fetchAndPrintData()
        super.viewDidLoad()
        
      if let newsItem = newsItem {
                 titleLB.text = newsItem.title ?? "No title"
                 authorLB.text = newsItem.author ?? "No author"
                 decTextView.text = newsItem.desription ?? "No description"
                 
                 if let imageUrlString = newsItem.imageUrl, let imageUrl = URL(string: imageUrlString) {
                     let placeholderImage = UIImage(named: "boy.jpeg")
                     newImage.sd_setImage(with: imageUrl, placeholderImage: placeholderImage, completed: nil)
                 } else {
                     newImage.image = UIImage(named: "boy.jpeg")
                 }
             }
        isInFavorites = isNewsSavedToCoreData(news: newsItem!)
        udateFvoriteButton()
     
         }
    
    @IBAction func favBtn(_ sender: UIButton) {
        isInFavorites.toggle()
         udateFvoriteButton()
        if isInFavorites {
                   favImage.setImage(UIImage(systemName: "heart.fill"), for: .normal)

            saveNewsToCoreData()
        }else{
            favImage.setImage(UIImage(systemName: "heart"), for: .normal)
            removeNewsFromCoreData()
        }
            
        
       
           
        
        
    }
    func saveNewsToCoreData() {
               let appDelegate = UIApplication.shared.delegate as! AppDelegate
                      let context =
                          appDelegate.persistentContainer.viewContext
                      let entity = NSEntityDescription.entity(forEntityName: "NewsTable",
                                                              in: context)
                      let news = NSManagedObject(entity: entity!, insertInto: context)
                      news.setValue(titleLB.text, forKey:"title")
                        news.setValue(authorLB.text, forKey:"author")
                        news.setValue(decTextView.text, forKey:"desription")
                      news.setValue(newsItem?.imageUrl, forKey:"image")
   
                      do{
                          try context.save()
                          print("\nSaved\n")
                        print( news.setValue(newsItem?.imageUrl, forKey:"image"))
                      }catch let error{
                          print(error.localizedDescription)
   
                                  }
       }

    func isNewsSavedToCoreData(news: News) -> Bool{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NewsTable")
        fetchRequest.predicate = NSPredicate(format: "title == %@", newsItem?.title ?? "" )
        do {
            let result = try context.fetch(fetchRequest)
            print("found news")
            return !result.isEmpty
        }catch{
            print("error fatching news:\(error.localizedDescription)")
            return false
        }
    }
    func removeNewsFromCoreData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NewsTable")
        fetchRequest.predicate = NSPredicate(format: "title == %@", newsItem?.title ?? "")
        
        do {
            let data = try context.fetch(fetchRequest)
            for item in data {
                context.delete(item)
            }
            try context.save()
            print("\nDeleted\n")
        } catch let error {
            print("Failed to delete item: \(error.localizedDescription)")
        }
    }
    func udateFvoriteButton()
    {
        if isInFavorites {
            favImage.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }else{
               favImage.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
}
  
