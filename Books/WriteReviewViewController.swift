//
//  WriteReviewViewController.swift
//  SpeakingBooks
//
//  Created by 김인로 on 2017. 4. 8..
//  Copyright © 2017년 김인로. All rights reserved.
//

import UIKit

class WriteReviewViewController: UIViewController {

    
    @IBOutlet weak var cancelButtonItem: UIBarButtonItem!

    @IBAction func cancelCliked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var sendButtonItem: UIBarButtonItem!
    
    
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var reviewTextView: UITextView!
    
    
    @IBAction func sendButtonClicked(_ sender: Any)
    {
    var request = URLRequest(url: URL(string: "http://inlokim.com/wonli/review_write.php")!)
        request.httpMethod = "POST"
        
        let subject:String = titleTextView.text
        let content:String = reviewTextView.text
        
        let postString = "book_id=33334&subject=\(subject)&writer=작가님&score=5&content=\(content)"
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
        }
        task.resume()
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
