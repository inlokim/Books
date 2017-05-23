//
//  Util.swift
//  SpeakingBooks
//
//  Created by 김인로 on 2017. 4. 6..
//  Copyright © 2017년 김인로. All rights reserved.
//

import UIKit

class Util {

    
    public static var sessionId : String!
    
    open static func setSessionId()
    {
        let link = "http://m.gutenberg.org/ebooks/search.mobile/?sort_order=release_date"
        let url:URL = URL(string: link)!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            
            // Save the incoming HTTP Response
            
            let httpResponse: HTTPURLResponse = response as! HTTPURLResponse
            
            // Since the incoming cookies will be stored in one of the header fields in the HTTP Response, parse through the header fields to find the cookie field and save the data
            
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: httpResponse.allHeaderFields as! [String : String], for: (response?.url!)!)
            
            print("Cookies.count: \(cookies.count)")
            
            // HTTPCookieStorage.shared.setCookies(cookies as [AnyObject] as! [HTTPCookie], for: response?.url!, mainDocumentURL: nil)
            
            for cookie in cookies {
                
                print("name: \(cookie.name) value: \(cookie.value)")
                Util.sessionId = cookie.value
            }
        })
        
        task.resume()
    }
    
    
    open static let homeDir : String = {
        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }()
    
    
    public static func imageViewShadow(imageView:UIImageView) -> UIImageView
    {
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.6
        imageView.layer.shadowRadius = 2.0
        imageView.layer.shadowOffset = CGSize.init(width: 3.0, height: 0.0)
        
        return imageView
    }
    
    
    public static func burnText2ImageView(image:UIImage, title:String) -> UIImage
    {
        let newImageView = UIImageView(image : image)
        let labelView = UILabel(frame: CGRect(x:25 , y:10 , width: image.size.width*0.7, height: image.size.height*0.7)
)
        var fontSize = 30.0;
        
        if (title.characters.count > 100) {fontSize = 18.0}
        if (title.characters.count > 150) {fontSize = 16.0}
        if (title.characters.count > 200) {fontSize = 14.0}
        
        labelView.font = UIFont(name:"Times New Roman", size:CGFloat(fontSize))
        labelView.textAlignment = .center
        labelView.lineBreakMode = .byWordWrapping
        labelView.numberOfLines = 5
        labelView.textColor = UIColor(colorLiteralRed: 0.8 , green: 0.8, blue: 0.7, alpha: 1)
        
        labelView.text = title
        
        newImageView.addSubview(labelView)
        UIGraphicsBeginImageContext(newImageView.frame.size)
        newImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let watermarkedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return watermarkedImage
    }
    
    
}
