//
//  MapsViewController.swift
//  Remind_Me
//
//  Created by Ajinkya Kulkarni on 10/29/16.
//  Copyright © 2016 Ajinkya Kulkarni. All rights reserved.
//


import UIKit
import GoogleMaps
import GooglePlaces

class MapsViewController: UIViewController,UISearchBarDelegate, LocateOnTheMap {
    
    var searchResultController:SearchResultsController!
    var resultsArray = [String]()
    var googleMapsView:GMSMapView!
    
    @IBOutlet var mapViewContainer: UIView!
    
    @IBAction func showSearchController(_ sender: AnyObject) {
        
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.delegate = self
        self.present(searchController, animated: true, completion: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.googleMapsView =  GMSMapView(frame: self.mapViewContainer.frame)
        self.view.addSubview(self.googleMapsView)
        searchResultController = SearchResultsController()
        searchResultController.delegate = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locateWithLongitude(_ lon: Double, andLatitude lat: Double, andTitle title: String) {
        
        DispatchQueue.main.async { () -> Void in
            let position = CLLocationCoordinate2DMake(lat, lon)
            let marker = GMSMarker(position: position)
            
            let camera  = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 16)
            self.googleMapsView.camera = camera
            
            marker.title = title
            marker.map = self.googleMapsView
        }
    }
    
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String){
        
        let placesClient = GMSPlacesClient()
        placesClient.autocompleteQuery(searchText, bounds: nil, filter: nil) {
            
            (results, error) -> Void in
            self.resultsArray.removeAll()
            if results == nil {
                return
            }
            
            for result in results!{
               
                if let result = result as? GMSAutocompletePrediction{
                    self.resultsArray.append(result.attributedFullText.string)
                }
            }
            self.searchResultController.reloadDataWithArray(self.resultsArray)
        }
    }
}

