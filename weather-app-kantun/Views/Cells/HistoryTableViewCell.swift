import UIKit

class HistoryCell: UITableViewCell {
    static let reuseID = "HistoryCell"

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    private func configure() {
        selectionStyle = .none
        backgroundColor = .clear
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
    }

    func configure(with forecast: Forecast) {
        cityLabel.text = forecast.cityName

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        if let date = forecast.date {
            dateLabel.text = dateFormatter.string(from: date)
        } else {
            dateLabel.text = "N/A"
        }

        tempLabel.text = String(format: "%.2f°C", forecast.temperature)
    }
}
