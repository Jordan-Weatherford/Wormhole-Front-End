//
//  MapViewController.swift
//  DemoSwiftyCam
//
//  Created by Jordan Russell Weatherford on 6/14/17.
//  Copyright © 2017 Cappsule. All rights reserved.
//


import UIKit
import MapKit
import CoreLocation
import Alamofire
import HDAugmentedReality






class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, ARDataSource {
    
    
    @IBOutlet weak var bigView: UIView!
    @IBOutlet weak var closeFullSizeImageButton: UIButton!
    @IBOutlet weak var thumbButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageCountLabel: UILabel!
    @IBOutlet weak var closeFullSizePhotoButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var fullSizeImageView: UIImageView!
    @IBOutlet weak var activityIndicator2: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    fileprivate var arViewController: ARViewController!
    
    var locationManager: CLLocationManager!
    
    var serverAddress:String = "http://52.14.243.255"
    var ARButton:UIButton = UIButton()
    var cancelButton: UIButton = UIButton()
    var album: [Dictionary<String, Any>] = []
    var annoInfo:Dictionary<String, Dictionary<String, Any>> = [:]
    var currentPage: Int = 0
//    var arAnnotations: [ARAnnotation] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
//        locationManager.requestWhenInUseAuthorization()
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        locationManager.requestWhenInUseAuthorization()
        
        mapView.delegate = self
        fullSizeImageView.isHidden = true
        activityIndicator2.isHidden = true
        activityIndicator2.scale(factor: 3.0)
        activityIndicator2.color = UIColor.white
        pageCountLabel.isHidden = true
        
        
        // hide buttons
        prevButton.isHidden = true
        nextButton.isHidden = true
        nextButton.layer.cornerRadius = 3
        prevButton.layer.cornerRadius = 3
        thumbButton.isHidden = true
        nextButton.isHidden = true
        closeFullSizeImageButton.isHidden = true
        
        
//      fonts
        usernameLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 45)
        pageCountLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 20)
        
