import UIKit
import CoreData

@objcMembers
class AppDelegate: UIResponder, UIApplicationDelegate {
  var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "DressDiary")
    container.loadPersistentStores { _, error in
      if let error {
        fatalError("Unresolved Core Data error: \(error)")
      }
    }
    return container
  }()

    func application(_ application: UIApplication, 
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {true}
}
