import SwiftUI

@main
struct MyApp: App {
    let persistence = Persistence2.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
        }
    }
}