//      augmented reality view button
        let screenWidth = UIScreen.main.bounds.width
        ARButton = UIButton(frame: CGRect(x: screenWidth - 65.0, y: 20.0, width: 60.0, height: 40.0))
        ARButton.setImage(#imageLiteral(resourceName: "3d"), for: UIControlState())
        ARButton.addTarget(self, action: #selector(showARView), for: .touchUpInside)
        ARButton.isHidden = true
        view.addSubview(ARButton)
        

//      exit to main screen button
        cancelButton = UIButton(frame: CGRect(x: 10.0, y: 25.0, width: 30.0, height: 30.0))
        cancelButton.setImage(#imageLiteral(resourceName: "cancel"), for: UIControlState())
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        
//      call pin request function from server
        getPinsFromServer()
        
//      get current location and pin to map
        getCurrentLocation()
        
     
    }
    
    
//  receive annotation data from server, loop through annotation data, create annotation and add to map on each loop
    func getPinsFromServer(){
        let parameters = [
            "latitude" : locationManager.location!.coordinate.latitude,
            "longitude" : locationManager.location!.coordinate.longitude,
            ] as [String : Double]
        print("b")
//        locationManager.stopUpdatingLocation()
        
        Alamofire.request("\(serverAddress)/getPins", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            if let JSON = response.result.value as? Dictionary<String, Dictionary<String, Any>>{
                print("a")
                print(JSON)
                self.annoInfo = JSON
                
                for (key, value) in self.annoInfo {
                    print("c")
                    let lat = value["latitude"] as? CLLocationDegrees
                    let long = value["longitude"] as? CLLocationDegrees
                    let photo_id = key 
                    let username = value["username"] as? String
                    
                    var loc: CLLocationCoordinate2D?
                    
                    if lat != nil && long != nil {
                        loc = CLLocationCoordinate2DMake(lat!, long!)
                        print("d")
                    } else {
                        print("failed response")
                        return
                    }
                    let annotation = MKPointAnnotation()
                    
//                  instantiate and add map annotations
                    annotation.coordinate = loc!
                    annotation.subtitle = photo_id
                    
                    if (username != nil) {
                        annotation.title = username!
                    }
                    self.mapView.addAnnotation(annotation)

                    self.annoInfo[key]?["annotation"] = annotation
                }
                print(8)
                self.getARPhotos()
                print(9)
            } else {
                print("error! invalid response from 'get pins' request")
            }
        }
    }
    

    

    
//  get ar photos
    func getARPhotos(){
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        
        var pins = [String]()
        
        for (key, value) in self.annoInfo {
            let photo_id = key 
            let username = value["username"] as! String
            let lat = value["latitude"] as! CLLocationDegrees
            let long = value["longitude"] as! CLLocationDegrees
            let loc = CLLocation(latitude: lat, longitude: long)
            let arAnno = ARAnnotation(identifier: photo_id, title: username, location: loc) 
            
            
            self.annoInfo[photo_id]?["arAnnotation"] = arAnno
            pins.append(photo_id)
        }

        
        let parameters = [
            "pins" : pins,
            ] as [String : Array<String>]
        
        
        Alamofire.request("\(serverAddress)/getARPhotos", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            if let JSON = response.result.value as? Dictionary<String, Any> {
                for (key, value) in JSON {
                    let encodedImage = value as! String
                    let decodedImage = NSData(base64Encoded: encodedImage, options: NSData.Base64DecodingOptions(rawValue: 0))!
                    let image = UIImage(data: decodedImage as Data)!
                    
                    self.annoInfo[key]?["image"] = image
                }
            } else {
                print("error in response from ar photos call")
                self.dismiss(animated: false, completion: nil)
            }
            self.ARButton.isHidden = false
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleView = MKCircleRenderer(overlay: overlay)
        circleView.strokeColor = UIColor.green
        circleView.fillColor = UIColor.green
        
        circleView.alpha = 0.2
        
        return circleView
    }
//  get current location and add annotation to map
    func getCurrentLocation(){
//      instantiate location manager to grab current user location
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingHeading()
        
        //    ---------------
        let circle = MKCircle(center: (locationManager.location?.coordinate)!, radius: 500)
        mapView.add(circle)
        //    ---------------
        
//        mapView.add(circle)
        
 
//      get current coordinates
        let latitude = locationManager.location!.coordinate.latitude
        let longtitude = locationManager.location!.coordinate.longitude

        
//      set map center and zoom level
        let span = MKCoordinateSpanMake(0.015, 0.015)
        let location = CLLocationCoordinate2DMake(latitude, longtitude)
        let region = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: true)
        
        
//      show user location on mapview
        mapView.showsUserLocation = true
    }
    
    
//  exits to camera view from map view
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
//  show AR button pressed
    func showARView() {
        // Check if device has hardware needed for augmented reality
        if let error = ARViewController.isAllHardwareAvailable(), !Platform.isSimulator
        {
            let message = error.userInfo["description"] as? String
            let alertView = UIAlertView(title: "Error", message: message, delegate: nil, cancelButtonTitle: "Close")
            alertView.show()
            return
        }
        
        // Present ARViewController
        let arViewController = ARViewController()
        //arViewController.presenter = TestARPresenter(arViewController: arViewController)  // Always set custom presenter first
        arViewController.dataSource = self
        // Vertical offset by distance
        arViewController.presenter.distanceOffsetMode = .manual
        arViewController.presenter.distanceOffsetMultiplier = 0.1   // Pixels per meter
        arViewController.presenter.distanceOffsetMinThreshold = 500 // Doesn't raise annotations that are nearer than this
        // Filtering for performance
        arViewController.presenter.maxDistance = 3000               // Don't show annotations if they are farther than this
        arViewController.presenter.maxVisibleAnnotations = 100      // Max number of annotations on the screen
        // Stacking
        arViewController.presenter.verticalStackingEnabled = true
        // Location precision
        arViewController.trackingManager.userDistanceFilter = 15
        arViewController.trackingManager.reloadDistanceFilter = 50
        // Ui
        arViewController.uiOptions.closeButtonEnabled = true
        
        // Interface orientation
        arViewController.interfaceOrientationMask = .all
        
        var arAnnotations: [ARAnnotation] = []
        
        for (_, value) in self.annoInfo {
            arAnnotations.append(value["arAnnotation"] as! ARAnnotation)
        }
        
        arViewController.setAnnotations(arAnnotations)
        self.present(arViewController, animated: false, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let amountToRotate = CGFloat(newHeading.magneticHeading.degreesToRadians)
        userAnnoView.transform = CGAffineTransform(rotationAngle: amountToRotate)
    }
    
    
    var userAnnoView: MKAnnotationView!
//  annotation view method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//      custom user annotation view
        if (annotation is MKUserLocation) {
            userAnnoView = MKAnnotationView()
            let image = #imageLiteral(resourceName: "avatar")
            let size = CGSize(width: image.size.width / 10, height: image.size.height / 10)
            UIGraphicsBeginImageContext(size)
            let rect = CGRect(origin: .zero, size: size)
            image.draw(in: rect)
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            userAnnoView.image = resizedImage
            
            return userAnnoView
        }

        let reuseId = "mapPins"
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        

        anView?.annotation = annotation
        anView?.canShowCallout = false
        
        let photo_id = annotation.subtitle!
        let pages = self.annoInfo[photo_id!]?["pages"] as! NSArray
        
        if (pages.count > 0) {
            anView?.image = UIImage(named: "album")
            anView?.centerOffset = CGPoint(x: -27, y: -36)
            
            return anView
        } else {
            return nil
        }
    }
    
    
    
//  protocol method that assigns arview to arAnnotation
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
//      instantiate new AR ANNO view
        let arAnnoView = arAnnotationView()
        let photo_key = viewForAnnotation.identifier!
        let pages = self.annoInfo[photo_key]?["pages"] as! NSArray
        let image = self.annoInfo[photo_key]?["image"]
        
        arAnnoView.photo_key = photo_key
        
        arAnnoView.annotation = viewForAnnotation
        arAnnoView.image = image as? UIImage
        arAnnoView.username = self.annoInfo[photo_key]?["username"] as? String
        arAnnoView.likes = self.annoInfo[photo_key]?["likes"] as? Int
        arAnnoView.pages = pages
        
        
        if (pages.count > 0) {
            arAnnoView.background = #imageLiteral(resourceName: "album_cover")
            arAnnoView.viewSize = CGRect(x: 0, y: 0, width: 265, height: 366)
            arAnnoView.imageFrame = CGRect(x: 45, y: 43, width: 172, height: 252)
            arAnnoView.like_thumb_rect = CGRect(x: 210, y: 303, width: 20, height: 20)
            arAnnoView.like_count_rect = CGRect(x: 195, y: 303, width: 70, height: 25)
            arAnnoView.album_title_rect = CGRect(x: 40, y: 288, width: 150, height: 50)
        } else {
            
            
            print(22)
            
            arAnnoView.background = #imageLiteral(resourceName: "polaroid")
            
            arAnnoView.viewSize = CGRect(x: 0, y: 0, width: 203, height: 340)
            arAnnoView.imageFrame = CGRect(x: 16, y: 29, width: 173, height: 258)
            arAnnoView.like_thumb_rect = CGRect(x: 175, y: 303, width: 20, height: 20)
            arAnnoView.like_count_rect = CGRect(x: 160, y: 303, width: 70, height: 25)
            arAnnoView.album_title_rect = CGRect(x: 15, y: 284, width: 150, height: 50)
        }
        
        //      ad gesture
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action:#selector(photoTapped(sender:)))
        arAnnoView.addGestureRecognizer(gesture)
        
        
        
        
        return arAnnoView
    }
    
    func cropImage(image:UIImage, toRect rect:CGRect) -> UIImage{
        let imageRef:CGImage = image.cgImage!.cropping(to: rect)!
        let croppedImage:UIImage = UIImage(cgImage:imageRef)
        return croppedImage
    }
    
    
    func photoTapped(sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
        fullSizeImageView.backgroundColor = UIColor.black
        fullSizeImageView.isHidden = false
        activityIndicator2.startAnimating()
        activityIndicator2.isHidden = false
        ARButton.isHidden = true
        nextButton.isHidden = false
        cancelButton.isHidden = true
        
        
        
        if let viewTapped = sender.view as! arAnnotationView? {
            
            var pages = viewTapped.pages as! Array<String>
            pages.append(viewTapped.photo_key!)
            
            bottomView.isHidden = false
            usernameLabel.isHidden = true
            thumbButton.isHidden = true
            nextButton.isHidden = true
            prevButton.isHidden = true
            pageCountLabel.isHidden = true
            likesLabel.isHidden = true
            closeFullSizeImageButton.isHidden = false
            
            
            let parameters = [
                "keys" : pages
            ]
            
            Alamofire.request("\(serverAddress)/getFullSizePhotos", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON(completionHandler: { response in
                if var JSON = response.result.value as? [Dictionary<String, Any>] {
//                  decode images
                    for i in 0..<JSON.count {
                        let encodedImage = JSON[i]["image"] as! String
                        let decodedImage = NSData(base64Encoded: encodedImage, options: NSData.Base64DecodingOptions(rawValue: 0))!
                        let image = UIImage(data: decodedImage as Data)!
                        JSON[i]["image"] = image
                    }
                    self.album = JSON
                    self.showFullSizeImage()
                } else {
                    print("no response from server!")
                }
            })
        }
    }
        
    func updateUI() {
        usernameLabel.text = album[currentPage]["username"] as? String
        fullSizeImageView.image = album[currentPage]["image"] as? UIImage
        likesLabel.text = (album[currentPage]["likes"] as! String)
        pageCountLabel.text = String(describing: currentPage)
        
    }
    
    
    func showFullSizeImage() {
        updateUI()
        currentPage = 0
        fullSizeImageView.isHidden = false
        activityIndicator2.stopAnimating()
        activityIndicator2.isHidden = true
        thumbButton.isHidden = false
        likesLabel.isHidden = false
        usernameLabel.isHidden = false
        
        if album.count > 1 {
            pageCountLabel.text = "Cover Shot!"
            nextButton.isHidden = false
            bigView.layer.borderWidth = 4
        } else {
            pageCountLabel.text = "\(currentPage)"
            nextButton.isHidden = true
            bigView.layer.borderWidth = 0
        }
        pageCountLabel.isHidden = false
        
        let pink = UIColor(red: 100.0/255.0, green: 130.0/255.0, blue: 230.0/255.0, alpha: 1.0)
        bigView.layer.borderColor = pink.cgColor
        bottomView.isHidden = false
    }
    
    @IBAction func closeFullSizePhotoButtonPressed(_ sender: UIButton) {
        fullSizeImageView.isHidden = true
        fullSizeImageView.image = nil
        ARButton.isHidden = false
        pageCountLabel.isHidden = true
        prevButton.isHidden = true
        nextButton.isHidden = true
        bottomView.isHidden = true
        closeFullSizeImageButton.isHidden = true
        cancelButton.isHidden = false
        bigView.layer.borderWidth = 0
        
//        //      loop through ar annos and setAnnos
//        var arAnnotations: [ARAnnotation] = []
//
//        for (_, value) in self.annoInfo {
//            arAnnotations.append(value["arAnnotation"] as! ARAnnotation)
//        }
//
//        arViewController.setAnnotations(arAnnotations)
//        self.present(arViewController, animated: false, completion: nil)
        showARView()
    }
    
    
    
    @IBAction func prevButtonPressed(_ sender: UIButton) {
        if currentPage > 0 {
            currentPage -= 1
            
            updateUI()
            
            if currentPage == 0 {
                prevButton.isHidden = true
                pageCountLabel.text = "Cover!"
                bigView.layer.borderWidth = 4
            }
            
            if currentPage < album.count - 1 {
                nextButton.isHidden = false
            }
        }
    }
    
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if currentPage < album.count - 1 {
            prevButton.isHidden = false
            currentPage += 1
            updateUI()
            bigView.layer.borderWidth = 0
            
            if currentPage == album.count - 1 {
                nextButton.isHidden = true
            }
        }
    }    
    
    
    
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        guard let user = UserDefaults.standard.object(forKey: "username") else { return }
        let photo = self.album[currentPage]["photo_id"]
        
        let parameters = [
            "username": user,
            "photo_id": photo,
        ] as Dictionary<String, Any>
        
        Alamofire.request("\(serverAddress)/createLike", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON(completionHandler: { response in
            if let response = response.result.value as? Dictionary<String, Any> {
                if let result = response["result"] as? Bool {
                    if result == true {
                        
                        let likes = String(describing: response["likes"]!)
                        
//                      add like to 'album'
                        for i in 0..<self.album.count {
                            let pic_id = String(describing: self.album[i]["photo_id"])
                            if (pic_id == String(describing: response["photo_id"])) {
                                self.album[i]["likes"] = likes
                            }
                        }
                        self.likesLabel.text = likes
//                      check if need to refetch 'annoInfo'
                        
                    } else {
                        print(result)
                    }
                }
                
            } else {
                print("invalid response from server")
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
}


extension UIActivityIndicatorView {
    func scale(factor: CGFloat) {
        guard factor > 0.0 else { return }
        transform = CGAffineTransform(scaleX: factor, y: factor)
    }
}



extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
}








