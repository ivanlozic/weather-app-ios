import UIKit

class CityTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var locationIconImage: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    
    func configure(with cityName: String?) {
        containerView.layer.borderWidth = 0.5
        containerView.layer.borderColor = UIColor.systemGray4.cgColor
        cityLabel?.text = cityName ?? "Unknown City"
    }
}
