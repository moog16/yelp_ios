//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Matthew Goo on 9/22/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit

enum FilterTypes: Int {
    case Deals = 0
    case Distance = 1
    case Sort = 2
    case Category = 3
}

@objc protocol FiltersViewControllerDelegate {
    optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String:AnyObject])
}

class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate {

    @IBOutlet weak var filtersTableView: UITableView!
    weak var delegate: FiltersViewControllerDelegate?
    let metersPerMile = 1609.34
    
    var filterCategoryStates = [Int: Bool]()
    var dealsState: Bool = false
    var distanceState: Double?
    var sortState: Int?
    var initialFilters: [String:AnyObject]?
    
    var showAllDistances: Bool = false
    var showAllSorts: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filtersTableView.delegate = self
        filtersTableView.dataSource = self
        filtersTableView.separatorColor = UIColor.clearColor()
        
        if let initialFilters = initialFilters {
            // set initial categories - could be better than n^2
            if let initialCategories = initialFilters["categories"] {
                let initialStringCategories = initialCategories as! [String]
                for initCategory in initialStringCategories {
                    for (index, category) in categories.enumerate() {
                        if category["code"] == initCategory {
                            filterCategoryStates[index] = true
                        }
                    }
                }
            }
            
            if let initialDeals = initialFilters["deals"] {
                dealsState = initialDeals as! Bool
            }
            
            if let initialSort = initialFilters["sort"] {
                sortState = initialSort as? Int
            }
            
            if let initialDistance = initialFilters["distance"] {
                distanceState = (initialDistance as! Double)/metersPerMile
            }
        }
        
    }
    
    func distanceCell(indexPath: NSIndexPath, tableView: UITableView) -> CheckboxCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CheckboxCell", forIndexPath: indexPath) as! CheckboxCell
        let distance = distances[indexPath.row]
        cell.value = distance
        cell.checkboxLabel.text = "\(distance) miles"
        if distanceState != nil {
            if distanceState! == cell.value as! Double {
                cell.checkOn()
            } else {
                cell.checkOff()
            }
        } else {
            cell.checkOff()
        }
        return cell
    }
    
    func sortCell(indexPath: NSIndexPath, tableView: UITableView) -> CheckboxCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CheckboxCell", forIndexPath: indexPath) as! CheckboxCell
        cell.value = indexPath.row
        cell.checkboxLabel.text = YelpSortMode(rawValue: indexPath.row)!.label
        if sortState != nil {
            if sortState! == cell.value as! Int {
                cell.checkOn()
            } else {
                cell.checkOff()
            }
        } else {
            cell.checkOff()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == FilterTypes.Deals.rawValue ||
            indexPath.section == FilterTypes.Category.rawValue {
         
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
            cell.delegate = self
                
            if indexPath.section == FilterTypes.Deals.rawValue {
                cell.switchLabel.text = "Offering a Deal"
                cell.onSwitch.on = dealsState
            } else {
                cell.switchLabel.text = categories[indexPath.row]["name"]
                cell.onSwitch.on = filterCategoryStates[indexPath.row] ?? false
            }
            return cell
        } else {
            if indexPath.section == FilterTypes.Distance.rawValue {
                if showAllDistances {
                    return distanceCell(indexPath, tableView: tableView)
                } else {
                    let cell = tableView.dequeueReusableCellWithIdentifier("DropDownCell", forIndexPath: indexPath) as! DropDownCell
                    cell.dropDownLabel.text = "\(distanceState) miles"
                    return cell
                }
            } else {
                if showAllSorts {
                    return sortCell(indexPath, tableView: tableView)
                } else {
                    let cell = tableView.dequeueReusableCellWithIdentifier("DropDownCell", forIndexPath: indexPath) as! DropDownCell
                    if let sortState = sortState {
                        cell.dropDownLabel.text = "\(YelpSortMode(rawValue: sortState)!.label)"
                    } else {
                        cell.dropDownLabel.text = "Sort"
                    }
                    return cell
                }
            }
        }
    }
    
    func getDistanceCell(value: Double) -> CheckboxCell? {
        let row = distances.indexOf(value)
        if let row = row {
            let indexPath = NSIndexPath(forRow: row, inSection: FilterTypes.Distance.rawValue)
            return filtersTableView.cellForRowAtIndexPath(indexPath) as? CheckboxCell
        }
        return nil
    }
    
    func getSortCell(value: Int) -> CheckboxCell? {
        let indexPath = NSIndexPath(forRow: value, inSection: FilterTypes.Sort.rawValue)
        if let cell = filtersTableView.cellForRowAtIndexPath(indexPath) {
            return cell as? CheckboxCell
        }
        return nil
    }
    
    func animateDistanceSection() {
        let index = NSIndexSet(index: FilterTypes.Distance.rawValue)
        filtersTableView.reloadSections(index, withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func animateSortSection() {
        let index = NSIndexSet(index: FilterTypes.Sort.rawValue)
        filtersTableView.reloadSections(index, withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func animateTableViewSection(index: FilterTypes) {
        let index = NSIndexSet(index: index.rawValue)
        filtersTableView.reloadSections(index, withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let isDistanceSection = indexPath.section == FilterTypes.Distance.rawValue
        let isSortSection = indexPath.section == FilterTypes.Sort.rawValue
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if showAllDistances == false && isDistanceSection {
            showAllDistances = true
            animateTableViewSection(FilterTypes.Distance)
        } else if showAllSorts == false && isSortSection {
            showAllSorts = true
            animateTableViewSection(FilterTypes.Sort)
        } else if isDistanceSection || isSortSection {
            let cell = filtersTableView.cellForRowAtIndexPath(indexPath) as! CheckboxCell
            if cell.isSelected == true {
                cell.checkOff()
            } else {
                cell.checkOn()
                if isDistanceSection {
                    if distanceState != nil {
                        if let distanceCell = getDistanceCell(distanceState!) {
                            if distanceCell != cell {
                                distanceCell.checkOff()
                            }
                        }
                    }
                    distanceState = cell.value as? Double
                    showAllDistances = false
                    animateTableViewSection(FilterTypes.Distance)
                } else if isSortSection {
                    if sortState != nil {
                        if let sortCell = getSortCell(sortState!) {
                            if sortCell != cell {
                                sortCell.checkOff()
                            }
                        }
                    }
                    sortState = cell.value as? Int
                    showAllSorts = false
                    animateTableViewSection(FilterTypes.Sort)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == FilterTypes.Category.rawValue {
            return categories.count
        } else if section == FilterTypes.Distance.rawValue {
            return showAllDistances == true ? distances.count : 1
        } else if section == FilterTypes.Sort.rawValue {
            return showAllSorts ==  true ? YelpSortMode.count : 1
        } else {
            return 1
        }
    }
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = filtersTableView.indexPathForCell(switchCell)!
        if indexPath.section == FilterTypes.Deals.rawValue {
            dealsState = value
        } else {
            filterCategoryStates[indexPath.row] = value
        }

    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Distance"
        case 2:
            return "Sort By"
        case 3:
            return "Category"
        default:
            return ""
        }
    }
    
    @IBAction func onCancelButton(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onSearchButton(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
        var filters = [String: AnyObject]()
        var selectedCategories = [String]()
        for (row, isSelected) in filterCategoryStates {
            if isSelected {
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        
        if let distanceState = distanceState {
            filters["distance"] = distanceState * metersPerMile // in meters
        }
        
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories
        }
        
        if sortState != nil {
            filters["sort"] = sortState
        }

        filters["deals"] = dealsState
        delegate?.filtersViewController?(self, didUpdateFilters: filters)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    let distances:[Double] = [10.0, 5.0, 2.0, 1.0, 0.75, 0.5, 0.2, 0.1]
    
    let categories = [["name" : "Afghan", "code": "afghani"],
        ["name" : "African", "code": "african"],
        ["name" : "American, New", "code": "newamerican"],
        ["name" : "American, Traditional", "code": "tradamerican"],
        ["name" : "Arabian", "code": "arabian"],
        ["name" : "Argentine", "code": "argentine"],
        ["name" : "Armenian", "code": "armenian"],
        ["name" : "Asian Fusion", "code": "asianfusion"],
        ["name" : "Asturian", "code": "asturian"],
        ["name" : "Australian", "code": "australian"],
        ["name" : "Austrian", "code": "austrian"],
        ["name" : "Baguettes", "code": "baguettes"],
        ["name" : "Bangladeshi", "code": "bangladeshi"],
        ["name" : "Barbeque", "code": "bbq"],
        ["name" : "Basque", "code": "basque"],
        ["name" : "Bavarian", "code": "bavarian"],
        ["name" : "Beer Garden", "code": "beergarden"],
        ["name" : "Beer Hall", "code": "beerhall"],
        ["name" : "Beisl", "code": "beisl"],
        ["name" : "Belgian", "code": "belgian"],
        ["name" : "Bistros", "code": "bistros"],
        ["name" : "Black Sea", "code": "blacksea"],
        ["name" : "Brasseries", "code": "brasseries"],
        ["name" : "Brazilian", "code": "brazilian"],
        ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
        ["name" : "British", "code": "british"],
        ["name" : "Buffets", "code": "buffets"],
        ["name" : "Bulgarian", "code": "bulgarian"],
        ["name" : "Burgers", "code": "burgers"],
        ["name" : "Burmese", "code": "burmese"],
        ["name" : "Cafes", "code": "cafes"],
        ["name" : "Cafeteria", "code": "cafeteria"],
        ["name" : "Cajun/Creole", "code": "cajun"],
        ["name" : "Cambodian", "code": "cambodian"],
        ["name" : "Canadian", "code": "New)"],
        ["name" : "Canteen", "code": "canteen"],
        ["name" : "Caribbean", "code": "caribbean"],
        ["name" : "Catalan", "code": "catalan"],
        ["name" : "Chech", "code": "chech"],
        ["name" : "Cheesesteaks", "code": "cheesesteaks"],
        ["name" : "Chicken Shop", "code": "chickenshop"],
        ["name" : "Chicken Wings", "code": "chicken_wings"],
        ["name" : "Chilean", "code": "chilean"],
        ["name" : "Chinese", "code": "chinese"],
        ["name" : "Comfort Food", "code": "comfortfood"],
        ["name" : "Corsican", "code": "corsican"],
        ["name" : "Creperies", "code": "creperies"],
        ["name" : "Cuban", "code": "cuban"],
        ["name" : "Curry Sausage", "code": "currysausage"],
        ["name" : "Cypriot", "code": "cypriot"],
        ["name" : "Czech", "code": "czech"],
        ["name" : "Czech/Slovakian", "code": "czechslovakian"],
        ["name" : "Danish", "code": "danish"],
        ["name" : "Delis", "code": "delis"],
        ["name" : "Diners", "code": "diners"],
        ["name" : "Dumplings", "code": "dumplings"],
        ["name" : "Eastern European", "code": "eastern_european"],
        ["name" : "Ethiopian", "code": "ethiopian"],
        ["name" : "Fast Food", "code": "hotdogs"],
        ["name" : "Filipino", "code": "filipino"],
        ["name" : "Fish & Chips", "code": "fishnchips"],
        ["name" : "Fondue", "code": "fondue"],
        ["name" : "Food Court", "code": "food_court"],
        ["name" : "Food Stands", "code": "foodstands"],
        ["name" : "French", "code": "french"],
        ["name" : "French Southwest", "code": "sud_ouest"],
        ["name" : "Galician", "code": "galician"],
        ["name" : "Gastropubs", "code": "gastropubs"],
        ["name" : "Georgian", "code": "georgian"],
        ["name" : "German", "code": "german"],
        ["name" : "Giblets", "code": "giblets"],
        ["name" : "Gluten-Free", "code": "gluten_free"],
        ["name" : "Greek", "code": "greek"],
        ["name" : "Halal", "code": "halal"],
        ["name" : "Hawaiian", "code": "hawaiian"],
        ["name" : "Heuriger", "code": "heuriger"],
        ["name" : "Himalayan/Nepalese", "code": "himalayan"],
        ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
        ["name" : "Hot Dogs", "code": "hotdog"],
        ["name" : "Hot Pot", "code": "hotpot"],
        ["name" : "Hungarian", "code": "hungarian"],
        ["name" : "Iberian", "code": "iberian"],
        ["name" : "Indian", "code": "indpak"],
        ["name" : "Indonesian", "code": "indonesian"],
        ["name" : "International", "code": "international"],
        ["name" : "Irish", "code": "irish"],
        ["name" : "Island Pub", "code": "island_pub"],
        ["name" : "Israeli", "code": "israeli"],
        ["name" : "Italian", "code": "italian"],
        ["name" : "Japanese", "code": "japanese"],
        ["name" : "Jewish", "code": "jewish"],
        ["name" : "Kebab", "code": "kebab"],
        ["name" : "Korean", "code": "korean"],
        ["name" : "Kosher", "code": "kosher"],
        ["name" : "Kurdish", "code": "kurdish"],
        ["name" : "Laos", "code": "laos"],
        ["name" : "Laotian", "code": "laotian"],
        ["name" : "Latin American", "code": "latin"],
        ["name" : "Live/Raw Food", "code": "raw_food"],
        ["name" : "Lyonnais", "code": "lyonnais"],
        ["name" : "Malaysian", "code": "malaysian"],
        ["name" : "Meatballs", "code": "meatballs"],
        ["name" : "Mediterranean", "code": "mediterranean"],
        ["name" : "Mexican", "code": "mexican"],
        ["name" : "Middle Eastern", "code": "mideastern"],
        ["name" : "Milk Bars", "code": "milkbars"],
        ["name" : "Modern Australian", "code": "modern_australian"],
        ["name" : "Modern European", "code": "modern_european"],
        ["name" : "Mongolian", "code": "mongolian"],
        ["name" : "Moroccan", "code": "moroccan"],
        ["name" : "New Zealand", "code": "newzealand"],
        ["name" : "Night Food", "code": "nightfood"],
        ["name" : "Norcinerie", "code": "norcinerie"],
        ["name" : "Open Sandwiches", "code": "opensandwiches"],
        ["name" : "Oriental", "code": "oriental"],
        ["name" : "Pakistani", "code": "pakistani"],
        ["name" : "Parent Cafes", "code": "eltern_cafes"],
        ["name" : "Parma", "code": "parma"],
        ["name" : "Persian/Iranian", "code": "persian"],
        ["name" : "Peruvian", "code": "peruvian"],
        ["name" : "Pita", "code": "pita"],
        ["name" : "Pizza", "code": "pizza"],
        ["name" : "Polish", "code": "polish"],
        ["name" : "Portuguese", "code": "portuguese"],
        ["name" : "Potatoes", "code": "potatoes"],
        ["name" : "Poutineries", "code": "poutineries"],
        ["name" : "Pub Food", "code": "pubfood"],
        ["name" : "Rice", "code": "riceshop"],
        ["name" : "Romanian", "code": "romanian"],
        ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
        ["name" : "Rumanian", "code": "rumanian"],
        ["name" : "Russian", "code": "russian"],
        ["name" : "Salad", "code": "salad"],
        ["name" : "Sandwiches", "code": "sandwiches"],
        ["name" : "Scandinavian", "code": "scandinavian"],
        ["name" : "Scottish", "code": "scottish"],
        ["name" : "Seafood", "code": "seafood"],
        ["name" : "Serbo Croatian", "code": "serbocroatian"],
        ["name" : "Signature Cuisine", "code": "signature_cuisine"],
        ["name" : "Singaporean", "code": "singaporean"],
        ["name" : "Slovakian", "code": "slovakian"],
        ["name" : "Soul Food", "code": "soulfood"],
        ["name" : "Soup", "code": "soup"],
        ["name" : "Southern", "code": "southern"],
        ["name" : "Spanish", "code": "spanish"],
        ["name" : "Steakhouses", "code": "steak"],
        ["name" : "Sushi Bars", "code": "sushi"],
        ["name" : "Swabian", "code": "swabian"],
        ["name" : "Swedish", "code": "swedish"],
        ["name" : "Swiss Food", "code": "swissfood"],
        ["name" : "Tabernas", "code": "tabernas"],
        ["name" : "Taiwanese", "code": "taiwanese"],
        ["name" : "Tapas Bars", "code": "tapas"],
        ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
        ["name" : "Tex-Mex", "code": "tex-mex"],
        ["name" : "Thai", "code": "thai"],
        ["name" : "Traditional Norwegian", "code": "norwegian"],
        ["name" : "Traditional Swedish", "code": "traditional_swedish"],
        ["name" : "Trattorie", "code": "trattorie"],
        ["name" : "Turkish", "code": "turkish"],
        ["name" : "Ukrainian", "code": "ukrainian"],
        ["name" : "Uzbek", "code": "uzbek"],
        ["name" : "Vegan", "code": "vegan"],
        ["name" : "Vegetarian", "code": "vegetarian"],
        ["name" : "Venison", "code": "venison"],
        ["name" : "Vietnamese", "code": "vietnamese"],
        ["name" : "Wok", "code": "wok"],
        ["name" : "Wraps", "code": "wraps"],
        ["name" : "Yugoslav", "code": "yugoslav"]]

}
