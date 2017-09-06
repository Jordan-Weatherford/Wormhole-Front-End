/*Copyright (c) 2016, Andrew Walz.

Redistribution and use in source and binary forms, with or without modification,are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */

import UIKit
import Alamofire
import MapKit
import CoreLocation



class PhotoViewController: UIViewController, CLLocationManagerDelegate {
    var locationManager:CLLocationManager?
    var currentLocation:CLLocation?
    var altitude:Double?
    var longitude:Double?
    var latitude:Double?
    var encodedImage:String?
    var activityIndicator:UIActivityIndicatorView?
    var serverAddress:String = "http://52.14.243.255"


	override var prefersStatusBarHidden: Bool {
		return true
	}

	private var backgroundImage: UIImage

	init(image: UIImage) {
		self.backgroundImage = image
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor.gray
		let backgroundImageView = UIImageView(frame: view.frame)
		backgroundImageView.contentMode = UIViewContentMode.scaleAspectFit
		backgroundImageView.image = backgroundImage
		view.addSubview(backgroundImageView)
        let screenWidth = UIScreen.main.bounds.width
        
//      activity indicator setup
        activityIndicator = UIActivityIndicatorView()
        activityIndicator?.scale(factor: 2.0)
        activityIndicator?.center = self.view.center
        activityIndicator?.isHidden = true
        view.addSubview(activityIndicator!)
        
		
//      cancel button
        let cancelButton = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: 30.0, height: 30.0))
		cancelButton.setImage(#imageLiteral(resourceName: "cancel"), for: UIControlState())
		cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
		view.addSubview(cancelButton)
	
//      custom save button
        let saveButton = UIButton(frame: CGRect(x: screenWidth - 40.0, y: 10.0, width: 30.0, height: 30.0))
        saveButton.setImage(#imageLiteral(resourceName: "save"), for: UIControlState())
        saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        view.addSubview(saveButton)
        
        
//      get user location code
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.startUpdatingLocation()
        locationManager?.requestWhenInUseAuthorization()
    }
    
//      get user location code
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager?.stopUpdatingLocation()
        currentLocation = locations[0]
        
        altitude = currentLocation!.altitude
        longitude = currentLocation!.coordinate.longitude
        latitude = currentLocation!.coordinate.latitude
    
    
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
    

	func cancel() {
		dismiss(animated: true, completion: nil)
	}
    
//
//  send image with data to server
    func save() {
        activityIndicator?.startAnimating()
        activityIndicator?.isHidden = false
        let image = UIImageJPEGRepresentation(backgroundImage, 0.1)
        encodedImage = image?.base64EncodedString()
        
        let parameters = [
            "altitude" : altitude!,
            "longitude" : longitude!,
            "latitude" : latitude!,
            "encodedImage" : encodedImage!,
            "username" : UserDefaults.standard.string(forKey: "username") ?? "user not found"
        ] as [String : Any]
        
        
        
        Alamofire.request("\(serverAddress)/photos", method: .post, parameters: parameters).response { response in
            print("photo uploaded")
            self.dismiss(animated: true, completion: nil)
        }
    }
}
