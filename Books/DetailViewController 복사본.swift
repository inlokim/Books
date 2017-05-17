//
//  DetailViewController.swift
//  SpeakingBooks
//
//  Created by 김인로 on 2017. 3. 24..
//  Copyright © 2017년 김인로. All rights reserved.
//

import UIKit
import SDWebImage
import MZDownloadManager

class DetailViewController: UIViewController {
    
    //XML
    var strXMLData:String = ""
    var currentElement:String = ""
    var passData:Bool=false
    var passName:Bool=false
    var parser = XMLParser()
    
    
    //Book
    var book:Book = Book()
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var downloadingViewObj : DetailViewController?
    let myDownloadPath = MZUtility.baseFilePath
    
    //cookie session id
    var sessionId : String!
    

    lazy var downloadManager: MZDownloadManager = {
        [unowned self] in
        
        let sessionIdentifer: String = self.randomString(5)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var completion = appDelegate.backgroundSessionCompletionHandler
        
        let downloadmanager = MZDownloadManager(session: sessionIdentifer, delegate: self, completion: completion)
        return downloadmanager
        }()
    
    @IBOutlet weak var downloadButton: UIButton!
    
    var progressDownload = UIProgressView()
    
    //let alertView = UIAlertController(title: "Please wait", message: nil, preferredStyle: .alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authorLabel.text = book.author
        titleLabel.text = book.title
        
        print("myDownloadPath = \(myDownloadPath)")
        
        let bookCover:UIImageView = UIImageView()
        let coverUrl = "http://www.gutenberg.org/cache/epub/"+book.bookId+"/pg"+book.bookId+".cover.medium.jpg"
        
        bookCover.image = Util.burnText2ImageView(image:UIImage(named: "BookCover.png")!, title: book.title)
        
        imageView.sd_setImage(with: URL(string: coverUrl), placeholderImage: bookCover.image)
        imageView = Util.imageViewShadow(imageView: imageView)

        //print("Detail Book : "+book.bookId)
        
        setSesstionId(book.url)
        
       // self.setUpDownloadingViewController()
        
        //Review XML Set
        let url:String="http://www.inlokim.com/wonli/review.php"
        let urlToSend: NSURL = NSURL(string: url)!
        // Parse the XML 
        parser = XMLParser(contentsOf: urlToSend as URL)!
        parser.delegate = self
        
        let success:Bool = parser.parse()
        
        if success {
            print("parse success!")
            print(strXMLData)
        } else { print("parse failure!") }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func randomString(_ length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    
    func setUpDownloadingViewController() {
        let tabBarTabs : NSArray? = self.tabBarController?.viewControllers as NSArray?
        let mzDownloadingNav : UINavigationController = tabBarTabs?.object(at: 0) as! UINavigationController
        
        downloadingViewObj = mzDownloadingNav.viewControllers[0] as? DetailViewController
    }
    
    @IBAction func download(_ sender: Any)
    {
        print("downloadFile")
        
        let fileURL  : NSString = "http://www.gutenberg.org/ebooks/"+book.bookId+".epub.images?session_id="+self.sessionId as NSString
        
        print("url = "+(fileURL as String))
        
        
        let fileName = book.bookId+".epub"
        
        self.downloadManager.addDownloadTask(fileName as String, fileURL: fileURL.addingPercentEscapes(using: String.Encoding.utf8.rawValue)!, destinationPath: myDownloadPath)
        
        self.createAlert()
    }
    
   
    
    func createAlert()
    {
        //  Just create your alert as usual:
        let alertView = UIAlertController(title: "Please wait...", message: nil, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "", style: .default, handler: nil))
        
        //  Show it to your users
        present(alertView, animated: true, completion: {
            //  Add your progressbar after alert is shown (and measured)
            let margin:CGFloat = 8.0
            let rect = CGRect(x: margin, y: 72.0, width: alertView.view.frame.width - margin * 2.0, height: 2.0)
            self.progressDownload = UIProgressView(frame: rect)
            let downloadModel = MZDownloadModel()
            
            self.progressDownload.progress = downloadModel.progress
            self.progressDownload.tintColor = UIColor.blue
            alertView.view.addSubview(self.progressDownload)
        })
    }
    
    func refeshProgress(downloadModel:MZDownloadModel) {
        
        //print("refeshProgress")
        self.progressDownload.progress = downloadModel.progress
    }
    
    
    
    func safelyDismissAlertController() {
        self.dismiss(animated: true, completion: nil)
        
        self.parent?.tabBarController?.tabBar.items?.first?.badgeValue = "1"
    }
    
    
    func setSesstionId(_ link:String)
    {
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
                
                // print("name: \(cookie.name) value: \(cookie.value)")
                self.sessionId = cookie.value
            }
        })
        
        task.resume()
    }
    
}


