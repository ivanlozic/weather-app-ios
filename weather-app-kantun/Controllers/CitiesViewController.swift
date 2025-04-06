import UIKit
import CoreLocation

// MARK: - CitiesTableConstants

private enum CitiesConstants {
    static let buttonHeight: CGFloat = 50
    static let buttonWidth: CGFloat = 200
    static let cornerRadius: CGFloat = 12
    static let buttonBottomMargin: CGFloat = 30
    static let cellHeight: CGFloat = 70
    static let cityCellIdentifier = "CityCell"
    static let navBarHeight: CGFloat = 44
}

// MARK: - CitiesTableViewController

class CitiesViewController: UITableViewController {
    
    // MARK: - Properties
    
    private let cities = [
        ("Rijeka", 45.3271, 14.4422),
        ("Zagreb", 45.8150, 15.9819),
        ("Split", 43.5081, 16.4402),
        ("New York", 40.7128, -74.0060)
    ]
    
    private let locationManager = CLLocationManager()
    private let locationButton = UIButton(type: .system)
    
    private var selectedCity: String?
    private var selectedLatitude: Double?
    private var selectedLongitude: Double?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        setupLocationButton()
        setupLocationManager()
    }
    
    // MARK: - UI Setup
    
    private func setupNavigationBar() {
        title = "Weather Forecast"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.frame.size.height = CitiesConstants.navBarHeight
        }
    }
    
    private func setupTableView() {
        tableView.register(ForecastTableViewCell.self, forCellReuseIdentifier: CitiesConstants.cityCellIdentifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGroupedBackground
    }
    
    private func setupLocationButton() {
        locationButton.setTitle("My Location", for: .normal)
        locationButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        locationButton.backgroundColor = .systemBlue
        locationButton.setTitleColor(.white, for: .normal)
        locationButton.layer.cornerRadius = CitiesConstants.cornerRadius
        locationButton.layer.shadowColor = UIColor.black.cgColor
        locationButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        locationButton.layer.shadowRadius = 4
        locationButton.layer.shadowOpacity = 0.1
        locationButton.addTarget(self, action: #selector(handleLocationButtonTap), for: .touchUpInside)
        
        view.addSubview(locationButton)
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            locationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            locationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -CitiesConstants.buttonBottomMargin),
            locationButton.widthAnchor.constraint(equalToConstant: CitiesConstants.buttonWidth),
            locationButton.heightAnchor.constraint(equalToConstant: CitiesConstants.buttonHeight)
        ])
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self 
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Actions
    
    @objc private func handleLocationButtonTap() {
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
        detailVC.city = selectedCity
        detailVC.latitude = selectedLatitude
        detailVC.longitude = selectedLongitude
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension CitiesViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CitiesConstants.cityCellIdentifier, for: indexPath) as! ForecastTableViewCell
        let (city, _, _) = cities[indexPath.row]
        cell.configure(with: city)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CitiesConstants.cellHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let (city, lat, lon) = cities[indexPath.row]
        selectedCity = city
        selectedLatitude = lat
        selectedLongitude = lon
        performSegue(withIdentifier: "showDetail", sender: self)
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
