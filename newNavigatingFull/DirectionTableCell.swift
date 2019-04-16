//
//  Cell.swift
//  newNavigatingFull
//
//  Created by Nguyen Hoang Chuong on 4/10/19.
//  Copyright © 2019 Nguyen Hoang Chuong. All rights reserved.
//

import UIKit
import MapKit

class DirectionTableCell: UITableViewCell {
    
    @IBOutlet weak var directionButton: UIButton!
    
    @IBOutlet weak var directionName: UILabel!
    
    @IBOutlet weak var directionDistance: UILabel!
    
    @IBOutlet weak var directionTime: UILabel!
    
    var route: MKRoute?
    
    var overlay: MKOverlay?
    
    @IBAction func tap(_ sender: UIButton) {
        ViewController.chosenRoute = route
        ViewController.fpc.contentViewController = ViewController.inDirectionVc
        ViewController.fpc.move(to: .half, animated: true)
//        ViewController.inDirectionVc.route = self.route
        ViewController.inDirectionVc.directionName.text = route!.name
        ViewController.inDirectionVc.directionTime.text = String(route!.expectedTravelTime)
//        ViewController.inDirectionVc.chosenOverlay = overlay
    }
    /*
     @IBOutlet weak var testView: UIView!
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
