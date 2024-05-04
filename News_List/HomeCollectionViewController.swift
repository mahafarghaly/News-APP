//
//  HomeCollectionViewController.swift
//  News_List
//
//  Created by maha on 4/29/24.
//  Copyright © 2024 maha. All rights reserved.
//

import UIKit
import SDWebImage
import CoreData
import Reachability


class HomeCollectionViewController: UICollectionViewController,UICollectionViewDelegateFlowLayout {
var idinticator: UIActivityIndicatorView?
var news: [News] = []
let reachability = try! Reachability()

    override func viewDidLoad() {
        super.viewDidLoad()
        idinticator = UIActivityIndicatorView(style: .large)
        idinticator!.center = view.center
        idinticator!.startAnimating()
        view.addSubview(idinticator!)

//        getDataFromApi{[weak self] news in
//            DispatchQueue.main.async {
//              self?.idinticator?.stopAnimating()
//                self?.news = news
//                       self?.collectionView.reloadData()
//
//
//            }
//
//        }
        
       reachability.whenReachable = { [weak self] _ in
        getDataFromApi { news in
                      DispatchQueue.main.async {
                           print("connected \n")
                          self?.idinticator?.stopAnimating()
                          self?.news = news
                          self?.collectionView.reloadData()
                          self?.saveNewsToCoreData()
                      }
                  }
              }
              reachability.whenUnreachable = { [weak self] _ in
                  DispatchQueue.main.async {
                    print("disconected \n")
                      self?.idinticator?.stopAnimating()
                      self?.news = self?.getFromCoreData() ?? []
                      self?.collectionView.reloadData()
                  }
              }

              do {
                  try reachability.startNotifier()
              } catch {
                  print("Unable to start notifier")
              }
           
            }


    override func numberOfSections(in collectionView: UICollectionView) -> Int {
            // #warning Incomplete implementation, return the number of sections
            return 1
        }
     

        override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            // #warning Incomplete implementation, return the number of items
            return  news.count
            
        }

        override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)as!CollectionViewCell
    //
    //        cell.myImage.image=UIImage(named: "boy.jpeg")
    //        cell.nameLable.text="beaf"
//            let imageUrl = URL(string: imageUrls[indexPath.item])
//            let placeholderImage = UIImage(named: "boy.jpeg")
//            cell.myImage.sd_setImage(with: imageUrl, placeholderImage: placeholderImage, completed: nil)
       let newsItem = news[indexPath.item]

       cell.titleLB.text = newsItem.title ?? "No title"
            if let imageUrlString = newsItem.imageUrl,
               let imageUrl = URL(string: imageUrlString) {
                let placeholderImage = UIImage(named: "boy.jpeg")
                cell.myImage.sd_setImage(with: imageUrl, placeholderImage: placeholderImage, completed: nil)
            } else {
                cell.myImage.image = UIImage(named: "boy.jpeg")
            }
            
            return cell
        }
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
               let width = (view.frame.width / 2) - 10
             let height = (view.frame.width) / 2 - 10
               return CGSize(width: width, height: height)
           }
    
      override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      let selectedNews = news[indexPath.item]
      if let viewController = storyboard?.instantiateViewController(withIdentifier: "VC") as? ViewController {
          viewController.newsItem = selectedNews
          navigationController?.pushViewController(viewController, animated: true)
      }
    }
     func saveNewsToCoreData() {
         guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
             print("Error getting app delegate")
             return
         }

         let context = appDelegate.persistentContainer.viewContext

         for newsItem in news {
             let entity = NSEntityDescription.entity(forEntityName: "AllNews", in: context)!
             let newsObj = NSManagedObject(entity: entity, insertInto: context)
             newsObj.setValue(newsItem.title, forKey: "title")
             newsObj.setValue(newsItem.author, forKey: "author")
             newsObj.setValue(newsItem.desription, forKey: "des")
             newsObj.setValue(newsItem.imageUrl, forKey: "image")

             do {
                 try context.save()
                 print("Saved news to Core Data")
             } catch let error as NSError {
                 print("Could not save news. \(error), \(error.userInfo)")
             }
         }
     }
    func getFromCoreData() -> [News] {
        
        var newsItems: [News] = []

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
           let context = appDelegate.persistentContainer.viewContext
           let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AllNews")
          newsItems.removeAll()
        do {
            let result = try context.fetch(fetchRequest)
            for data in result  {
                let newsItem = News()
                newsItem.title = data.value(forKey: "title") as? String
               newsItem.author = data.value(forKey: "author") as? String
                newsItem.desription = data.value(forKey: "des") as? String
                newsItem.imageUrl = data.value(forKey: "image") as? String
                newsItems.append(newsItem)
                 print("Could  fetch data ")
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        return newsItems
    }

}
