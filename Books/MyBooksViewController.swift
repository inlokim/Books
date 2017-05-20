import UIKit
import FolioReaderKit
import MZDownloadManager
import RealmSwift

class MyBooksViewController: UITableViewController {
    
    var downloadedFilesArray : [String] = []
    var selectedIndexPath    : IndexPath?
    var fileManger           : FileManager = FileManager.default
   // var myDownloadPath = MZUtility.baseFilePath+"/ePub"

    var myDownloadPath = MZUtility.baseFilePath+"/ePub"

    var categoryName = "All"
    
    @IBOutlet weak var categoryButton: UIButton!
    
    @IBAction func categoryAction(_ sender: Any) {
        
    }
   
    let config = FolioReaderConfig()
    
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
       print("ePub Dir :\(MZUtility.baseFilePath+"/ePub")")
        
       // categoryButton.titleLabel?.text = categoryName+" ▼"
        
        
        do {
            let contentOfDir: [String] = try FileManager.default.contentsOfDirectory(atPath: myDownloadPath as String)

            downloadedFilesArray = contentOfDir.filter{ $0.contains(".epub") }
            
        } catch let error as NSError {
            print("Error while getting directory content \(error)")
        }
        
        NotificationCenter.default.addObserver(self, selector: NSSelectorFromString("downloadFinishedNotification:"), name: NSNotification.Name(rawValue: MZUtility.DownloadCompletedNotif as String), object: nil)
        
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MZDownloadedViewController.downloadFinishedNotification(_:)), name: DownloadCompletedNotif as String, object: nil)
        
        readerConfig()
        
        
        
        //reveal view
        
        if revealViewController() != nil {
            
            print("revealViewController")
            //            revealViewController().rearViewRevealWidth = 62
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
           
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

    }
    
    
    func btn1Action() {
        
    }
    
    
    func readerConfig()
    {
        print("readerConfig")
        
        config.shouldHideNavigationOnTap = true
        config.scrollDirection = .horizontal
        
        // See more at FolioReaderConfig.swift
        //        config.canChangeScrollDirection = false
        //        config.enableTTS = false
        //        config.allowSharing = false
        config.tintColor = UIColor.red
        //        config.toolBarTintColor = UIColor.redColor()
        //        config.toolBarBackgroundColor = UIColor.purpleColor()
        //        config.menuTextColor = UIColor.brownColor()
        //        config.menuBackgroundColor = UIColor.lightGrayColor()
        //        config.hidePageIndicator = true
        //    config.realmConfiguration = Realm.Configuration(fileURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("highlights.realm"))
        
  //      print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("highlights.realm"))
        
        
       // config.realmConfiguration = Realm.Configuration(fileURL: URL(fileURLWithPath: myDownloadPath).appendingPathComponent("highlights.realm"))

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - NSNotification Methods -
    
    func downloadFinishedNotification(_ notification : Notification)
    {
        print("downloadFinishedNotification")
        
        let fileName : NSString = notification.object as! NSString
        downloadedFilesArray.append(fileName.lastPathComponent)
        tableView.reloadData()
        //tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.fade)

    }
}

//MARK: UITableViewDataSource Handler Extension

extension MyBooksViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return downloadedFilesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier : NSString = "DownloadedFileCell"
        let cell : BookTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier as String, for: indexPath) as! BookTableViewCell
        
        let bookPath = myDownloadPath + "/" + downloadedFilesArray[(indexPath as NSIndexPath).row]
        
        print("bookPath:\(bookPath)")
        
        let (title, author, cover) = getBookInfo(bookPath)
        
        cell.titleLabel.text = title
        cell.authorLabel.text = author
        cell.bookCover.image = cover
        
        cell.bookCover = Util.imageViewShadow(imageView: (cell.bookCover)!)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if (indexPath.row % 2) == 0 {
            cell.backgroundColor = UIColor(colorLiteralRed: 0.99, green: 0.99, blue: 0.99, alpha: 1)
        }
    }
}

func getBookInfo(_ bookPath:String) -> (String, String, UIImage?)
{
    var title = ""
    var author = ""
    var cover = UIImage()
    
    do {
        title = try FolioReader.getTitle(bookPath)!
        author = try FolioReader.getAuthorName(bookPath)!
        
        if let myCover = try FolioReader.getCoverImage(bookPath) { cover = myCover }
        else {cover = Util.burnText2ImageView(image:UIImage(named: "BookCover.png")!, title: title)}
        
    } catch {
        print(error)
        cover = Util.burnText2ImageView(image:UIImage(named: "BookCover.png")!, title: title)
    }
    /*
    
    title = FolioReader.getTitle(bookPath)!
    author = FolioReader.getAuthorName(bookPath)!
    
    if FolioReader.getCoverImage(bookPath) != nil
    {
        cover = FolioReader.getCoverImage(bookPath)!
    }
    else {
        cover = Util.burnText2ImageView(image:UIImage(named: "BookCover.png")!, title: title)
    }
    
    */
    
    
    return (title, author, cover)
}


//MARK: UITableViewDelegate Handler Extension

extension MyBooksViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedIndexPath = indexPath
        let epubName = downloadedFilesArray[indexPath.row]
        openEpub(epubName)
        
    }
    
    func openEpub(_ epubName: String) {
        

        
        
        
        // Custom sharing quote background
  /*      let customImageQuote = QuoteImage(withImage: UIImage(named: "demo-bg")!, alpha: 0.6, backgroundColor: UIColor.black)
        let customQuote = QuoteImage(withColor: UIColor(red:0.30, green:0.26, blue:0.20, alpha:1.0), alpha: 1.0, textColor: UIColor(red:0.86, green:0.73, blue:0.70, alpha:1.0))
        
        config.quoteCustomBackgrounds = [customImageQuote, customQuote]*/
        
        // Epub file
        //let epubName = "54483";
        let bookPath = myDownloadPath+"/\(epubName)"
        
        print("bookPath:\(bookPath)")
        FolioReader.presentReader(parentViewController: self, withEpubPath: bookPath, andConfig: config, shouldRemoveEpub: false)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let fileName : NSString = downloadedFilesArray[(indexPath as NSIndexPath).row] as NSString
        let fileURL  : URL = URL(fileURLWithPath: (myDownloadPath as NSString).appendingPathComponent(fileName as String))
        
        do {
            try fileManger.removeItem(at: fileURL)
            downloadedFilesArray.remove(at: (indexPath as NSIndexPath).row)
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        } catch let error as NSError {
            debugPrint("Error while deleting file: \(error)")
        }
    }
}
