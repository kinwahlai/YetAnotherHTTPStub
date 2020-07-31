//
//  ViewController.swift
//  Example
//
//  Created by Darren Lai on 7/15/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var get: UIButton!
    @IBOutlet weak var post: UIButton!
    
    @IBOutlet weak var origin: UILabel!
    @IBOutlet weak var originValue: UILabel!
    
    @IBOutlet weak var url: UILabel!
    @IBOutlet weak var urlValue: UILabel!
    
    @IBOutlet weak var errorView: UITextView!
    
    let afService = ServiceUsingAlamofire()
    let moyaService = ServiceUsingMoya()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func callGETrequest(_ sender: Any) {
        afService.getRequest { [unowned self] (dict, error) in
            if let dict = dict {
                self.originValue.text = dict["origin"] as! String
                self.urlValue.text = dict["url"] as! String
                return
            }
            if let error = error {
                self.errorView.text = error.localizedDescription
            }
        }
    }
    
    @IBAction func callPOSTrequest(_ sender: Any) {
        afService.post(["uitest": "testing work"]) { [unowned self] (dict, error) in
            if let dict = dict {
                self.originValue.text = dict["origin"] as! String
                self.urlValue.text = dict["url"] as! String
                return
            }
            if let error = error {
                self.errorView.text = error.localizedDescription
            }
        }
    }
    
}

