//
//  MazeScene.swift
//  SearchMazes
//
//  Created by Dion Larson on 7/7/16.
//  Copyright (c) 2016 Make School. All rights reserved.
//

import SpriteKit

class MazeScene: SKScene {
    
    var mazeNode: MazeNode!
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        mazeNode = childNodeWithName("maze") as! MazeNode
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        let scene = MazeScene(fileNamed: "MazeScene")!
        scene.scaleMode = .AspectFill
        self.view?.presentScene(scene)
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        sync(mazeNode.synced) {
            for node in self.mazeNode.wallsToKnockDown {
                node.removeFromParent()
            }
            self.mazeNode.wallsToKnockDown.removeAll()
            for cell in self.mazeNode.cellsToColor {
                if cell.solution != nil {
                    cell.node.color = cell.solutionColor
                } else if cell.backtrack != nil {
                    cell.node.color = cell.backtrackColor
                } else if !cell.start && !cell.goal {
                    cell.node.color = cell.defaultColor
                }
            }
            self.mazeNode.cellsToColor.removeAll()
        }
    }
}
