//
//  ViewController.swift
//  travelBook
//
//  Created by Doğukan Ahi on 13.07.2023.
//
import UIKit
import MapKit
import CoreLocation
import CoreData
class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var commentfield: UITextField!
    @IBOutlet weak var namefield: UITextField!
    @IBOutlet weak var mapKit: MKMapView!
    var locationManager = CLLocationManager()
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    var selectedTitle = ""
    var selectedTitleID : UUID?
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()

    override func viewDidLoad() {
        super.viewDidLoad()
        mapKit.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 2
        mapKit.addGestureRecognizer(gestureRecognizer)
        
        
        if selectedTitle != ""{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            let idString = selectedTitleID!.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let title = result.value(forKey: "title") as? String{
                            annotationTitle = title
                            if let subtitle = result.value(forKey: "subtitle") as? String{
                                annotationSubtitle = subtitle
                                if let latitude = result.value(forKey: "latitude") as? Double{
                                    annotationLatitude = latitude
                                    if let longitude = result.value(forKey: "longitude") as? Double{
                                        annotationLongitude = longitude
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotationTitle
                                        annotation.subtitle = annotationSubtitle
                                        let coordinates = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                        annotation.coordinate = coordinates
                                        namefield.text = annotationTitle
                                        commentfield.text = annotationSubtitle
                                        
                                        
                                    }
                                }
                            }
                            
                        }
                    }
                }
                
            }catch {
                print("Error occured!")
            }
            
        }
    }
        @objc func chooseLocation(gestureRecognizer:UILongPressGestureRecognizer){
            if gestureRecognizer.state == .began{
                let touchedPoint = gestureRecognizer.location(in: self.mapKit)
                let touchedCoordinates = self.mapKit.convert(touchedPoint, toCoordinateFrom: self.mapKit)
                let annotation = MKPointAnnotation()
                chosenLatitude = touchedCoordinates.latitude
                chosenLongitude = touchedCoordinates.longitude
                annotation.coordinate = touchedCoordinates
                annotation.title = namefield?.text
                annotation.subtitle = commentfield.text
                
                self.mapKit.addAnnotation(annotation)
            }
            
            
        }
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.latitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.030, longitudeDelta: 0.030)
            let region = MKCoordinateRegion(center: location, span: span)
            mapKit.setRegion(region, animated: true)
        }
        
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate =  UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        if namefield.text == ""{
            let alert = UIAlertController(title: "ERROR!", message: "Please enter location name", preferredStyle: .alert)
            self.present(alert,animated: true)
            let okButon = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default)
            alert.addAction(okButon)
            
        }
        else if commentfield.text == ""{
            let alert = UIAlertController(title: "ERROR!", message: "Please enter location comment", preferredStyle: .alert)
            self.present(alert,animated: true)
            let okButon = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default)
            alert.addAction(okButon)
        }
        else{
            
            
            newPlace.setValue(namefield?.text, forKey: "title")
            newPlace.setValue(commentfield.text, forKey: "subtitle")
            newPlace.setValue(chosenLongitude, forKey: "longitude")
            newPlace.setValue(chosenLatitude, forKey: "latitude")
            newPlace.setValue(UUID(), forKey: "id")
            
            do{
                try context.save()
                print("success")
            }catch{
                print("error")
            }
        }
    }
    
    
}


 
