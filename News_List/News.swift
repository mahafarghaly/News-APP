//
//  News.swift
//  News_List
//
//  Created by maha on 4/29/24.
//  Copyright © 2024 maha. All rights reserved.
//

import Foundation
class News:Codable{
    var author: String?
    var title: String?
     var desription: String?
     var imageUrl: String?
         var publishedAt: String?

    
}
func getDataFromApi(handler: @escaping ([News]) -> Void){
    let url = URL(string: "https://raw.githubusercontent.com/DevTides/NewsApi/master/news.json")
    guard let urll = url else{
        return
    }
    let request = URLRequest(url: urll)
    let session = URLSession(configuration: .default)
    let task = session.dataTask(with: request){ data,response,error in
        guard let data = data else{
            print("no data")
            return
        }
        do{
            let results = try JSONDecoder().decode([News].self, from: data)
            print(results[0].title ?? "no title")
            handler(results)
            
        }catch{
            print(error.localizedDescription)
        }
    }
    task.resume()

}
