//
//  ContentView.swift
//  ARGlasses
//
//  Created by Alexandra Popova on 28.08.2022.
//

import ARKit
import SwiftUI
import RealityKit

struct ContentView : View {
    
    var body: some View {
        return ARViewContainer().edgesIgnoringSafeArea(.all).onTapGesture {
            let circle = MeshResource.generateBox(size: 0.05, cornerRadius: 0.025)
            let box = MeshResource.generateBox(width: 0.05, height: 0.025, depth: 0.025)
            
            var typeOfGlasses = circle
            
            if ARViewContainer.counter {
                ARViewContainer.colorForMaterial = .red
            } else {
                ARViewContainer.colorForMaterial = .blue
                typeOfGlasses = box
            }
            
            let material = SimpleMaterial(color: ARViewContainer.colorForMaterial, isMetallic: true)
            for entity in [ARViewContainer.leftEntity, ARViewContainer.rightEntity] {
                entity.components[ModelComponent.self] = ModelComponent(mesh: typeOfGlasses, materials: [material])
            }
            ARViewContainer.counter.toggle()
        }
    }
    
    struct ARViewContainer: UIViewRepresentable {
        
        static let radians = 90.0 * Float.pi / 180.0
        static var counter = true
        static var colorForMaterial: UIColor!
        
        static let leftEntity = ARViewContainer.createSquareLenses(x: -0.035, y: 0.025, z: 0.06)
        static let rightEntity = ARViewContainer.createSquareLenses(x: 0.035, y: 0.025, z: 0.06)
        
        
        static func createSquareLenses(x: Float = 0,y: Float = 0, z:Float = 0) -> Entity {
            let box = MeshResource.generateBox(width: 0.05, height: 0.025, depth: 0.025)
            let material = SimpleMaterial(color: .blue, isMetallic: true)
            
            let boxEntity = ModelEntity(mesh: box, materials: [material])
            boxEntity.position = SIMD3(x, y, z)
            boxEntity.scale.x = 1.1
            boxEntity.scale.z = 0.01
            
            return boxEntity
        }
        
        
        static func createRoundLenses(x: Float = 0, y: Float = 0, z: Float = 0) -> Entity {
            let circle = MeshResource.generateBox(size: 0.05, cornerRadius: 0.025)
            let material = SimpleMaterial(color: .blue, isMetallic: true)
            
            let circleEntity = ModelEntity(mesh: circle, materials: [material])
            circleEntity.position = SIMD3(x, y, z)
            circleEntity.scale.x = 1.1
            circleEntity.scale.z = 0.01
            
            return circleEntity
        }
        
        func createBasisOfGlasses(x: Float, y: Float, z: Float, radians: Float, width : Float, height : Float, depth : Float) -> Entity {
            let box = MeshResource.generateBox(width: width, height: height, depth: depth)
            let material = SimpleMaterial(color: .yellow, isMetallic: true)
            let basisOfGlasses = ModelEntity(mesh: box, materials: [material])
            
            basisOfGlasses.position = SIMD3(x, y, z)
            basisOfGlasses.scale.x = 1.1
            basisOfGlasses.scale.z = 0.01
            basisOfGlasses.orientation = simd_quatf(angle: radians, axis: SIMD3(x: 0, y: -1, z: 0))
            
            return basisOfGlasses
        }
        
        func createSphereNose(x: Float = 0, y: Float = 0, z: Float = 0, radius: Float = 1) -> Entity {
            let sphere = MeshResource.generateSphere(radius: radius)
            let material = SimpleMaterial(color: .yellow, isMetallic: true)
            
            let sphereEntity = ModelEntity(mesh: sphere, materials: [material])
            sphereEntity.position = SIMD3(x, y, z)
            
            return sphereEntity
        }
        
        func makeUIView(context: Context) -> ARView {
            // Create AR view
            let arView = ARView(frame: .zero)
            
            // Check that face tracking configeration is supported
            guard ARFaceTrackingConfiguration.isSupported else {
                print(#line, #function, "Sorry, face tracking is not supported by your device")
                return arView
            }
            
            // Create face tracking configuration
            let configuration = ARFaceTrackingConfiguration()
            configuration.isLightEstimationEnabled = true
            
            // Run face tracking session
            arView.session.run(configuration, options: [])
            
            // Create face anchor
            let faceAnchor = AnchorEntity(.face)
            
            // Add box to the face anchor
            faceAnchor.addChild(ARViewContainer.leftEntity)
            faceAnchor.addChild(ARViewContainer.rightEntity)
            faceAnchor.addChild(createSphereNose(z: 0.06, radius: 0.025))
            faceAnchor.addChild(createBasisOfGlasses(x: 0.085, y: 0.025, z: 0.01, radians: 90, width: 0.1, height: 0.015, depth: 0.025))
            faceAnchor.addChild(createBasisOfGlasses(x: -0.085, y: 0.025, z: 0.01, radians: -90, width: 0.1, height: 0.015, depth: 0.025))
            faceAnchor.addChild(createBasisOfGlasses(x: 0, y: 0.025, z: 0.06, radians: 0, width: 0.015, height: 0.015, depth: 0.015))
            
            // Face anchor to the scene
            arView.scene.anchors.append(faceAnchor)
            return arView
        }
        
        func updateUIView(_ uiView: ARView, context: Context) {}
    }
    
#if DEBUG
    struct ContentView_Previews : PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
#endif
}

