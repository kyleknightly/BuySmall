//
//  TableViewController.swift
//  SmallBusinessFinder
//
//  Created by Kyle Knightly on 3/30/21.
//

import UIKit

class TableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet var UITableView: UITableView!
    
    var csvRows: [[String]] = []
    var businessNames: [String] = []
    var filteredData: [String]!
    var filteredNumbers: [String] = []
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let data = openCSV(fileName: "TabSeperatedHoustonSmallBusinesses", fileType: "tsv")
        self.csvRows = csv(data: data!)
        createBusinessNamesList()
        searchBar.delegate = self
        filteredData = businessNames

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: Functions

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredData.count-1
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("selected row")
        print(indexPath.row)
        print(csvRows[indexPath.row][4])
        let mapsURLSpaces = "maps://?address="+(csvRows[indexPath.row][4])
        print (mapsURLSpaces)
        let mapsURL = mapsURLSpaces.replacingOccurrences(of: " ", with: "+")
        print (mapsURL)
        UIApplication.shared.openURL(URL(string: mapsURL)!)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = filteredData[indexPath.row+1]

        return cell
    }
    
    func createBusinessNamesList() {
        for row in csvRows {
            businessNames.append(row[0])
        }
        print(businessNames)
        
    }
        
    // MARK: Data Parsing
    
    func openCSV(fileName:String, fileType: String)-> String!{
       guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType)
           else {
               return nil
       }
       do {
           let contents = try String(contentsOfFile: filepath, encoding: .utf8)

           return contents
       } catch {
           print("File Read Error for file \(filepath)")
           return nil
       }
   }
    
    func csv(data: String) -> [[String]] {
           var result: [[String]] = []
           let rows = data.components(separatedBy: "\n")
           for row in rows {
               let columns = row.components(separatedBy: "\t")
               result.append(columns)
           }
           return result
    }
    
    // MARK: Search Bar
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = []
        if searchText == "" {
            filteredData = businessNames
        }
        else {
            for name in businessNames {
                if name.contains(searchBar.text!){
                    filteredData.append(name)
                }
            }
//            for row in csvRows {
//                let rowString = row.joined(separator: " ")
//                if rowString.contains(searchBar.text!) {
//                    filteredData.append(row[1])
//                    print (row[1])
//                }
//            }
        self.tableView.reloadData()
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
