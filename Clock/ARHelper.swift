import RealityKit
import CoreGraphics

struct ARHelper {
    
    static func createPlaneMeshDescriptorWithOffset(size: CGSize, offset: SIMD3<Float>) -> MeshDescriptor {
        let geometry = MeshResource.generatePlane(width: Float(size.width), depth: Float(size.height))
        
        var positions = [SIMD3<Float>]()
        var indices = [UInt32]()
        var textureMap = [SIMD2<Float>]()
        
        for model in geometry.contents.models {
            for part in model.parts {
                positions += offset == .zero ? part.positions.elements : part.positions.elements.map { $0 + offset }
                if let triangleIndices = part.triangleIndices {
                    indices += triangleIndices
                }
                if let textureElements = part.textureCoordinates?.elements {
                    textureMap = textureElements
                }
            }
        }
        
        var desc = MeshDescriptor()
        desc.positions = .init(positions)
        desc.primitives = .triangles(indices)
        desc.textureCoordinates = .init(textureMap)
        desc.materials = .allFaces(0)
        return desc
    }
    
    static func moveEntity(entity: Entity, horizontal: Float, vertical: Float, depth: Float) {
        let trans = SIMD3(x: horizontal, y: depth, z: vertical)
        let t = Transform(translation: trans)
        entity.move(to: t, relativeTo: entity.parent)
    }
    
    static func rotateEntity(entity: Entity, axis: ARHelper.Axis, angle: Float, aroundEntity: Entity? = nil) {
        var _axis: SIMD3<Float>?
        switch axis {
        case .x:
            _axis = SIMD3(x: 1.0, y: 0.0, z: 0.0)
        case .y:
            _axis = SIMD3(x: 0.0, y: 1.0, z: 0.0)
        case .z:
            _axis = SIMD3(x: 0.0, y: 0.0, z: 1.0)
        }
        guard let _axis = _axis else {
            return
        }

        let rot = simd_quatf(angle: angle, axis: _axis)
        let t = Transform(rotation: rot)
        
        if let aroundEntity = aroundEntity {
            let parent = entity.parent
            let originEntity = Entity()
            aroundEntity.addChild(originEntity)
            originEntity.addChild(entity)
            originEntity.move(to: t, relativeTo: originEntity)
            
            let worldTransform = entity.transformMatrix(relativeTo: nil)
            originEntity.removeChild(entity)
            originEntity.removeFromParent()
            parent?.addChild(entity)
            entity.setTransformMatrix(worldTransform, relativeTo: nil)
        } else {
            entity.move(to: t, relativeTo: entity)
        }
    }
    
    static func deg2rad(_ number: Double) -> Double {
        return number * .pi / 180
    }
    
    enum Axis {
        case x
        case y
        case z
    }
}
