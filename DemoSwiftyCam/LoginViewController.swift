//
//  LoginViewController.swift
//  DemoSwiftyCam
//
//  Created by Jordan Russell Weatherford on 6/20/17.
//  Copyright © 2017 Cappsule. All rights reserved.
//
import Alamofire
import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var pwConfirmField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    
    var serverAddress:String = "http://52.14.243.255"


    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.text = ""
//      hides keyboard when clicking outside of keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        createButton.layer.cornerRadius = 10
        loginButton.layer.cornerRadius = 10

     }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pwConfirmField.isHidden = true
        usernameField.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
//      if user remembered, segue to camera view
        
        if let user = UserDefaults.standard.object(forKey: "username") {
            performSegue(withIdentifier: "CameraViewSegue", sender: user)
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }

    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
//      if email or password fields are missing, return with error
        if ((emailField.text?.characters.count)! < 2 || (passwordField.text?.characters.count)! < 2) {
            self.errorLabel.text = "missing fields!"
            return
        }
        
        var parameters = [
            "email" : emailField.text,
            "password" : passwordField.text
        ] as! [String : String]

//      create button pressed
        if (self.loginButton.titleLabel?.text! == "Create!") {
            parameters["username"] = usernameField.text
            parameters["pwConfirm"] = pwConfirmField.text
            
//          if passwords don't match, return with error
            if (parameters["password"] != parameters["pwConfirm"]) {
                errorLabel.text = "passwords don't match!"
                return
            }
            
//          if username or pwconfirm fields are empty, return
            if ((usernameField.text?.characters.count)! < 2 || (pwConfirmField.text?.characters.count)! < 2) {
                errorLabel.text = "please fill out all fields!"
                return
            }
        }

//      make call to server with info, if a username is returned, login or creation was successful, segue to cameraView
        Alamofire.request("\(serverAddress)/login", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            if let JSON = response.result.value as? Dictionary<String, Any> {
                let server_message = JSON["server_message"] as! String
                if (JSON["username"] as? String) != nil {
                    print(server_message)
                    
//                  set user default to rememeber logged in user
                    UserDefaults.standard.set(JSON["username"], forKey: "username")
                    self.performSegue(withIdentifier: "CameraViewSegue", sender: nil)
                } else {
                    print(server_message)
                }
            }
        }
    }
    

    
    
    @IBAction func createButtonPressed(_ sender: UIButton) {
        if self.pwConfirmField.isHidden {
            pwConfirmField.isHidden = false
            usernameField.isHidden = false
            loginButton.setTitle("Create!", for: .normal)
        } else {
            pwConfirmField.isHidden = true
            usernameField.isHidden = true
            loginButton.setTitle("Login", for: .normal)
        }
    }
}




// extending Bool class to accept Integer for initializer to help parse JSON on login
extension Bool
{
    init(_ intValue: Int)
    {
        switch intValue
        {
        case 0:
            self.init(false)
        default:
            self.init(true)
        }
    }
}
