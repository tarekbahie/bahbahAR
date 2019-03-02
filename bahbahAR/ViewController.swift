//
//  ViewController.swift
//  bahbahAR
//
//  Created by tarek bahie on 3/1/19.
//  Copyright © 2019 tarek bahie. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var diceArray = [SCNNode]()
    
    // MARK: - APPCYCLEMETHODS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
       
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        let planeNode = createPlane(with: planeAnchor)
        node.addChildNode(planeNode)
    }
    
    // MARK: - PLANERENDERING
    
    func createPlane(with planeAnchor : ARPlaneAnchor)-> SCNNode{
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        plane.materials = [gridMaterial]
        planeNode.geometry = plane
        return planeNode
    }
    
    
    // MARK: - DiceRenderingMethods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            if let hitResult = results.first {
                addDice(atLocation: hitResult)
            }
        }
    }
    func addDice(atLocation hitResult : ARHitTestResult) {
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true){
            diceNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y
                + diceNode.boundingSphere.radius,hitResult.worldTransform.columns.3.z)
            diceArray.append(diceNode)
            sceneView.scene.rootNode.addChildNode(diceNode)
            roll(dice: diceNode)
            
            
        }
    }
    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    func roll(dice: SCNNode) {
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX), y: 0, z: CGFloat(randomZ), duration: 0.5))
    }
    
    @IBAction func rollBtnPressed(_ sender: Any) {
        rollAll()
    }
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    @IBAction func removeBtnPressed(_ sender: Any) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
}
