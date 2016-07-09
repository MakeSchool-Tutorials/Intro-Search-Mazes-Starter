//
//  Cell.swift
//  SearchMazes
//
//  Created by Dion Larson on 7/7/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import SpriteKit

enum Direction: String {
    
    case Left, Down, Right, Up
    
    static func travel(to direction: Direction) -> (x: Int, y: Int) {
        switch direction {
        case .Left:
            return (-1, 0)
        case .Right:
            return (1, 0)
        case .Up:
            return (0, 1)
        case .Down:
            return (0, -1)
        }
    }
    
    static func opposite(of direction: Direction) -> Direction {
        switch direction {
        case .Left:
            return .Right
        case .Right:
            return .Left
        case .Up:
            return .Down
        case .Down:
            return .Up
        }
    }
    
    static func allValues() -> [Direction] {
        return [.Left, .Down, .Right, .Up]
    }
}

class Cell {
    
    let defaultColor = SKColorWithRGBA(35, g: 142, b: 193, a: 255)
    let startColor = SKColorWithRGBA(27, g: 231, b: 255, a: 255)
    let goalColor = SKColorWithRGBA(110, g: 235, b: 131, a: 255)
    let solutionColor = SKColorWithRGBA(110, g: 235, b: 131, a: 255)
    let backtrackColor = SKColorWithRGBA(249, g: 122, b: 46, a: 255)
    let defaultSize = CGSize(width: CellSize, height: CellSize)
    
    private(set) var openPaths = [Direction]()
    private(set) var neighborDirections: [Direction] = Direction.allValues()
    
    var solution: Direction?
    var backtrack: Direction?
    
    var onSolution: Bool {
        get {
            return solution != nil
        }
    }
    var onBacktrack: Bool {
        get {
            return backtrack != nil
        }
    }
    
    var knockedDown = false
    
    let node: CellNode
    let column: Int
    let row: Int
    
    var start = false {
        didSet {
            if start {
                node.color = startColor
            } else {
                node.color = defaultColor
            }
        }
    }
    
    var goal = false {
        didSet {
            if goal {
                node.color = goalColor
            } else {
                node.color = defaultColor
            }
        }
    }
    
    init(column: Int, row: Int, totalColumns: Int, totalRows: Int) {
        self.row = row
        self.column = column
        node = CellNode(color: defaultColor, size: defaultSize)
        node.position = CGPoint(x: column * CellSize, y: row * CellSize)
        
        if column == 0 {
            neighborDirections = neighborDirections.filter { $0 != .Left }
        }
        if row == 0 {
            neighborDirections = neighborDirections.filter { $0 != .Down }
        }
        if column == totalColumns - 1 {
            neighborDirections = neighborDirections.filter { $0 != .Right }
        }
        if row == totalRows - 1 {
            neighborDirections = neighborDirections.filter { $0 != .Up }
        }
    }
    
    func knockDown(wall wall: Direction) -> SKNode {
        self.knockedDown = true
        openPaths.append(wall)
        return node.childNodeWithName(wall.rawValue)!
    }
}

class CellNode: SKSpriteNode {
    
    init(color: SKColor, size: CGSize) {
        super.init(texture: nil, color: color, size: size)
        self.anchorPoint = CGPoint.zero
        for direction in Direction.allValues() {
            self.addChild(createWall(side: direction))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createWall(side side: Direction) -> SKSpriteNode {
        let wall = SKSpriteNode(imageNamed: "wall")
        wall.zPosition = 10
        wall.setScale(CGFloat(Double(CellSize) / 25.0))
        
        wall.anchorPoint = CGPoint(x: 0.5, y: 0)
        switch side {
        case .Left:
            break
        case .Down:
            wall.zRotation = -π/2
        case .Right:
            wall.position = CGPoint(x: self.size.width, y: 0)
        case .Up:
            wall.position = CGPoint(x: 0, y: self.size.height)
            wall.zRotation = -π/2
        }
        wall.name = side.rawValue
        return wall
    }
    
}