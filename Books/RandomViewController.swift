//
//  ListViewController.swift
//  SpeakingBooks
//
//  Created by 김인로 on 2017. 3. 20..
//  Copyright © 2017년 김인로. All rights reserved.
//

import UIKit
import SDWebImage
import GoogleMobileAds

class RandomViewController: UITableViewController
{
    //MARK: Properties
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var sortOrder = String();
    var baseUrl = "http://m.gutenberg.org/ebooks/search.mobile/?"
    let rowCountDisplayed = 25
    
    var actInd : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40)) as UIActivityIndicatorView
    
    var books = [Book]()
    var booksCount:Int = 0
    var startIndex : Int = 0
    
    @IBOutlet weak var refreshButtonItem: UIBarButtonItem!
    
    @IBAction func refreshAction(_ sender: Any) {
        
        books = [Book]()
        tableView.reloadData()
        
        listData()
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

  /*      print("Google Mobile Ads SDK version: " + GADRequest.sdkVersion())
        //bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" //test
        bannerView.adUnitID = "ca-app-pub-1966927625201357/7400352420" //real
        bannerView.rootViewController = self
        bannerView.load(GADRequest())*/
        
        listData()
        

    }
    
    func listData()
    {
        actInd.center = (self.parent?.view.center)!
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        parent?.view.addSubview(actInd)
        
        //XML
        sortOrder = "sort_order=random"
        getDataFromURL(baseUrl+sortOrder)
    }
    
    func runActivity() {
        actInd.startAnimating()
    }
    
    
    func stopActivity() {
        actInd.stopAnimating()
    }
    
    
    func getDataFromURL(_ link:String)
    {
        print("link = "+link)
        
        self.runActivity()
        
        let nsLink = link as NSString
        let urlStr  = nsLink.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url:URL = URL(string: urlStr!)!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (
            data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                
                return
            }
            
            self.extractHTML(data!)
        })
        
        task.resume()
    }
    
    
    func extractHTML(_ data: Data)
    {
        let doc = TFHpple(htmlData: data as Data!)
        let pathQuery1 = "//li[@class='booklink']/a[@class='table link']"
        
        //let pathQuery2 = "//li[@class='booklink']/a[@class='table link']/span/span[@class='cell content']"
        
        if let elements = doc?.search(withXPathQuery: pathQuery1) as? [TFHppleElement] {
            
            for element in elements {
                
                let bookId:String =  getBookId(element.object(forKey: "href"))
                
                //print("bookId : "+bookId)
                
                
                let contentLines = element.content.lines
                
                
                let title = contentLines[6]
                let author = contentLines[7]
                let book = Book()
                
                book.bookId = bookId
                book.title = title
                book.author = author
                book.url = baseUrl+sortOrder //used for Session Id
                
                //print("book.url : "+book.url)
                
                books.append(book)
                //print(contentLines)
            }
        }
        
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            self.stopActivity()
        })
    }
    
    func getBookId(_ str:String) -> String {
        
        var newStr:String
        
        newStr = str.replacingOccurrences(of: "/ebooks/", with: "")
        newStr = newStr.replacingOccurrences(of: ".mobile", with: "")
        
        return newStr
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "BookTableViewCell"
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? BookTableViewCell else {
        //   // fatalError("The dequeued cell is not an instance of BookTableViewCell.")
        // }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BookTableViewCell
        
        // Fetches the appropriate book for the data source layout.
        let book = books[indexPath.row]
        
        //print("book id = "+book.bookId)
        
        cell?.titleLabel.text = book.title
        cell?.authorLabel.text = book.author
        //cell?.bookCover.image = book.cover.image
        
        let bookCover:UIImageView = UIImageView()
        let coverUrl = "http://www.gutenberg.org/cache/epub/"+book.bookId+"/pg"+book.bookId+".cover.medium.jpg"
        
        bookCover.image = Util.burnText2ImageView(image:UIImage(named: "BookCover.png")!, title: book.title)
        cell?.bookCover.sd_setImage(with: URL(string: coverUrl), placeholderImage: bookCover.image)
        cell?.bookCover = Util.imageViewShadow(imageView: (cell?.bookCover)!)
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if (indexPath.row % 2) == 0 {
            cell.backgroundColor = UIColor(colorLiteralRed: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        }
        else {
            cell.backgroundColor = UIColor.white
        }
        
        //Last Element
        let lastElement = books.count - 1
        if indexPath.row == lastElement {
            // handle your logic here to get more items, add it to dataSource and reload tableview
            //let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            /*          let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
             label.text = "Load More..."
             cell.contentView.addSubview(label)*/
            
            if startIndex != books.count + 1
            {
                startIndex = books.count + 1
                
                getDataFromURL(baseUrl+sortOrder+"&start_index=\(startIndex)")
                //print("startIndex : \(startIndex)")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: "showBookInfo", sender: indexPath)
    }
    
    
    //MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showBookInfo" {
            if let detailViewController = segue.destination as? BookInfoViewController {
                let indexPath = self.tableView.indexPathForSelectedRow
                //print(" indexPath  "+self.books[(indexPath?.row)!].bookId)
                detailViewController.book = self.books[(indexPath?.row)!]
            }
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
}







