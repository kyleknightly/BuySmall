//
//  ViewController.swift
//  SmallBusinessFinder
//
//  Created by Kyle Knightly on 12/01/20.
//

import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation
import SwiftUI

class ViewController: UIViewController, UISearchBarDelegate {
    
    @Environment(\.openURL) var openURL
    
    @IBOutlet weak var openInMapsButton: UIButton!
    @IBOutlet weak var copySiteButton: UIButton!
    @IBOutlet weak var textBox: UITextView!
    @IBOutlet weak var disclaimerBox: UITextView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var csvRows: [[String]] = []
    var businessSites: [String] = []
    var businessAddresses: [String] = []
    var businessDescriptions: [String] = []
    
    var selectedAnnotation: MKPointAnnotation?
    
    // MARK: Functions
    
    @IBAction func refreshButton(_ sender: Any) {
        self.buildAnnotations(rows: self.csvRows)
    }
    
    @IBAction func openInMapsButton(_ sender: Any) {
        print("Open in Maps button pressed")
        let number = Int((selectedAnnotation?.subtitle)!)
        let mapsURLSpaces = "maps://?address="+businessAddresses[number!]
//        print (mapsURLSpaces)
        let mapsURL = mapsURLSpaces.replacingOccurrences(of: " ", with: "+")
//        print (mapsURL)
        openURL(URL(string: mapsURL)!)
    }
    @IBAction func copySiteButton(_ sender: Any) {
        print("Copy Site button pressed")
        //If site == "", display warning
        let number = Int((selectedAnnotation?.subtitle)!)
        if businessSites[number!] == "" {
            let alert = UIAlertController(title: "Business' Site Unavailable", message: "Unfortunately, this business did not provide the Small Business Administration with a valid website.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        else {
            //Copy url
            let pasteboard = UIPasteboard.general
            pasteboard.string = businessSites[number!]
            let alert = UIAlertController(title: "Copied to clipboard", message: "The selected business' website has been copied to your clipboard.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Great!", style: .default, handler: nil))
            self.present(alert, animated: true)
            print(businessSites[number!])
        
        }
      
    }
    
    @IBAction func searchButton(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //Ignoring user
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        //Activity indicator
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = UIActivityIndicatorView.Style.medium
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        self.view.addSubview(activityIndicator)
        
        //Hide search bar
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        //Remove annotations
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        print(searchBar.text ?? "")
        
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        
        //Search through rows
        for row in self.csvRows {
            let rowString = row.joined(separator: " ")
            if rowString.contains(searchBar.text!) {
                let lat = (row[5] as NSString).doubleValue
                let long = (row[6] as NSString).doubleValue
                    let annotation = MKPointAnnotation()
                    annotation.title = row[0]
                    annotation.subtitle = row[4]
                    annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                self.mapView.addAnnotation(annotation)
            }
        }
        
    }
    
    // MARK: Location Functions
    
    let locationManager = CLLocationManager()
    let context = (UIApplication.shared.delegate as!
        AppDelegate).persistentContainer.viewContext
    let regionInMeters: Double = 10000
    let houstonCenter = CLLocation(latitude: 29.7528, longitude: -95.3652)

    override func viewDidLoad() {
        super.viewDidLoad()
        let data = openCSV(fileName: "TabSeperatedHoustonSmallBusinesses", fileType: "tsv")
        self.csvRows = csv(data: data!)
//        print("Second Row:", csvRows[1])
//        print("Value at 1,5: ", csvRows[1][5])
        checkLocationServices()
        openInMapsButton.isHidden = true
        openInMapsButton.layer.cornerRadius = 20
        copySiteButton.isHidden = true
        copySiteButton.layer.cornerRadius = 20
        textBox.isHidden = true
        textBox.layer.cornerRadius = 20
        disclaimerBox.layer.cornerRadius = 20
        fadeOutDisclaimer()
        createBusinessSitesList()
        createBusinessAddressesList()
        createBusinessDescriptionsList()
//        openWebsiteButton.isHidden = true
//        openWebsiteButton.layer.cornerRadius = 20
        
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        print("centeredview")
        }

        
    }
    
    func houstonCheck() {
        if let location = locationManager.location {
            let houstonDistance = location.distance(from: houstonCenter);
            if houstonDistance > 40000 {
                let alert = UIAlertController(title: "This app currently only works in Houston", message: "Sorry, we're still working on making this app available around the country!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))

                self.present(alert, animated: true)
            }
        }
        
    }
    
    func fadeOutDisclaimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            UIView.animate(withDuration: 2) {
                self.disclaimerBox.alpha = 0.0
            }
        }
        
    }
    
    func buildAnnotations(rows: [[String]]) {
        var num = 0
        for row in rows {
            let lat = (row[5] as NSString).doubleValue
            let long = (row[6] as NSString).doubleValue
                let annotation = MKPointAnnotation()
                annotation.title = row[0]
//                annotation.subtitle = row[4]
                annotation.subtitle = String(num)
                annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                num = num + 1
            

            
            mapView.addAnnotation(annotation)
        }
        
    }
    
//    func buildCells(rows: [[String]]) {
//        for row in rows {
//            let cell = UITableView.cellForRow(self: )
//        }
//    }
    
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
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            centerViewOnUserLocation()
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
            mapView.cameraZoomRange = MKMapView.CameraZoomRange(minCenterCoordinateDistance: 1000, maxCenterCoordinateDistance: 150000)
            houstonCheck()
//            let data = openCSV(fileName: "TabSeperatedHoustonSmallBusinesses", fileType: "tsv")
//            let csvRows = csv(data: data!)
//            print("Second Row:", csvRows[1])
//            print("Value at 1,5: ", csvRows[1][5])
            buildAnnotations(rows: csvRows)
            
        } else {
            let alert = UIAlertController(title: "Location Services Unavailable", message: "We are unable to access your location, please enable location services and try again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))

            self.present(alert, animated: true)
        }
    }
    
    func createBusinessSitesList() {
        for row in csvRows {
            businessSites.append(row[3])
        }
//        print(businessSites)
        
    }
    func createBusinessAddressesList() {
        for row in csvRows {
            businessAddresses.append(row[4])
        }
//        print(businessAddresses)
        
    }
    
    func createBusinessDescriptionsList() {
        for row in csvRows {
            businessDescriptions.append(row[2])
        }
//        print(businessDescriptions)
        
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Runs on location update
        guard let location = locations.last else {
            return }
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
//        mapView.setRegion(region, animated: true)
        print("change region")
    }
  
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
         checkLocationServices()
    }

}

// MARK: Annotation Functions

extension ViewController: MKMapViewDelegate {

    internal func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("calloutAccessoryControlTapped")
        
   }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
        //Display "Open in Maps" button
        openInMapsButton.isHidden = false
        copySiteButton.isHidden = false
        textBox.isHidden = false
//        openWebsiteButton.isHidden = false
        print("Annotation Tapped")
        self.selectedAnnotation = view.annotation as? MKPointAnnotation
        print(selectedAnnotation?.subtitle ?? "")
        let number = Int((selectedAnnotation?.subtitle)!)
        textBox.text = businessDescriptions[number!]
        if textBox.text == "" {
            textBox.text = "Unfortunately this business did not provide the Small Business Administration with a description of their services."
        }
        
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView){
        //Hide "Open in Maps" button
        openInMapsButton.isHidden = true
        copySiteButton.isHidden = true
        textBox.isHidden = true
//        openWebsiteButton.isHidden = true
        print("Map Tapped")
    }
}
