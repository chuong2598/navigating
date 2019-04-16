//
//  DirectionPanelViewController.swift
//  newNavigatingFull
//
//  Created by Nguyen Hoang Chuong on 4/10/19.
//  Copyright © 2019 Nguyen Hoang Chuong. All rights reserved.
//

import UIKit
import MapKit

class DirectionPanelViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate{
    
    @IBOutlet weak var destinationLabel: UILabel!
    
    @IBOutlet weak var carBtn: UIButton!
    
    @IBOutlet weak var walkBtn: UIButton!
    
    @IBOutlet weak var directionTableView: UITableView!
    
    var mapView: MKMapView?
    
    var handleMapSearchDelegate:GetDirection? = nil
    
    var color: [UIColor] = [UIColor(red: 50/255, green: 138/255, blue: 239/255, alpha: 1.0), .orange, .green]
    
    var routes: [MKRoute] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        directionTableView.delegate = self
        directionTableView.dataSource = self
        destinationLabel.text = "To " + ViewController.selectedPin!.name!
        ViewController.searchVC.searchBar.text = ""
        ViewController.fpc.move(to: .half, animated: true)
    }
    @IBAction func tapExitDirection(_ sender: Any) {
        mapView!.removeOverlays(mapView!.overlays)
        mapView!.removeAnnotations(mapView!.annotations)
        ViewController.fpc.contentViewController = ViewController.searchVC
    }
    
    @IBAction func tapCarBtn(_ sender: Any) {
        mapView!.removeOverlays(mapView!.overlays)
        handleMapSearchDelegate?.getDirection(destinationPlaceMark: ViewController.selectedPin!, transportType: .automobile)
    }
    
    @IBAction func tapWalkBtn(_ sender: Any) {
        mapView!.removeOverlays(mapView!.overlays)
        handleMapSearchDelegate?.getDirection(destinationPlaceMark: ViewController.selectedPin!, transportType: .walking)
        ViewController.fpc.move(to: .half, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "direction", for: indexPath) as! DirectionTableCell
        cell.directionName.text = routes[indexPath.row].name
        cell.directionButton.backgroundColor = color[indexPath.row]
        cell.directionDistance.text = "Distance: " + String(Int(routes[indexPath.row].distance)) + "m"
        cell.directionTime.text = "Time: " + String(Int(ceil(routes[indexPath.row].expectedTravelTime/60))) + " minutes"
        cell.route = routes[indexPath.row]

        cell.overlay = mapView!.overlays[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        ViewController.overlayColor = color[indexPath.row]
        self.mapView!.addOverlay(routes[indexPath.row].polyline, level: .aboveRoads)
        ViewController.fpc.move(to: .tip, animated: true)
        let rekt = routes[indexPath.row].polyline.boundingMapRect
        self.mapView!.setRegion(MKCoordinateRegion(rekt), animated: true)
        print(self.mapView!.overlays.count)
    }
}


