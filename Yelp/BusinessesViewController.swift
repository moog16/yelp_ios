//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FiltersViewControllerDelegate     {

    var businesses: [Business]!
    var currentFilters: [String: AnyObject]?
    var defaultCurrentFilters = [String: AnyObject]()
    let metersPerMile = 1609.34
    @IBOutlet weak var noResultsFoundView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        let searchBar = UISearchBar()
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        defaultCurrentFilters["categories"] = ["burgers"]
        defaultCurrentFilters["deals"] = true as Bool
        defaultCurrentFilters["distance"] = metersPerMile
        defaultCurrentFilters["sort"] = 1
        
        
        Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["burgers"], deals: true, radius: metersPerMile) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
            self.showError(businesses)
            
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
        }
    }
    
    func showError(businesses: [Business]) {
        noResultsFoundView.hidden = true
        if businesses.count == 0 {
            noResultsFoundView.hidden = false
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navigationController = segue.destinationViewController as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        filtersViewController.delegate = self
        
        filtersViewController.initialFilters = currentFilters != nil ? currentFilters : defaultCurrentFilters
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        currentFilters = filters
        let categories = filters["categories"] as? [String]
        let deals = filters["deals"] as! Bool
        let distance = filters["distance"] as? Double
        var sortOrder = YelpSortMode.BestMatched
        if let sort = filters["sort"] as? Int {
            sortOrder =  YelpSortMode(rawValue: sort)!
        }
        
        Business.searchWithTerm("Restaurants", sort: sortOrder, categories: categories, deals: deals, radius: distance) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
            self.showError(businesses)
        }
    }

}
