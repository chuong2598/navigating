//
//  Copyright © 2018 Shin Yamamoto. All rights reserved.
//

import UIKit
import MapKit
import FloatingPanel

protocol GetDirection {
    func getDirection(destinationPlaceMark:MKPlacemark, transportType: MKDirectionsTransportType)
}

protocol GetRouteInstruction {
    func getRouteInstruction()
}


class ViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate, FloatingPanelControllerDelegate {
    static var fpc: FloatingPanelController!
    static var overlayColor: UIColor?
    static var selectedPin:MKPlacemark? = nil
    static var searchVC: SearchPanelViewController!
    static var directionVc: DirectionPanelViewController!
    static var inDirectionVc: InDirectionPanelViewController!
    static var chosenRoute: MKRoute?
    static var directionSteps: [String] = []
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    
    var headingImageView: UIImageView?
    
    var userHeading: CLLocationDirection?
    
    var cameraHeading: CLLocationDirection?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.showsScale = true
        mapView.showsPointsOfInterest = true
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if(CLLocationManager.locationServicesEnabled()){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            mapView.setUserTrackingMode(.follow, animated: true)
        }
        

        ViewController.fpc = FloatingPanelController()
        ViewController.fpc.delegate = self
        ViewController.fpc.surfaceView.backgroundColor = .clear
        ViewController.fpc.surfaceView.cornerRadius = 12.0
        ViewController.fpc.surfaceView.shadowHidden = false
        
        ViewController.searchVC = storyboard?.instantiateViewController(withIdentifier: "SearchPanelViewController") as? SearchPanelViewController
        ViewController.searchVC.handleMapSearchDelegate = self

        ViewController.directionVc = storyboard?.instantiateViewController(withIdentifier: "DirectionPanelViewController") as? DirectionPanelViewController
        ViewController.directionVc.handleMapSearchDelegate = self
        ViewController.directionVc.mapView = mapView
        
        ViewController.inDirectionVc = storyboard?.instantiateViewController(withIdentifier: "InDirectionPanelViewController") as? InDirectionPanelViewController
        ViewController.inDirectionVc.mapView = mapView
        ViewController.inDirectionVc.handleGetRouteInstruction = self
        
        ViewController.fpc.set(contentViewController: ViewController.searchVC)
        ViewController.fpc.track(scrollView: ViewController.searchVC.tableView)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //  Add FloatingPanel to a view with animation.
        ViewController.fpc.addPanel(toParent: self, animated: true)
        ViewController.searchVC.searchBar.delegate = self
        ViewController.searchVC.searchBar.text = ""
        locationManager.startUpdatingHeading()
    }
    
    @IBAction func currentPositionTap(_ sender: Any) {
        let sourceCoordinates = locationManager.location?.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: sourceCoordinates!, span: span)
        mapView.setRegion(region, animated: true)
//        mapView.setUserTrackingMode(.follow, animated: true)
    }
}


extension ViewController{
    func updateSearchResult(){
        if (ViewController.searchVC.searchBar.text!.count % 2 != 0){
            return
        }
        guard
            let mapView = mapView,
            let searchBarText = ViewController.searchVC.searchBar.text else {return }
        print(searchBarText)
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            ViewController.searchVC.matchingItems = response.mapItems
            print(ViewController.searchVC.matchingItems)
            ViewController.searchVC.tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        updateSearchResult()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearchResult()
    }
}

// floating panel set up
extension ViewController {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton  = false
        ViewController.fpc.move(to: .half, animated: true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        ViewController.searchVC.tableView.alpha = 1.0
        ViewController.fpc.move(to: .full, animated: true)
    }
    
    // MARK: FloatingPanelControllerDelegate
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        switch newCollection.verticalSizeClass {
        case .compact:
            ViewController.fpc.surfaceView.borderWidth = 1.0 / traitCollection.displayScale
            ViewController.fpc.surfaceView.borderColor = UIColor.black.withAlphaComponent(0.2)
            return SearchPanelLandscapeLayout()
        default:
            ViewController.fpc.surfaceView.borderWidth = 0.0
            ViewController.fpc.surfaceView.borderColor = nil
            return nil
        }
    }
    

    
    func floatingPanelDidMove(_ vc: FloatingPanelController) {
//        let y = vc.surfaceView.frame.origin.y
//        let tipY = vc.originYOfSurface(for: .tip)
//        if y > tipY - 44.0 {
//            let progress = max(0.0, min((tipY  - y) / 44.0, 1.0))
//            self.searchVC.tableView.alpha = progress
//        }
    }
    
    func floatingPanelWillBeginDragging(_ vc: FloatingPanelController) {
        print("begin drag")
        if vc.position == .full {
            if (ViewController.fpc.contentViewController == ViewController.searchVC){
                ViewController.searchVC.searchBar.showsCancelButton = false
                ViewController.searchVC.searchBar.resignFirstResponder()
            }
            else if(ViewController.fpc.contentViewController == ViewController.directionVc){
                // impletation
            }
        }
    }
    
    func floatingPanelDidEndDragging(_ vc: FloatingPanelController, withVelocity velocity: CGPoint, targetPosition: FloatingPanelPosition) {
        if targetPosition != .full {
        }
        
        print("end drag")
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: .allowUserInteraction,
                       animations: {
                        if (ViewController.fpc.contentViewController == ViewController.searchVC){
                            if targetPosition == .tip {
                                ViewController.searchVC.tableView.alpha = 0.0
                            } else {
                                ViewController.searchVC.tableView.alpha = 1.0
                            }
                        }
                        else if(ViewController.fpc.contentViewController == ViewController.directionVc){
                            // impletation
                        }
        }, completion: nil)
    }
}

