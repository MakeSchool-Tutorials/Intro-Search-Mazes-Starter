//
//  Maze.swift
//  SearchMazes
//
//  Created by Dion Larson on 7/7/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import SpriteKit

let CellSize = 25
let Delay = 1.0 / 60

class Maze {
    
    let delegate: MazeNode
    
    init(delegate: MazeNode) {
        self.delegate = delegate
    }
    
    func generate(from from: Cell) {
        var cellStack = [Cell]()
        var currentCell = delegate.cells.randomElement().randomElement()
        var visitedCells = 1
        
        while visitedCells < delegate.totalCells {
            let neighborDirections = unvistedGenerationNeighborDirections(for: currentCell)
            if neighborDirections.count != 0 {
                let direction = neighborDirections.randomElement()
                delegate.knockDown(direction, for: currentCell)
                cellStack.append(currentCell)
                let newCell = delegate.neighbor(to: direction, of: currentCell)
                currentCell = newCell
                visitedCells += 1
            } else {
                currentCell = cellStack.popLast()!
            }
        }
    }
    
    func unvistedGenerationNeighborDirections(for cell: Cell) -> [Direction] {
        let allNeighborDirections = cell.neighborDirections
        var unvisitedNeighborDirections = [Direction]()
        for dir in allNeighborDirections {
            let potentialNeighbor = delegate.neighbor(to: dir, of: cell)
            if !potentialNeighbor.knockedDown {
                unvisitedNeighborDirections.append(dir)
            }
        }
        return unvisitedNeighborDirections
    }
    
    func solve() {
        var cellStack = [Cell]()
        var currentCell = delegate.startCell
        var visitedCells = 1
        
        while currentCell !== delegate.goalCell {
            let neighborDirections = unvistedSolutionNeighborDirections(for: currentCell)
            if neighborDirections.count != 0 {
                let direction = neighborDirections.randomElement()
                delegate.visit(direction, for: currentCell)
                cellStack.append(currentCell)
                let newCell = delegate.neighbor(to: direction, of: currentCell)
                currentCell = newCell
                visitedCells += 1
            } else {
                delegate.backtrack(cell: currentCell)
                currentCell = cellStack.popLast()!
            }
        }
    }
    
    func unvistedSolutionNeighborDirections(for cell: Cell) -> [Direction] {
        let allNeighborDirections = cell.openWalls
        var unvisitedNeighborDirections = [Direction]()
        for dir in allNeighborDirections {
            let potentialNeighbor = delegate.neighbor(to: dir, of: cell)
            if potentialNeighbor.solution == nil && potentialNeighbor.backtrack == nil {
                unvisitedNeighborDirections.append(dir)
            }
        }
        return unvisitedNeighborDirections
    }
}