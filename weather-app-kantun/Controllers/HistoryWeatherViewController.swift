import UIKit
import CoreData

class HistoryWeatherViewController: UITableViewController {
    
    @IBOutlet weak var emptyStateLabel: UILabel!
    
    private var fetchedResultsController: NSFetchedResultsController<Forecast>!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        updateEmptyState()
    }

    private func updateEmptyState() {
        let hasData = fetchedResultsController.fetchedObjects?.isEmpty == false
        emptyStateLabel.isHidden = hasData
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest = CoreDataManager.forecastFetchRequest()
        
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as? HistoryCell else {
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
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        updateEmptyState()
    }
}
