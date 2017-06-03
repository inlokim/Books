import UIKit
import FolioReaderKit
import MZDownloadManager
import RealmSwift
import PDFReader
import AVFoundation

class MyBooksViewController: UITableViewController {
    
    var pathOfMyBooksPlist = String()
    var downloadedFilesArray : [String] = []
    var selectedIndexPath    : IndexPath?
    var fileManger           : FileManager = FileManager.default
    
    var myDownloadPath = "\(MZUtility.baseFilePath)/ePub"
   
    var booksInfo:NSMutableArray = NSMutableArray()
    var badgeCount:Int = 0
    
    @IBOutlet weak var categoryButton: UIButton!
    
    @IBAction func categoryAction(_ sender: Any) {
        
    }
   
    let config = FolioReaderConfig()

    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
       // title = "My Books"
        
        // Do any additional setup after loading the view.
       print("ePub Dir :\(MZUtility.baseFilePath+"/ePub")")
        
       
        NotificationCenter.default.addObserver(self, selector: NSSelectorFromString("downloadFinishedNotification:"), name: NSNotification.Name(rawValue: MZUtility.DownloadCompletedNotif as String), object: nil)

//        readerConfig()
        plistSetup()
       
        //reveal view
        
/*        if revealViewController() != nil {
            
            print("revealViewController")
            //revealViewController().rearViewRevealWidth = 62
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
           
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
*/
        

   }
    
    override func viewDidAppear(_ animated: Bool) {
        badgeCount = 0
        tabBarController?.tabBar.items?[0].badgeValue = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        badgeCount = 0
        tabBarController?.tabBar.items?[0].badgeValue = nil
    }
    
    func updateBadge()
    {
        tabBarController?.tabBar.items?[0].badgeValue = String(badgeCount)
    }
/*    func sortedFileList() -> [String]
    {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folder = directory.appendingPathComponent("/ePub")
        
        if let urlArray = try? FileManager.default.contentsOfDirectory(at: folder,
                                                                       includingPropertiesForKeys: [.contentModificationDateKey],
                                                                       options:.skipsHiddenFiles)
        {
            return urlArray.map { url in
                (url.lastPathComponent, (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast)
                }
                .sorted(by: { $0 > $1 }) // sort descending modification dates
                .map { $0.0 } // extract file names
            
        }
        else
        {
            return [""]
        }
    }
    
    func filteredfileList()
    {
        
       // let fileList = try? FileManager.default.contentsOfDirectory(atPath: myDownloadPath)
        //downloadedFilesArray = (fileList?.filter { $0.contains(".epub") || $0.contains(".pdf") })!

        
        downloadedFilesArray = sortedFileList().filter{ $0.contains(".epub") || $0.contains(".pdf") }
    }
 */
    
/*    func plist()
    {
        var myDict: NSDictionary?
        if let path = Bundle.main.path(forResource: "Colletions", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        if let dict = myDict {
            // Use your dict here
            print(dict)
            
        }
    }
*/
    func plistSetup()
    {
        //Plist
        pathOfMyBooksPlist = myDownloadPath+"/MyBooks.plist"
        
        if NSMutableArray(contentsOfFile: pathOfMyBooksPlist) != nil {
            booksInfo = NSMutableArray(contentsOfFile: pathOfMyBooksPlist)!
        }
        else { booksInfo = NSMutableArray() }
        
        print(booksInfo.count)
    }
    
    
    //sort desc
    
    func updateBooksInfo()
    {
        let saveBooksInfo = NSMutableArray(array: booksInfo.reverseObjectEnumerator().allObjects).mutableCopy() as! NSMutableArray
        saveBooksInfo.write(toFile: pathOfMyBooksPlist, atomically: true)
    }
    
    // MARK: - NSNotification Methods -
    
    func downloadFinishedNotification(_ notification : Notification)
    {
        print("downloadFinishedNotification")
        plistSetup()
        //updateBooksInfo()
        
        badgeCount += 1
        updateBadge()
        tableView.reloadData()
    }


    
    //EPUB
    func readerConfig()
    {
        print("readerConfig")
        
        let settings = Util.getSettings()

        config.shouldHideNavigationOnTap = true
        config.scrollDirection = .horizontal
        config.hidePageIndicator = true

        // See more at FolioReaderConfig.swift
        //        config.canChangeScrollDirection = false
        
        config.enableTTS = settings.object(forKey: "tts") as! Bool
        
/*        if config.enableTTS == false { backgroundSoundSetting(false)}
        else
        {
            let onoff = settings.object(forKey: "back_audio") as! Bool
            backgroundSoundSetting(onoff)
        }
 */
        
        let color = settings.object(forKey: "menu_color") as! String
        
        switch color {
        case "Black":
            config.tintColor = UIColor.black
        case "Red":
            config.tintColor = UIColor.red
        case "Blue":
            config.tintColor = UIColor.blue
        case "Purple":
            config.tintColor = UIColor.purple
        case "Green":
            config.tintColor = UIColor.green
        case "Brown":
            config.tintColor = UIColor.brown
        case "DarkGray":
            config.tintColor = UIColor.darkGray
        default:
            config.tintColor = UIColor.purple
        }

        //config.allowSharing = false
        
        //config.menuTextColor = UIColor.brown
        //config.menuBackgroundColor = UIColor.lightGray
        
        //        config.hidePageIndicator = true
        //    config.realmConfiguration = Realm.Configuration(fileURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("highlights.realm"))
        
  //      print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("highlights.realm"))
        
        
       // config.realmConfiguration = Realm.Configuration(fileURL: URL(fileURLWithPath: myDownloadPath).appendingPathComponent("highlights.realm"))

    }
    
