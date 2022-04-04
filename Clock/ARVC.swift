import RealityKit
import ARKit

class ARVC: UIViewController {

    let viewModel: ARVCVM
    var arView = ARView()
    var planeAnchor: AnchorEntity = AnchorEntity(.plane(([.any]), classification: [.any], minimumBounds: [0.5, 0.5]))
    
    init(viewModel: ARVCVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupARView()
        setupExperience()
        ClockSystem.registerSystem()
        arView.scene.anchors.append(planeAnchor)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureARView()
    }
    
    func setupARView() {
        self.view.addSubview(arView)
        arView.translatesAutoresizingMaskIntoConstraints = false
        arView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        arView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        arView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        arView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    func configureARView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.vertical]
        arView.renderOptions = [.disableHDR, .disableAREnvironmentLighting, .disableDepthOfField, .disableMotionBlur, .disablePersonOcclusion, .disableGroundingShadows]
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        arView.session.delegate = self
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func setupExperience() {
        createClockFace()
        for i in 0..<12 {
            createHourIndictors(hour: i)
        }
        createHourHand()
        createMinuteHand()
        createSecondsHand()
    }
     
    func createClockFace() {
        let clockMesh: MeshResource = .generatePlane(width: 0.25, depth: 0.25, cornerRadius: 10)
        var material = UnlitMaterial()
        material.color = .init(tint: .white.withAlphaComponent(1.0))
        let modelEntity = ModelEntity(mesh: clockMesh, materials: [material])
        planeAnchor.addChild(modelEntity)
    }
    
    
    func createHourIndictors(hour: Int) {
        let hourMesh: MeshResource = .generatePlane(width: 0.0125, depth: 0.025)
        var material = UnlitMaterial()
        material.color = .init(tint: .black.withAlphaComponent(1.0))
        let modelEntity = ModelEntity(mesh: hourMesh, materials: [material])
        planeAnchor.addChild(modelEntity)
        ARHelper.moveEntity(entity: modelEntity, horizontal: 0.0, vertical: -0.125+0.015, depth: 0.001)
        ARHelper.rotateEntity(entity: modelEntity, axis: .y, angle: Float(ARHelper.deg2rad(Double(-30 * hour))), aroundEntity: planeAnchor)
    }
    
    func createMinuteHand() {
        let offset: SIMD3<Float> = SIMD3(x: 0.0, y: 0.002, z: -0.04)
        let desc = ARHelper.createPlaneMeshDescriptorWithOffset(size: CGSize(width: 0.005, height: 0.08), offset: offset)
        var material = UnlitMaterial()
        material.color = .init(tint: .gray.withAlphaComponent(1.0))
        let entity = Entity()
        entity.components[ModelComponent.self] = ModelComponent(mesh: try! MeshResource.generate(from: [desc]), materials: [material])
        planeAnchor.addChild(entity)
        entity.components[MinuteComponent.self] = MinuteComponent(identity: entity.transform)
    }
    
    func createHourHand() {
        let offset: SIMD3<Float> = SIMD3(x: 0.0, y: 0.003, z: -0.03)
        let desc = ARHelper.createPlaneMeshDescriptorWithOffset(size: CGSize(width: 0.01, height: 0.06), offset: offset)
        var material = UnlitMaterial()
        material.color = .init(tint: .black.withAlphaComponent(1.0))
        let entity = Entity()
        entity.components[ModelComponent.self] = ModelComponent(mesh: try! MeshResource.generate(from: [desc]), materials: [material])
        planeAnchor.addChild(entity)
        entity.components[HourComponent.self] = HourComponent(identity: entity.transform)
    }
    
    func createSecondsHand() {
        let offset: SIMD3<Float> = SIMD3(x: 0.0, y: 0.001, z: -0.045)
        let desc = ARHelper.createPlaneMeshDescriptorWithOffset(size: CGSize(width: 0.003, height: 0.09), offset: offset)
        var material = UnlitMaterial()
        material.color = .init(tint: .red.withAlphaComponent(1.0))
        let entity = Entity()
        entity.components[ModelComponent.self] = ModelComponent(mesh: try! MeshResource.generate(from: [desc]), materials: [material])
        planeAnchor.addChild(entity)
        entity.components[SecondsComponent.self] = SecondsComponent(identity: entity.transform)
    }
}

extension ARVC: ARSessionDelegate {
    
}

struct HourComponent: Component {
    var identity: Transform
}

struct MinuteComponent: Component {
    var identity: Transform
}

struct SecondsComponent: Component {
    var identity: Transform
}

class ClockSystem: System {
    
    private static let hourQuery = EntityQuery(where: .has(HourComponent.self))
    private static let minuteQuery = EntityQuery(where: .has(MinuteComponent.self))
    private static let secondsQuery = EntityQuery(where: .has(SecondsComponent.self))
    
    required init(scene: Scene) {
        
    }
    
    func update(context: SceneUpdateContext) {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date) % 12
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        
        context.scene.performQuery(Self.hourQuery).forEach { entity in
            if let comp = entity.components[HourComponent.self] as? HourComponent {
                entity.transform = comp.identity
                ARHelper.rotateEntity(entity: entity, axis: .y, angle: Float(ARHelper.deg2rad(Double(-30 * hour))))
            }
        }
        
        context.scene.performQuery(Self.minuteQuery).forEach { entity in
            if let comp = entity.components[MinuteComponent.self] as? MinuteComponent {
                entity.transform = comp.identity
                ARHelper.rotateEntity(entity: entity, axis: .y, angle: Float(ARHelper.deg2rad(Double(-6 * minutes))))
            }
        }
        
        context.scene.performQuery(Self.secondsQuery).forEach { entity in
            if let comp = entity.components[SecondsComponent.self] as? SecondsComponent {
                entity.transform = comp.identity
                ARHelper.rotateEntity(entity: entity, axis: .y, angle: Float(ARHelper.deg2rad(-6 * Double(seconds))))
            }
        }
    }
}
