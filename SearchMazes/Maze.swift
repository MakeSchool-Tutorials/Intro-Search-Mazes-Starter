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
    
    func generate() {
        var cellStack = [Cell]()
        var currentCell = delegate.randomCell()
        var visitedCells = 1
        
        while visitedCells < delegate.totalCells {
            let neighborDirections = unvistedGenerationNeighborDirections(for: currentCell)
            if let direction = neighborDirections.randomElement() {
                delegate.knockDown(direction, for: currentCell)
                cellStack.append(currentCell)
                currentCell = delegate.neighbor(to: direction, of: currentCell)
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
        
        while !currentCell.goal {
            let neighborDirections = unvistedSolutionNeighborDirections(for: currentCell)
            if let direction = neighborDirections.randomElement() {
                delegate.visit(direction, for: currentCell)
                cellStack.append(currentCell)
                currentCell = delegate.neighbor(to: direction, of: currentCell)
            } else {
                delegate.backtrack(cell: currentCell)
                currentCell = cellStack.popLast()!
            }
        }
    }
    
    func unvistedSolutionNeighborDirections(for cell: Cell) -> [Direction] {
        let allNeighborDirections = cell.openPaths
        var unvisitedNeighborDirections = [Direction]()
        for dir in allNeighborDirections {
            let potentialNeighbor = delegate.neighbor(to: dir, of: cell)
            if !potentialNeighbor.onSolution && !potentialNeighbor.onBacktrack {
                unvisitedNeighborDirections.append(dir)
            }
        }
        return unvisitedNeighborDirections
    }
}

// An extension allows you to add functions to an existing class.
// In this case, we have added a "randomElement" function to the
// Array class to make your lives easier! Feel free to use this
// code in future projects.
extension Array {
    func randomElement() -> Element? {
        if self.count == 0 {
            return nil
        }
        return self[Int(arc4random_uniform(UInt32(self.count)))]
    }
}