/*    func backgroundSoundSetting(_ value:Bool)
    {
        //Background Sound
        
        print("background Sound : \(value)!")
        
        if (value == false)
        {
            do { try AVAudioSession.sharedInstance().setActive(false) }
            catch {
                print("AVAudioSession is NOT Active")
            }
        }
        else
        {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
                print("AVAudioSession Category Playback OK")
                do {
                    try AVAudioSession.sharedInstance().setActive(true)
                    print("AVAudioSession is Active")
                } catch {
                    print(error)
                }
            } catch {
                print(error)
            }
        }
    }
*/
    
    func openEpub(_ epubName: String) {
        
        readerConfig()
        
        let bookPath = myDownloadPath+"/\(epubName)"
        
        print("bookPath:\(bookPath)")
        FolioReader.presentReader(parentViewController: self, withEpubPath: bookPath, andConfig: config, shouldRemoveEpub: false)
    }
    
    
    //PDF
    func openPDF(_ pdfName: String, title: String)
    {
        let path = myDownloadPath+"/\(pdfName)"
        let documentFileURL = URL(fileURLWithPath: path)
        let document = PDFDocument(url: documentFileURL)!
        
        
        let readerController = PDFViewController.createNew(with: document)
        
        readerController.title = title
        navigationController?.pushViewController(readerController, animated: true)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

//MARK: UITableViewDataSource Handler Extension

extension MyBooksViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return booksInfo.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier : NSString = "DownloadedFileCell"
        let cell : BookTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier as String, for: indexPath) as! BookTableViewCell

        let book = booksInfo.object(at: indexPath.row) as! NSMutableDictionary
        
        cell.titleLabel.text = book.object(forKey: "title") as? String
        cell.authorLabel.text = book.object(forKey: "author") as? String
        
        let fileType = book.object(forKey: "file_type") as? String

        if fileType == "PDF" {
            cell.bookCover.image = Util.burnText2ImageView(image:UIImage(named: "BookCover.png")!, title: cell.titleLabel.text!)
        }
        else {
            cell.bookCover.image = getEPubBookCover(bookId: book.object(forKey: "id") as! String, title: cell.titleLabel.text!)
        }
        
        cell.bookCover = Util.imageViewShadow(imageView: (cell.bookCover)!)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if (indexPath.row % 2) == 0 {
            cell.backgroundColor = UIColor(colorLiteralRed: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        }
    }
}

func getEPubBookCover(bookId:String, title:String) -> UIImage?
{
   
    let bookPath =  MZUtility.baseFilePath + "/ePub/\(bookId).epub"
    
    var cover = UIImage()
    
    do {
        
        if let myCover = try FolioReader.getCoverImage(bookPath) { cover = myCover }
        else {cover = Util.burnText2ImageView(image:UIImage(named: "BookCover.png")!, title: title)}
        
    } catch {
        print(error)
        cover = Util.burnText2ImageView(image:UIImage(named: "BookCover.png")!, title: title)
    }
    
    return cover
}


//MARK: UITableViewDelegate Handler Extension

extension MyBooksViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
       
        selectedIndexPath = indexPath
        
        let book = booksInfo.object(at: indexPath.row) as! NSMutableDictionary
        let bookId : String = book.object(forKey: "id") as! String
        
        var fileName = String()
        let fileType = book.object(forKey: "file_type") as! String
        if fileType == "PDF" {
            fileName = "\(String(describing: bookId)).pdf"
            openPDF(fileName, title: book.object(forKey: "title") as! String)
        }
        else {
            fileName = "\(String(describing: bookId)).epub"
            openEpub(fileName)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let book = booksInfo.object(at: indexPath.row) as! NSMutableDictionary
        let fileName = getFileName(book)
        
        let fileURL  : URL = URL(fileURLWithPath: (myDownloadPath as NSString).appendingPathComponent(fileName as String))
        let docfileURL  : URL = URL(fileURLWithPath: (MZUtility.baseFilePath as NSString).appendingPathComponent(fileName as String))
        
        do {
            try fileManger.removeItem(at: fileURL)
            try fileManger.removeItem(at: docfileURL)
            
            booksInfo.removeObject(at: (indexPath as NSIndexPath).row)
            booksInfo.write(toFile: pathOfMyBooksPlist, atomically: true)
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            
        } catch let error as NSError {
            debugPrint("Error while deleting file: \(error)")
        }
    }
    
    
    func getFileName(_ book:NSMutableDictionary) -> String
    {
        var fileName = String()
        let fileType = book.object(forKey: "file_type") as! String
        let bookId : String = book.object(forKey: "id") as! String
        if fileType == "PDF" { fileName = "\(String(describing: bookId)).pdf"}
        else { fileName = "\(String(describing: bookId)).epub"}
        
        return fileName
    }
}
