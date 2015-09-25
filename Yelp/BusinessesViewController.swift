//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FiltersViewControllerDelegate, UISearchBarDelegate {

    @IBOutlet weak var filtersBarButton: UIBarButtonItem!
    var businesses: [Business]!
    var currentFilters: [String: AnyObject]?
    var defaultCurrentFilters = [String: AnyObject]()
    let metersPerMile = 1609.34
    var searchBar: UISearchBar?
    @IBOutlet weak var noResultsFoundView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.749, green: 0.0902, blue: 0, alpha: 1.0)
        
        let navigationSearchBar = UISearchBar()
        navigationSearchBar.sizeToFit()
        navigationItem.titleView = navigationSearchBar
        searchBar = navigationSearchBar
        navigationSearchBar.delegate = self
        
        
        defaultCurrentFilters["categories"] = []
        defaultCurrentFilters["deals"] = false as Bool
        defaultCurrentFilters["distance"] = metersPerMile
        defaultCurrentFilters["sort"] = 1
        
        
        Business.searchWithTerm("Restaurants", sort: .Distance, categories: nil, deals: false, radius: metersPerMile) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
            self.showError(businesses)
        }
    }
    
    func showError(businesses: [Business]) {
        noResultsFoundView.hidden = true
        if businesses.count == 0 {
            noResultsFoundView.hidden = false
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        searchBar?.resignFirstResponder()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        searchBar?.endEditing(true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses!.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        
        cell.business = businesses[indexPath.row]
        
        return cell
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let currentFilters = currentFilters {
            search(currentFilters)
        } else {
            search(defaultCurrentFilters)
        }
        searchBar.endEditing(true)
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navigationController = segue.destinationViewController as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        filtersViewController.delegate = self
        
        filtersViewController.initialFilters = currentFilters != nil ? currentFilters : defaultCurrentFilters
    }
    
    func search(filters: [String: AnyObject]) {
        let categories = filters["categories"] as? [String]
        let deals = filters["deals"] as! Bool
        let distance = filters["distance"] as? Double
        var sortOrder = YelpSortMode.BestMatched
        if let sort = filters["sort"] as? Int {
            sortOrder =  YelpSortMode(rawValue: sort)!
        }
        var searchTerm = "Restaurants"
        if let searchText = searchBar!.text {
            searchTerm = searchText
        }
        
        Business.searchWithTerm(searchTerm, sort: sortOrder, categories: categories, deals: deals, radius: distance) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
            self.showError(businesses)
        }
        if businesses.count > 0 {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
        }
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        currentFilters = filters
        search(filters)
    }

}
