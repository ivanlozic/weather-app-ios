import UIKit

class HistoryCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    private func configure() {
        containerView.layer.masksToBounds = true
        containerView.layer.borderWidth = 0.5
        containerView.layer.borderColor = UIColor.systemGray4.cgColor
    }

    func configure(with forecast: Forecast) {
        cityLabel.text = forecast.cityName
        dateLabel.text = formattedDate(from: forecast.date)
        tempLabel.text = String(format: "%.2f°C", forecast.temperature)
    }
    
    private func formattedDate(from date: Date?) -> String {
          guard let date = date else { return "N/A" }
          let formatter = DateFormatter()
          formatter.dateStyle = .medium
          formatter.timeStyle = .short
          
          return formatter.string(from: date)
      }
}
