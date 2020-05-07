//
//  EarthquakesViewController.swift
//  Quakes
//
//  Created by Paul Solt on 10/3/19.
//  Copyright © 2019 Lambda, Inc. All rights reserved.
//

import UIKit
import MapKit

class EarthquakesViewController: UIViewController {

    let quakeFetcher = QuakeFetcher()

	// NOTE: You need to import MapKit to link to MKMapView
	@IBOutlet var mapView: MKMapView!
	
	override func viewDidLoad() {
		super.viewDidLoad()

        mapView.delegate = self
        // MKMarkerAnnotationView like a table view cell
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "QuakeView")

        quakeFetcher.fetchQuakes { (quakes, error) in
            if let error = error {
                print("Error fetching quakes: \(error)")
            }

            guard let quakes = quakes else { return }

            print("Quakes: \(quakes.count)")

            DispatchQueue.main.async {
                self.mapView.addAnnotations(quakes)

                guard let quake = quakes.first else { return }

                let span = MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
                let region = MKCoordinateRegion(center: quake.coordinate, span: span)
                self.mapView.setRegion(region, animated: true)

                // Future: can call a function to do all this work
            }
        }
	}
}

extension EarthquakesViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let quake = annotation as? Quake else {
            fatalError("Only quakes are supported")
        }

        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "QuakeView", for: annotation) as? MKMarkerAnnotationView else {
            fatalError("Missing a registered view")
        }

        annotationView.glyphImage = UIImage(named: "QuakeIcon")
        if let mag = quake.magnitude {
            if mag >= 5.0 {
                annotationView.markerTintColor = .red
            } else if mag >= 3.0 && mag < 5.0 {
                annotationView.markerTintColor = .orange
            } else {
                annotationView.markerTintColor = .yellow
            }
        } else {
            annotationView.markerTintColor = .white
        }

        return annotationView
    }
}
