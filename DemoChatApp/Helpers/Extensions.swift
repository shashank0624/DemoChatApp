//
//  Extensions.swift
//  DemoChatApp
//
//  Created by Kirti Ahlawat on 21/04/18.
//  Copyright © 2018 Shashank Panwar. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView{
    
    func loadImageUsingCacheWithUrlString(urlString: String){
        
        self.image = UIImage(named: "gameofthrones_splash")
        //Check Cache for image first
        if let cachedImage = imageCache.object(forKey: (urlString as AnyObject)) as? UIImage{
            self.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        if let url = NSURL(string: urlString){
            print("URL: \(url)")
            URLSession.shared.dataTask(with: url as URL) { (data, URLRequest, error) in
                if let err = error{
                    print("error: \(err)")
                    return
                }
                DispatchQueue.main.async {
                    if let downloadedImage = UIImage(data: data!){
                        imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                        self.image = downloadedImage                    }
                    
                }
                }.resume()
        }
        
    }
}






