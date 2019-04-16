//
//  InDirectionPanelViewController.swift
//  newNavigatingFull
//
//  Created by Nguyen Hoang Chuong on 4/11/19.
//  Copyright © 2019 Nguyen Hoang Chuong. All rights reserved.
//

import UIKit
import MapKit

class InDirectionPanelViewController: UIViewController, MKMapViewDelegate {
//    var route: MKRoute? = nil
    var mapView: MKMapView?
    @IBOutlet weak var directionName: UILabel!
    @IBOutlet weak var directionTime: UILabel!
    var handleGetRouteInstruction: GetRouteInstruction? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("in direction")
        mapView!.removeOverlays(mapView!.overlays)
        ViewController.overlayColor = ViewController.directionVc.color[0]
        mapView!.addOverlay(ViewController.chosenRoute!.polyline, level: .aboveRoads)
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        print("in direction")
        mapView!.removeOverlays(mapView!.overlays)
        ViewController.overlayColor = ViewController.directionVc.color[0]
        mapView!.addOverlay(ViewController.chosenRoute!.polyline, level: .aboveRoads)
    }
    
    @IBAction func getRouteStep(_ sender: UIButton) {
        handleGetRouteInstruction!.getRouteInstruction()
    }
    
    
    @IBAction func exitTap(_ sender: Any) {
        ViewController.fpc.contentViewController = ViewController.searchVC
        ViewController.fpc.move(to: .half, animated: true)
        mapView!.removeOverlays(mapView!.overlays)
        mapView!.removeAnnotations(mapView!.annotations)
    }
    
//    @IBAction func getRouteInstruction(_ sender: Any) {
//        performSegue(withIdentifier: "instruction", sender: nil)
//    }
}
