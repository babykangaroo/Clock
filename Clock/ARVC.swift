import RealityKit
import ARKit

class ARVC: UIViewController {

    let viewModel: ARVCVM
    var arView = ARView()
    
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
        let boxMesh: MeshResource = .generateBox(size: 0.25)
        let modelEntity = ModelEntity(mesh: boxMesh)
        let planeAnchor = AnchorEntity(.plane(([.any]), classification: [.any], minimumBounds: [0.5, 0.5]))
        planeAnchor.addChild(modelEntity)
        arView.scene.anchors.append(planeAnchor)
    }
}

extension ARVC: ARSessionDelegate {
    
}
