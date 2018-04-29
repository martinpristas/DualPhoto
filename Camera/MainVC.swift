//
//  MainVC.swift
//  Camera
//
//  Created by Martin Pristas on 25.4.18.
//  Copyright © 2018 Martin Pristas. All rights reserved.
//

import UIKit

class MainVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let titles : [String] = [
        "Camera",
        "Tsukuba"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        CIFilter.registerName("DisparityComputeFilterLR",
                              constructor: FilterVendor(),
                              classAttributes: [kCIAttributeFilterName: "DisparityComputeFilterLR"])
        
        CIFilter.registerName("DisparityComputeFilterRL",
                              constructor: FilterVendor(),
                              classAttributes: [kCIAttributeFilterName: "DisparityComputeFilterRL"])
        CIFilter.registerName("OcclusionFilter",
                              constructor: FilterVendor(),
                              classAttributes: [kCIAttributeFilterName: "OcclusionFilter"])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  

}

extension MainVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Default") as! MainCell
        cell.controlLabel.text = titles[indexPath.row]
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            let nextVC = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            nextVC.loadView()
            present(nextVC, animated: true, completion: nil)
        }
        
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
        nextVC.loadView()
        nextVC.leftImageView.image = #imageLiteral(resourceName: "leftTsukuba")
        nextVC.rightImageView.image = #imageLiteral(resourceName: "rightTsukuba")
        nextVC.trueDisparityImageView.image = #imageLiteral(resourceName: "trueTsukuba")
        present(nextVC, animated: true, completion: nil)
        
        
    }
}
