import MapKit

class CustomAnnotation: NSObject, MKAnnotation {

    var coordinate: CLLocationCoordinate2D
    var name: String!
    var date: String!
    var image: UIImage!
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    
}