extension ViewController: GetDirection {
    func getDirection(destinationPlaceMark:MKPlacemark, transportType: MKDirectionsTransportType){
        ViewController.searchVC.searchBar.endEditing(true)
        ViewController.fpc.move(to: .tip, animated: true)
        ViewController.searchVC.tableView.alpha = 0.0
        
        mapView.removeOverlays(mapView.overlays)
        ViewController.selectedPin = destinationPlaceMark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = destinationPlaceMark.coordinate
        annotation.title = destinationPlaceMark.name
        if let city = destinationPlaceMark.locality,
            let state = destinationPlaceMark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        
        let sourceCoordinates = locationManager.location?.coordinate
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinates!)
        //        let destPlacemark = MKPlacemark(coordinate: destCoordinates)
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destItem = MKMapItem(placemark: destinationPlaceMark)
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceItem
        directionRequest.destination = destItem
        directionRequest.transportType = transportType
        directionRequest.requestsAlternateRoutes = true
        //
        let direction = MKDirections(request: directionRequest)
        direction.calculate(completionHandler: {
            response, error in
            guard let response = response else{
                if let error = error{
                    print(error)
                }
                return
            }

            var routes = response.routes
            ViewController.directionVc.routes = routes
            ViewController.directionVc.directionTableView.reloadData()
            for i in stride(from: routes.count - 1, through: 0, by: -1){
                if(i > 2){ break}
                print(i)
                if(i == 0){
                    ViewController.overlayColor = UIColor(red: 50/255, green: 138/255, blue: 239/255, alpha: 1.0)
                }
                else if (i == 1){
                    ViewController.overlayColor = UIColor.orange
                }
                else if (i == 2){
                    ViewController.overlayColor = UIColor.green
                }
                
                self.mapView.addOverlay(routes[i].polyline, level: .aboveRoads)
                let rekt = routes[i].polyline.boundingMapRect
                if(i == 0){
                    self.mapView.setRegion(MKCoordinateRegion(rekt), animated: true)
                }
            }
        })
        
        ViewController.fpc.set(contentViewController: ViewController.directionVc)
        ViewController.fpc.track(scrollView: ViewController.directionVc.directionTableView)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)

        renderer.strokeColor = ViewController.overlayColor

        renderer.lineWidth = 5.0
        return renderer
    }
}

extension ViewController{
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        //        print("will")
        cameraHeading = mapView.camera.heading
        //        print("cameraHeading:  \(cameraHeading)")
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if(userHeading != nil && cameraHeading != mapView.camera.heading){
            var newHeading = userHeading! - mapView.camera.heading
            print(newHeading)
            print(userHeading!)
            print(mapView.camera.heading)
            updateHeadingRotation(heading : newHeading)
            cameraHeading = mapView.camera.heading
        }
    }
    
    
    
    
    func addHeadingView(toAnnotationView annotationView: MKAnnotationView) {
        if headingImageView == nil {
            let image = UIImage(named: "arrow.png")!
            headingImageView = UIImageView(image: image)
            headingImageView!.frame = CGRect(x: (annotationView.frame.size.width - image.size.width)/2, y: (annotationView.frame.size.height - image.size.height)/2, width: image.size.width, height: image.size.height)
            annotationView.insertSubview(headingImageView!, at: 0)
            headingImageView!.isHidden = false
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        if views.last?.annotation is MKUserLocation {
            addHeadingView(toAnnotationView: views.last!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if newHeading.headingAccuracy < 0 { return }
        let heading = (newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading)
        userHeading = heading
        updateHeadingRotation(heading: heading - mapView.camera.heading)
    }
    
    func updateHeadingRotation(heading: CLLocationDirection) {
        guard headingImageView != nil else {return}
        headingImageView!.isHidden = false
        let rotation = CGFloat((heading)/180 * Double.pi)
        headingImageView!.transform = CGAffineTransform(rotationAngle: rotation)
    }
}

extension ViewController:  GetRouteInstruction{
    func getRouteInstruction() {
        print("asdas")
        locationManager.stopUpdatingHeading()
        performSegue(withIdentifier: "stepsSegue", sender: nil)
        print("sadvdjksb")
    }
    
    
}


