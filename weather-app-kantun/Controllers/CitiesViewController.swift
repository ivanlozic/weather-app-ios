import UIKit
import CoreLocation

// MARK: - CitiesTableConstants

private enum CitiesConstants {
    static let buttonHeight: CGFloat = 50
    static let buttonWidth: CGFloat = 200
    static let cornerRadius: CGFloat = 12
    static let buttonBottomMargin: CGFloat = 30
    static let cellHeight: CGFloat = 70
    static let cityCellIdentifier = "CityTableViewCell"
}

// MARK: - CitiesTableViewController

class CitiesViewController: UIViewController,UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var citiesTableView: UITableView!
    @IBOutlet weak var currentLocationButton: UIButton!
    // MARK: - Properties
    
     private let cities = [
        ("Rijeka", 45.3271, 14.4422),
        ("Zagreb", 45.8150, 15.9819),
        ("Split", 43.5081, 16.4402),
        ("New York", 40.7128, -74.0060)
    ]
    
    private var isUsingCurrentLocation = false
    private let locationManager = CLLocationManager()
    
    private var selectedCity: String?
    private var selectedLatitude: Double?
    private var selectedLongitude: Double?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Weather Forecast"
        setupTableView()
        setupLocationManager()
    }
    
    // MARK: - UI Setup

    private func setupTableView() {
        citiesTableView.delegate = self
        citiesTableView.dataSource = self
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self 
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Actions
    
    @IBAction func handleLocationButtonTap(_ sender: Any) {
        let status: CLAuthorizationStatus
        if #available(iOS 14, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            showLocationPermissionDeniedAlert()
        @unknown default:
            break
        }
    }
    
    private func showLocationPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "Location Permission Denied",
            message: "Please enable location access in Settings to use this feature.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showDetail",
              let detailVC = segue.destination as? WeatherDetailsViewController else { return }

        if isUsingCurrentLocation {
            detailVC.city = selectedCity
            detailVC.latitude = selectedLatitude
            detailVC.longitude = selectedLongitude
        } else if let indexPath = citiesTableView.indexPathForSelectedRow {
            let (city, lat, lon) = cities[indexPath.row]
            detailVC.city = city
            detailVC.latitude = lat
            detailVC.longitude = lon
        }
    }

}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension CitiesViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CitiesConstants.cityCellIdentifier, for: indexPath) as? CityTableViewCell else {
            fatalError("Could not dequeue CityTableViewCell")
        }
        
        let (city, _, _) = cities[indexPath.row]
        cell.configure(with: city)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CitiesConstants.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let (city, lat, lon) = cities[indexPath.row]
        selectedCity = city
        selectedLatitude = lat
        selectedLongitude = lon
        isUsingCurrentLocation = false
    }

}

// MARK: - CLLocationManagerDelegate

extension CitiesViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            guard let self = self, let city = placemarks?.first?.locality else { return }
            
            self.selectedCity = city
            self.selectedLatitude = location.coordinate.latitude
            self.selectedLongitude = location.coordinate.longitude
            self.isUsingCurrentLocation = true
            self.performSegue(withIdentifier: "showDetail", sender: self)
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
}
