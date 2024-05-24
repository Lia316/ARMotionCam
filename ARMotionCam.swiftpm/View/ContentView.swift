import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext    
    @State private var path: [ViewType] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            Button("guide", systemImage: "camera") {
                path.append(.guide)
            }
            Button("practice", systemImage: "camera") {
                path.append(.practice)
            }
            .navigationDestination(for: ViewType.self) { viewType in
                switch viewType {
                case .guide: ARGuideCameraView()
                        .environment(\.managedObjectContext, viewContext)
                        .environmentObject(RecordingInfo())
                case .practice: VideoListView()
                        .environment(\.managedObjectContext, viewContext)
                }
            }
        }
    }
}

enum ViewType {
    case guide
    case practice
}
