import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    let referenceImages: Set<ARReferenceImage>
    var onImageDetected: ((ARImageAnchor) -> Void)?
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // First assign the coordinator
        arView.session.delegate = context.coordinator
        
        // Then configure and run the session
        let config = ARWorldTrackingConfiguration()
        config.detectionImages = referenceImages
        config.maximumNumberOfTrackedImages = 1
        
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                if let imageAnchor = anchor as? ARImageAnchor {
                    DispatchQueue.main.async {
                        self.parent.onImageDetected?(imageAnchor)
                    }
                    
                    // Optional: pause detection after finding an image
                    let config = session.configuration as? ARWorldTrackingConfiguration
                    config?.detectionImages = nil
                    session.run(config!, options: [])
                }
            }
        }
    }
}