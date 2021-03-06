//
//  ListViewController.swift
//  On The Map
//
//  Created by Vinicius Carvalho on 12/09/2016.
//  Copyright © 2016 Vinicius Carvalho. All rights reserved.
//

import UIKit
import AudioToolbox

class ListViewController: UITableViewController {
    
    var appDelegate: AppDelegate!
    let studentSegueIdentifier = "ShowStudentDetail"
    var refreshCount = 0
    @IBOutlet weak var dimOutlet: UIView!
    @IBOutlet weak var activityIndOutlet: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBarHidden = false
        tableView.delegate = self
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        print("viewwillload")
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        tableView.delegate = self
        self.navigationController?.navigationBarHidden = false
        print("viewwillappear")
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellReuseIdentifier = "TableViewCell"
        let location = StudentModel.sharedInstance().studentLocation[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
        cell.textLabel!.text = location.firstName + " " + location.lastName
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return StudentModel.sharedInstance().studentLocation.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let location = StudentModel.sharedInstance().studentLocation[indexPath.row]
        let url = location.mediaURL
        
        if verifyUrl(url) == true {
            
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        } else if verifyUrl(url) == false {
            
            self.failAlertGeneral("Unable to open that URL", message: "Unfrt this item doesn't contain a valid URL", actionTitle: "Try another")
        }
    }
    
    override internal func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override internal func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            print("Shaked")
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            let failLogoutAlert = UIAlertController(title: "Wanna Logout?", message: "Just double checking, we'll miss you!", preferredStyle: UIAlertControllerStyle.Alert)
            failLogoutAlert.addAction(UIAlertAction(title: "Log Me Out", style: UIAlertActionStyle.Default, handler: { alertAction in self.logOut() }))
            failLogoutAlert.addAction(UIAlertAction(title: "Take Me Back!", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(failLogoutAlert, animated: true, completion: nil)
        }
    }

    func refresh(sender: AnyObject) {

        Client.sharedInstance().getStudentLocations() { (results, error) in

            if error != nil {

                let failDataAlert = UIAlertController(title: "Sorry", message: "There was a problem with retrieving Student Location data", preferredStyle: UIAlertControllerStyle.Alert)
                failDataAlert.addAction(UIAlertAction(title: "I'll Come Back Later", style: UIAlertActionStyle.Default, handler: nil))
                failDataAlert.addAction(UIAlertAction(title: "Leave Feedback", style: UIAlertActionStyle.Default, handler: { alertAction in
                    UIApplication.sharedApplication().openURL(NSURL(string : "mailto:mnienaber@google.com")!)
                    failDataAlert.dismissViewControllerAnimated(true, completion: nil)
                    self.presentViewController(failDataAlert, animated: true, completion: nil)
                }))

            } else {

                performUIUpdatesOnMain {

                    self.getStudentList()
                    self.tableView.reloadData()
                    print("refresh is \(results)")
                    
                }
            }
        } 
    }

    @IBAction func refreshButton(sender: AnyObject) {

        if Reachability.isConnectedToNetwork() == false {

            let failPostAlert = UIAlertController(title: "No Internet Connection", message: "Please check your connection and try again", preferredStyle: UIAlertControllerStyle.Alert)
            failPostAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(failPostAlert, animated: true, completion: nil)
        } else if Reachability.isConnectedToNetwork() == true {

            self.refresh(self)
        }
    }
    
    func getStudentList() {
        
        if StudentModel.sharedInstance().studentLocation.isEmpty == true {
            
            performUIUpdatesOnMain {

                self.refresh(self)
            }
        } else if StudentModel.sharedInstance().studentLocation.isEmpty == false {
            
            performUIUpdatesOnMain {
                
                for _ in StudentModel.sharedInstance().studentLocation {
                    
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            }
        }
    }

    @IBAction func logOutButton(sender: AnyObject) {
        
        failLogOutAlert()
    }
    
    func logOut() {
        
        self.appDelegate.accountKey = nil
        self.appDelegate.accountRegistered = nil
        self.appDelegate.sessionID = nil
        self.appDelegate.sessionExpiration = nil

        Client.sharedInstance().deleteSession() { (result, error) in

            if error != nil {

                self.failAlertGeneral("LogOut Unsuccessful", message: "Something went wrong, please try again", actionTitle: "OK")
            } else {

                performUIUpdatesOnMain {

                    print("logout success \(result)")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                }
            }
        }
    }

    func failAlertGeneral(title: String, message: String, actionTitle: String) {

        let failAlertGeneral = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        failAlertGeneral.addAction(UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(failAlertGeneral, animated: true, completion: nil)
    }

    func failLogOutAlert() {

        let failLogoutAlert = UIAlertController(title: "Wanna Logout?", message: "Just double checking, we'll miss you!", preferredStyle: UIAlertControllerStyle.Alert)
        failLogoutAlert.addAction(UIAlertAction(title: "Log Me Out", style: UIAlertActionStyle.Default, handler: { alertAction in self.logOut() }))
        failLogoutAlert.addAction(UIAlertAction(title: "Take Me Back!", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(failLogoutAlert, animated: true, completion: nil)
    }
}

extension ListViewController {
    
    override func verifyUrl(urlString: String?) -> Bool {

        if let urlString = urlString {
            
            if NSURL(string: urlString) != nil {
                
                return true
            }
        }
        return false
    }
}


