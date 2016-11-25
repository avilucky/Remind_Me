//
//  SearchResultsController.swift
//  Remind_Me
//
//  Created by Ajinkya Kulkarni on 10/29/16.
//  Copyright © 2016 Ajinkya Kulkarni. All rights reserved.
//


import UIKit

protocol LocateOnTheMap{
    func locateWithLongitude(_ lon:Double, andLatitude lat:Double, andTitle title: String)
}

class SearchResultsController: UITableViewController {

    
    
    var searchResults: [String]!
    var delegate: LocateOnTheMap!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchResults = Array()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.searchResults.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        
        cell.textLabel?.text = self.searchResults[(indexPath as NSIndexPath).row]
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath){
        
        
        
        
        
        
        
        // 1
        self.dismiss(animated: true, completion: nil)
        // 2
        let valueAtIndex = self.searchResults![(indexPath as NSIndexPath).row].addingPercentEncoding(withAllowedCharacters: CharacterSet.symbols)
        guard let correctedAddress = valueAtIndex else { return }
        let adrString:String = "https://maps.googleapis.com/maps/api/geocode/json?address=\(correctedAddress)&sensor=false"
        let url:URL = URL(string: adrString)!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) -> Void in
            // 3
            do {
                if data != nil{
                    
                    let dic = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                    
                    let array = dic["results"]! as! NSArray
                    
                    
                    print(array)
                    print(array[0])
                    print(type(of: array[0]))
                    
                    let results = array[0] as! NSDictionary
                    
                    let geometry = results["geometry"] as! NSDictionary
                    let location = geometry["location"] as! NSDictionary
                    
                    let lat = location["lat"] as! Double
                    let lon = location["lng"] as! Double
                    
                    var address = results["formatted_address"] as! String
                    
                    print(address)
                    if(address.isEmpty)
                    {
                        address = ""
                    }
                    
                    let defaults = UserDefaults.standard
                    defaults.set(address, forKey: "locationAddress")
                    defaults.set(lat, forKey: "latitude")
                    defaults.set(lon, forKey: "longitude")
                    
                   // 4
                    print("From Coordinates: \(lat) and \(lon)")
                    self.delegate.locateWithLongitude(lon, andLatitude: lat, andTitle: self.searchResults[indexPath.row] )
                    
                    // 4
                }
                
            }catch {
                print("Error")
            }
        }
        // 5
        task.resume()
    }
    
    
    func reloadDataWithArray(_ array:[String]){
        self.searchResults = array
        self.tableView.reloadData()
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
