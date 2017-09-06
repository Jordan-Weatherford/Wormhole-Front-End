import MapKit




    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "CustomPinView")
        annotationView?.image = UIImage(named: "elephant.jpg")
        annotationView?.annotation = annotation
        print("mapview function")
    
        return annotationView
    }
