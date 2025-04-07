import UIKit

class CityTableViewCell: UITableViewCell {
    static let identifier = "CityTableViewCell"
    
    @IBOutlet weak var locationIconImage: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    
    func configure(with cityName: String?) {
        cityLabel?.text = cityName ?? "Unknown City"
    
    }
}
