import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "weather_app_kantun")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
    
     var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveForecast(city: String, temperature: Double, date: Date) {
        let forecast = Forecast(context: context)
        forecast.cityName = city
        forecast.temperature = temperature
        forecast.date = date
        
        saveContext()
    }
    
    static func forecastFetchRequest() -> NSFetchRequest<Forecast> {
         let fetchRequest: NSFetchRequest<Forecast> = Forecast.fetchRequest()
         fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
         return fetchRequest
     }

    func deleteForecast(_ forecast: Forecast) {
        context.delete(forecast)
        saveContext()
    }
    
    private func saveContext() {
        if context.hasChanges {
            try? context.save()
        }
    }
}
