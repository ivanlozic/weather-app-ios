import UIKit

class HistoryCell: UITableViewCell {
    static let reuseID = "HistoryCell"
    
    private let containerView = UIView()
    private let cityLabel = UILabel()
    private let dateLabel = UILabel()
    private let tempLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        selectionStyle = .none
        backgroundColor = .clear
        
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = 16
        
        cityLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        cityLabel.numberOfLines = 0
        
        dateLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        dateLabel.textColor = .secondaryLabel
        dateLabel.numberOfLines = 0
        
        tempLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        tempLabel.textAlignment = .right
        tempLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        [cityLabel, dateLabel, tempLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
        
        contentView.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            cityLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            cityLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            cityLabel.trailingAnchor.constraint(equalTo: tempLabel.leadingAnchor, constant: -padding),
            
            dateLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding),
            dateLabel.trailingAnchor.constraint(equalTo: tempLabel.leadingAnchor, constant: -padding),
            
            tempLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            tempLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            tempLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 90)
        ])
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