//MARK - tableView

extension DetailViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        
        cell.textLabel?.text = self.items[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView!, didSelectRowAt indexPath: IndexPath) {
        println("You selected cell #\(indexPath.row)!")
    }
}

//MARk - XMLParser

extension DetailViewController: XMLParserDelegate {
    
    //MARK - XMLParser
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        currentElement=elementName;
        
        if(elementName=="subject" || elementName=="writer" || elementName=="score" || elementName=="content")
        {
            if(elementName=="subject") {
                passName=true;
            };
            passData=true;
        }
    }
    

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        currentElement="";
        if(elementName=="subject" || elementName=="writer" || elementName=="score" || elementName=="content")
    {
        if(elementName=="subject")
    {
        passName=false;
        }
        passData=false;
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String)
    {
        if(passName)
        { strXMLData=strXMLData+"\n\n"+string
        }
        if(passData)
        { print(string)
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error)
    {
        //NSLog("failure error: %@", parseError)
    }
}

//MARk - Download

extension DetailViewController: MZDownloadManagerDelegate {
    
    func downloadRequestStarted(_ downloadModel: MZDownloadModel, index: Int) {
       //let indexPath = IndexPath.init(row: index, section: 0)
        //tableView.insertRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        
        print("downloadRequestStarted")
        print("downloadManager.downloadingArray.count : \(downloadManager.downloadingArray.count)")
    }
    
    func downloadRequestDidPopulatedInterruptedTasks(_ downloadModels: [MZDownloadModel]) {
        //tableView.reloadData()
        print("downloadRequestDidPopulatedInterruptedTasks")
    }
    
    func downloadRequestDidUpdateProgress(_ downloadModel: MZDownloadModel, index: Int) {
       // print("downloadRequestDidUpdateProgress")
        
        self.refeshProgress(downloadModel: downloadModel)
    }
    
    func downloadRequestDidPaused(_ downloadModel: MZDownloadModel, index: Int) {
        //self.refreshCellForIndex(downloadModel, index: index)
        print("downloadRequestDidPaused")
    }
    
    func downloadRequestDidResumed(_ downloadModel: MZDownloadModel, index: Int) {
        
        //self.refreshCellForIndex(downloadModel, index: index)
        
         print("downloadRequestDidResumed")
    }
    
    func downloadRequestCanceled(_ downloadModel: MZDownloadModel, index: Int) {
        
        //self.safelyDismissAlertController()
        
        //let indexPath = IndexPath.init(row: index, section: 0)
        //tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
        
        print("downloadRequestCanceled")
    }
    
    func downloadRequestFinished(_ downloadModel: MZDownloadModel, index: Int) {
        
        self.safelyDismissAlertController()
        
        downloadManager.presentNotificationForDownload("Ok", notifBody: "Download did completed")
        //print("downloadManager.downloadingArray.count : \(downloadManager.downloadingArray.count)")
        
        //    let indexPath = IndexPath.init(row: index, section: 0)
        //    tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
        
        let docDirectoryPath : NSString = (MZUtility.baseFilePath as NSString).appendingPathComponent(downloadModel.fileName) as NSString
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: MZUtility.DownloadCompletedNotif as String), object: docDirectoryPath)
    }
    
    func downloadRequestDidFailedWithError(_ error: NSError, downloadModel: MZDownloadModel, index: Int) {
//        self.safelyDismissAlertController()
//        self.refreshCellForIndex(downloadModel, index: index)
        
        debugPrint("Error while downloading file: \(downloadModel.fileName)  Error: \(error)")
    }
    
    //Oppotunity to handle destination does not exists error
    //This delegate will be called on the session queue so handle it appropriately
    func downloadRequestDestinationDoestNotExists(_ downloadModel: MZDownloadModel, index: Int, location: URL) {
        let myDownloadPath = MZUtility.baseFilePath
        if !FileManager.default.fileExists(atPath: myDownloadPath) {
            try! FileManager.default.createDirectory(atPath: myDownloadPath, withIntermediateDirectories: true, attributes: nil)
        }
        let fileName = MZUtility.getUniqueFileNameWithPath((myDownloadPath as NSString).appendingPathComponent(downloadModel.fileName as String) as NSString)
        let path =  myDownloadPath + "/" + (fileName as String)
        try! FileManager.default.moveItem(at: location, to: URL(fileURLWithPath: path))
        debugPrint("Default folder path: \(myDownloadPath)")
    }
}
