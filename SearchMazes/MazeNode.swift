//
//  MazeNode.swift
//  SearchMazes
//
//  Created by Dion Larson on 7/7/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import SpriteKit

func sync(lock: AnyObject, closure: () -> Void) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

class MazeNode: SKSpriteNode {
    
    var cells = [[Cell]]()
    var startCell: Cell!
    var goalCell: Cell!
    var totalCells: Int!
    var maze: Maze!
    let synced = NSObject()
    var wallsToKnockDown = [SKNode]()
    var cellsToColor = [Cell]()
    
    let queue = dispatch_queue_create("Mazing", DISPATCH_QUEUE_SERIAL)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        maze = Maze(delegate: self)
        
        let cellRows = Int(self.size.height) / CellSize
        let cellColumns = Int(self.size.width) / CellSize
        totalCells = cellRows * cellColumns
        
         for column in 0..<cellColumns {
            var columnOfCells = [Cell]()
            for row in 0..<cellRows {
                let cell = Cell(column: column, row: row, totalColumns: cellColumns, totalRows: cellRows)
                addChild(cell.node)
                columnOfCells.append(cell)
            }
            cells.append(columnOfCells)
        }
        
        startCell = cells[0][0]
        goalCell = cells.last!.last!
        startCell.start = true
        goalCell.goal = true
        
        dispatch_async(queue) {
            usleep(UInt32(1 * Double(USEC_PER_SEC)))
            self.maze.generate(from: self.startCell)
            usleep(UInt32(2 * Double(USEC_PER_SEC)))
            self.maze.solve()
        }
    }
    
    func knockDown(wall: Direction, for cell: Cell) {
        if cell.neighborDirections.contains(wall) {
            let dir = Direction.travel(to: wall)
            let neighbor = self.cells[cell.column + dir.x][cell.row + dir.y]
            let opposite = Direction.opposite(of: wall)
            sync(synced) {
                self.wallsToKnockDown.append(cell.knockDown(wall: wall))
                self.wallsToKnockDown.append(neighbor.knockDown(wall: opposite))
            }
            if Delay != 0 { usleep(UInt32(Delay * Double(USEC_PER_SEC))) }
        } else {
            fatalError("You cannot go in this direction!")
        }
    }
    
    func visit(direction: Direction, for cell: Cell) {
        if cell.openWalls.contains(direction) {
            let dir = Direction.travel(to: direction)
            let neighbor = self.cells[cell.column + dir.x][cell.row + dir.y]
            let opposite = Direction.opposite(of: direction)
            cell.solution = direction
            neighbor.backtrack = opposite
            sync(synced) {
                self.cellsToColor.append(cell)
            }
            if Delay != 0 { usleep(UInt32(Delay * Double(USEC_PER_SEC))) }
        } else {
            fatalError("You cannot go in this direction!")
        }
    }
    
    func backtrack(cell cell: Cell) {
        sync(synced) {
            cell.solution = nil
            self.cellsToColor.append(cell)
        }
        if Delay != 0 { usleep(UInt32(Delay * Double(USEC_PER_SEC))) }
    }
    
    func neighbor(to direction: Direction, of cell: Cell) -> Cell {
        let dir = Direction.travel(to: direction)
        return cells[cell.column + dir.x][cell.row + dir.y]
    }
    
    func randomCell() -> Cell {
        guard let cell = cells.randomElement()?.randomElement() else {
            fatalError("Maze setup failed!")
        }
        return cell
    }
}