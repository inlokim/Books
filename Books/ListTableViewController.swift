//
//  ListViewController.swift
//  SpeakingBooks
//
//  Created by 김인로 on 2017. 3. 20..
//  Copyright © 2017년 김인로. All rights reserved.
//

import UIKit
import SDWebImage

extension String {
    var lines: [String] {
        var result: [String] = []
        enumerateLines { line, _ in result.append(line) }
        return result
    }
}

class ListTableViewController: UITableViewController
{
    //MARK: Properties
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var sortOrder = "release_date"; //or downloads means favorites
    var baseUrl = "http://m.gutenberg.org/ebooks/search.mobile/?"
    let rowCountDisplayed = 25
    
    //  let spinner = UIActivityIndicatorView()
    
    var actInd : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40)) as UIActivityIndicatorView
    
    var books = [Book]()
    var booksCount:Int = 0
    
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func sortOrderChanged(_ sender: Any) {
        
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            sortOrder = "sort_order=release_date";
        case 1:
            sortOrder = "sort_order=downloads";

        default:
            break;
        }
        
        books = []
        
        tableView.reloadData()
        getDataFromURL(baseUrl+sortOrder)
        
       // let indexPath = IndexPath(row: 0, section: 0)
       // tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.top)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
        // Setup the Scope Bar
        //searchController.searchBar.scopeButtonTitles = ["All", "Chocolate", "Hard", "Other"]
        tableView.tableHeaderView = searchController.searchBar
        
        actInd.center = (self.parent?.view.center)!
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        parent?.view.addSubview(actInd)
        
        
        //XML
        sortOrder = "sort_order=release_date"
        getDataFromURL(baseUrl+sortOrder)
        
        
        print("session Id : \(Util.sessionId)")
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
        
        let url:URL = URL(string: link)!
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
            cell.backgroundColor = UIColor(colorLiteralRed: 0.99, green: 0.99, blue: 0.99, alpha: 1)
        }
        else {
            cell.backgroundColor = UIColor.white
        }
        
        //Last Element
        let lastElement = books.count - 1
        if indexPath.row == lastElement {
            // handle your logic here to get more items, add it to dataSource and reload tableview
            
            let startIndex = books.count + 1
            
            getDataFromURL(baseUrl+sortOrder+"&start_index=\(startIndex)")
            //print("startIndex : \(startIndex)")
            
            self.tableView.reloadData()
        }
    }
    
    //MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "show" {
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

extension ListTableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        //filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
        
        print("1 searchBar.text = \(String(describing: searchBar.text))")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
        
        books = []
        
        let url = baseUrl+"&query="
        getDataFromURL(url+searchBar.text!)
    }
}

extension ListTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        //let searchBar = searchController.searchBar
        // let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        //        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
        //print("2 baseUrl+searchBar.text:\(baseUrl)\(String(describing: searchBar.text))")
        
    }
}







