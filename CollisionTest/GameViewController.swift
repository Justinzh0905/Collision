//
//  GameViewController.swift
//  CollisionTest
//
//  Created by Justin Zhai on 7/10/23.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
  
  var dragGesture: UIPanGestureRecognizer?
  var currentNode: SCNNode?
  var beginningPos: SCNVector3?
  var previousLoc: CGPoint?
  var scnView: SCNView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // create a new scene
    let scene = SCNScene()
    
    // create and add a camera to the scene
    let cameraNode = SCNNode()
    cameraNode.camera = SCNCamera()
    scene.rootNode.addChildNode(cameraNode)
    
    // place the camera
    cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
    
    
    // create and add a light to the scene
    let lightNode = SCNNode()
    lightNode.light = SCNLight()
    lightNode.light!.type = .omni
    lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
    scene.rootNode.addChildNode(lightNode)
    
    // create and add an ambient light to the scene
    let ambientLightNode = SCNNode()
    ambientLightNode.light = SCNLight()
    ambientLightNode.light!.type = .ambient
    ambientLightNode.light!.color = UIColor.darkGray
    scene.rootNode.addChildNode(ambientLightNode)
    
    
    // retrieve the SCNView
    scnView = self.view as! SCNView
    
    // set the scene to the view
    scnView?.scene = scene
    
    // allows the user to manipulate the camera
    scnView?.allowsCameraControl = true
    
    // show statistics such as fps and timing information
    scnView?.showsStatistics = true
    
    // configure the view
    scnView?.backgroundColor = UIColor.black
    
    let node1 = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0))
    node1.position = SCNVector3(x: 0, y: 0, z: 0)
    node1.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: node1, options:
                                                                              [.type: SCNPhysicsShape.ShapeType.convexHull, .collisionMargin: 0.0,]))
    scene.rootNode.addChildNode(node1)
    
    
    let node2 = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0))
    node2.position = SCNVector3(x: 2, y: 2, z: 0)
    node2.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: node2, options:
                                                                              [.type: SCNPhysicsShape.ShapeType.concavePolyhedron, .collisionMargin: 0.0,]))
    scene.rootNode.addChildNode(node2)
    
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    scnView?.addGestureRecognizer(tapGesture)
    
    
  }
  
  func setupGesture() {
    dragGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
    view.addGestureRecognizer(dragGesture!)
  }
  
  func removeGesture() {
    if let dragGesture = dragGesture {
      view.removeGestureRecognizer(dragGesture)
      self.dragGesture = nil // Set the dragGesture to nil after removing it
    }
  }
  
  @objc
  func handlePan(_ sender: UIPanGestureRecognizer) {
    var delta = sender.translation(in: self.view)
    let loc = sender.location(in: self.view)
    
    
    if sender.state == .began {
      if let location = currentNode?.position {
        beginningPos = location
        previousLoc = loc
      }
    }
    
    if sender.state == .changed {
      if let currentNode {
        delta = CGPoint.init(x: 2 * (loc.x - previousLoc!.x), y: 2 * (loc.y - previousLoc!.y))
        currentNode.position = SCNVector3.init(currentNode.position.x  + Float(delta.x * 0.0075), currentNode.position.y - Float(delta.y * (0.0075)), currentNode.position.z)
      }
      previousLoc = loc
    }
    
    
    if sender.state == .ended {
      if let test = currentNode?.physicsBody {
        let list = scnView?.scene?.physicsWorld.contactTest(with: test)
        
        if list!.count > 0 {
          if let beginningPos {
            currentNode?.position = beginningPos
            
          }
        }
      }
    }
    
  }
  
  @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
    
    // check what nodes are tapped
    let p = gestureRecognize.location(in: scnView)
    let hitResults = scnView?.hitTest(p, options: [:])
    
    if let node = currentNode {
      
      removeGesture()
      scnView?.allowsCameraControl = true
      
      
      if let material = node.geometry?.firstMaterial {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        
        material.multiply.contents = UIColor.white
        
        SCNTransaction.commit()
      }
      currentNode = nil
    }
    
    // check that we clicked on at least one object
    if hitResults!.count > 0 {
      // retrieved the first clicked object
      
      currentNode = hitResults!.first?.node
      
      
      
      scnView?.allowsCameraControl = false
      
      
      
      setupGesture()
      
      
      let pos = currentNode!.position
      
      
      if let material = currentNode?.geometry?.firstMaterial {
        
        
        // highlight it
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        
        material.multiply.contents = UIColor.red
        SCNTransaction.commit()
      }
    }
  }
  
  
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    if UIDevice.current.userInterfaceIdiom == .phone {
      return .allButUpsideDown
    } else {
      return .all
    }
  }
  
}
