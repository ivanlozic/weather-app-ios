import UIKit
import CoreData

class HistoryWeatherViewController: UITableViewController {
    
    private var fetchedResultsController: NSFetchedResultsController<Forecast>!
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No weather history yet."
        label.textColor = .secondaryLabel
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureTableView()
        configureEmptyState()
        setupFetchedResultsController()
        updateEmptyState()
    }

    private func configureViewController() {
        title = "Weather History"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isHidden = false
        view.backgroundColor = .systemBackground
    }
    
    private func configureTableView() {
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGroupedBackground
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100 
    }
    
    private func configureEmptyState() {
        tableView.backgroundView = emptyStateLabel
    }
    
    private func updateEmptyState() {
        let hasData = fetchedResultsController.fetchedObjects?.isEmpty == false
        emptyStateLabel.isHidden = hasData
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Forecast> = Forecast.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreDataManager.shared.context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            presentAlert(title: "Error", message: "Failed to load history: \(error.localizedDescription)")
        }
    }
    
    private func deleteForecast(_ forecast: Forecast) {
        CoreDataManager.shared.deleteForecast(forecast)
        updateEmptyState()
    }
    
    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension HistoryWeatherViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = fetchedResultsController.sections?[section].numberOfObjects ?? 0
        emptyStateLabel.isHidden = count > 0
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HistoryCell.reuseID, for: indexPath) as? HistoryCell else {
            return UITableViewCell()
        }

        let forecast = fetchedResultsController.object(at: indexPath)
        cell.configure(with: forecast)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            let forecast = self.fetchedResultsController.object(at: indexPath)
            self.deleteForecast(forecast)
            completion(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension HistoryWeatherViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? HistoryCell {
                let forecast = fetchedResultsController.object(at: indexPath)
                cell.configure(with: forecast)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                tableView.moveRow(at: indexPath, to: newIndexPath)
            }
        @unknown default:
            fatalError()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        updateEmptyState()
    }
}
