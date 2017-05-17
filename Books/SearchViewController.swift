//
//  SearchViewController.swift
//  Books
//
//  Created by 김인로 on 2017. 5. 15..
//  Copyright © 2017년 김인로. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController {
    
    // MARK: - Properties
    let searchController = UISearchController(searchResultsController: nil)
    
    var sortOrder = "release_date"; //or downloads means favorites
    let baseUrl = "http://m.gutenberg.org/ebooks/search.mobile/?sort_order=downloads&query="
    let rowCountDisplayed = 25
    
    var actInd : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40)) as UIActivityIndicatorView
    
    var books = [Book]()
    var booksCount:Int = 0
    
    // MARK: - View Setup
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self 
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
        // Setup the Scope Bar
        //searchController.searchBar.scopeButtonTitles = ["All", "Chocolate", "Hard", "Other"]
        tableView.tableHeaderView = searchController.searchBar
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
                book.url = baseUrl+sortOrder
                
                //print("title : "+contentLines[6])
                //print("author : "+contentLines[7])
                
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
    
    override func viewWillAppear(_ animated: Bool) {
        //clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
}

extension SearchViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        //filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
        
        print("1 searchBar.text = \(String(describing: searchBar.text))")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
         books = []
         getDataFromURL(baseUrl+searchBar.text!)
    }
}

extension SearchViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
       // let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
//        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
        print("2 baseUrl+searchBar.text:\(baseUrl)\(String(describing: searchBar.text))")
        

    }
}
