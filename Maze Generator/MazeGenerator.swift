//
//  MazeGenerator.swift
//  Maze Generator
//
//  Created by Vardogr on 24/10/20.
//  Copyright © 2020 Vardogr. All rights reserved.
//

import Foundation
import GameplayKit

func generateMaze(rndseed: UInt64, numlevels: Int, numrows: Int, numcolumns: Int, roofcovered: Bool, lighting: Bool, mazename: String, mazesign: String, mazeskin: String, mazeexit: String) {
    
    print("Starting generation")
    
    let entrylevel: Int = 1
    let entryrow: Int = Int( round( Double( numrows ) / 2.0 ) )
    let entrycolumn: Int = 1
    
    let exitlevel: Int
    let exitrow: Int
    let exitcolumn: Int
    
    if ( mazeexit == "roof" ) {
        
         exitlevel = numlevels
         exitrow = Int( round( Double( numrows ) / 2.0 ) )
         exitcolumn = Int( round( Double( numcolumns ) / 2.0 ) )

    } else {
        
         exitlevel = 1
         exitrow = Int( round( Double( numrows ) / 2.0 ) )
         exitcolumn = numcolumns

    }
    
    let startlevel: Int = Int( round( Double( numlevels ) / 2.0 ) )
    let startrow: Int = Int( round( Double( numrows ) / 2.0 ) )
    let startcolumn: Int = Int( round( Double( numcolumns ) / 2.0 ) )

    let cellsizex: Int = 4
    let cellsizey: Int = 4
    let cellsizez: Int = 4
    
    let rng = GKMersenneTwisterRandomSource.init(seed: rndseed)
    let rndseedname = "\(rndseed)"
    
    var mazegrid = Array(repeating: Array(repeating: Array(repeating: ["w_up": true, "w_down": true, "w_left": true, "w_right": true, "w_front": true, "w_back": true], count: numcolumns), count: numrows), count: numlevels)
    
    var branchlist: [[String: Int]] = []
    var cleanuplist: [Cleanup] = []
    var nextcleanuplist: [Cleanup] = []

    let mazestart: [String: Int] = ["level": entrylevel, "row": entryrow, "column": entrycolumn]
    let mazeend: [String: Int] = ["level": exitlevel, "row": exitrow, "column": exitcolumn]

    branchlist.append(["level": startlevel, "row": startrow, "column": startcolumn])
    
    let emptycell = ["w_up": true, "w_down": true, "w_left": true, "w_right": true, "w_front": true, "w_back": true]
    
    var nextbranchlist: [[String: Int]]
    var branchchance: Int
    var branching: Int
    var movelist: [String]
    var ml: Int
    var mr: Int
    var mc: Int
    var m_cell: [String: Bool]
    var movenum: Int
    var mmove: String
    var nextpos: [String: Int]
    
    print("Processing branches")

    while ((branchlist.count > 0) || (cleanuplist.count > 0)){
        
        nextbranchlist = []
        
        for mazepos in branchlist {
            
            movelist = []
            branchchance = 0
            
            if (mazepos["row"]! < numrows) {
                
                ml = mazepos["level"]!
                mr = mazepos["row"]!
                mc = mazepos["column"]!
                
                m_cell = mazegrid[ml-1][mr][mc-1]
                
                if (m_cell == emptycell){
                    movelist.append("right")
                    branchchance = 5
                }
            }
            
            if (mazepos["row"]! > 1) {
                
                ml = mazepos["level"]!
                mr = mazepos["row"]!
                mc = mazepos["column"]!
                
                m_cell = mazegrid[ml-1][mr-2][mc-1]
                
                if (m_cell == emptycell){
                    movelist.append("left")
                    branchchance = 5
                }
            }
            
            if (mazepos["column"]! < numcolumns) {
                
                ml = mazepos["level"]!
                mr = mazepos["row"]!
                mc = mazepos["column"]!
                
                m_cell = mazegrid[ml-1][mr-1][mc]
                
                if (m_cell == emptycell){
                    movelist.append("front")
                    branchchance = 5
                }
            }
            
            if (mazepos["column"]! > 1) {
                
                ml = mazepos["level"]!
                mr = mazepos["row"]!
                mc = mazepos["column"]!
                
                m_cell = mazegrid[ml-1][mr-1][mc-2]
                
                if (m_cell == emptycell){
                    movelist.append("back")
                    branchchance = 5
                }
            }
            
            if (mazepos["level"]! < numlevels) {
                
                ml = mazepos["level"]!
                mr = mazepos["row"]!
                mc = mazepos["column"]!
                
                m_cell = mazegrid[ml][mr-1][mc-1]
                
                if (m_cell == emptycell){
                    movelist.append("up")
                    branchchance = 8
                }
            }
            
            if (mazepos["level"]! > 1) {
                
                ml = mazepos["level"]!
                mr = mazepos["row"]!
                mc = mazepos["column"]!
                
                m_cell = mazegrid[ml-2][mr-1][mc-1]
                
                if (m_cell == emptycell){
                    movelist.append("down")
                    branchchance = 8
                }
            }
            
            // check if moves available
            if (movelist.count > 0){
                // check if multiple moves
                if (movelist.count > 1){
                    
                    // there are multiple moves available so check if it should branch
                    branching = GKRandomDistribution(randomSource: rng, lowestValue: 1, highestValue:  branchchance).nextInt()
                    
                    // check random chance of branching
                    if (branching == 1) {
                        // branch immediately
                        nextbranchlist.append(mazepos)
                    } else {
                        // branch after a delay
                        cleanuplist.append( Cleanup(delay: 8, position: mazepos) )
                    }
                }
                
                // get random move from move list
                movenum = GKRandomDistribution(randomSource: rng, lowestValue: 1, highestValue:  movelist.count).nextInt()
                mmove = movelist[movenum - 1]
                
                ml = mazepos["level"]!
                mr = mazepos["row"]!
                mc = mazepos["column"]!

                // check move direction
                switch (mmove){
                    
                case "up":
                    // tunnel up
                    mazegrid[ml-1][mr-1][mc-1]["w_up"] = false
                    mazegrid[ml][mr-1][mc-1]["w_down"] = false
                    
                    nextpos = ["level": ml+1, "row": mr, "column": mc]
                    
                case "down":
                    // tunnel down
                    mazegrid[ml-1][mr-1][mc-1]["w_down"] = false
                    mazegrid[ml-2][mr-1][mc-1]["w_up"] = false
                
                    nextpos = ["level": ml-1, "row": mr, "column": mc]
                    
                case "left":
                    // tunnel left
                    mazegrid[ml-1][mr-1][mc-1]["w_left"] = false
                    mazegrid[ml-1][mr-2][mc-1]["w_right"] = false
                    
                    nextpos = ["level": ml, "row": mr-1, "column": mc]
                    
                case "right":
                    // tunnel right
                    mazegrid[ml-1][mr-1][mc-1]["w_right"] = false
                    mazegrid[ml-1][mr][mc-1]["w_left"] = false
                    
                    nextpos = ["level": ml, "row": mr+1, "column": mc]
                    
                case "front":
                    // tunnel forward
                    mazegrid[ml-1][mr-1][mc-1]["w_front"] = false
                    mazegrid[ml-1][mr-1][mc]["w_back"] = false
                    
                    nextpos = ["level": ml, "row": mr, "column": mc+1]
                    
                case "back":
                    // tunnel back
                    mazegrid[ml-1][mr-1][mc-1]["w_back"] = false
                    mazegrid[ml-1][mr-1][mc-2]["w_front"] = false
                    
                    nextpos = ["level": ml, "row": mr, "column": mc-1]
                    
                default:
                    // didn't recognise move
                    nextpos = ["level": ml, "row": mr, "column": mc]

                }
                
                // check if reached end position
                if (nextpos == mazeend) {
                    
                    ml = nextpos["level"]!
                    mr = nextpos["row"]!
                    mc = nextpos["column"]!
                    
                    // check if exiting to roof
                    if (mazeexit == "roof"){
                        // tunnel up
                        mazegrid[ml-1][mr-1][mc-1]["w_up"] = false

                    } else {
                        // tunnel forward
                        mazegrid[ml-1][mr-1][mc-1]["w_front"] = false
                    }
                    
                } else {
                    // check if reached start position
                    if (nextpos == mazestart) {
                        ml = nextpos["level"]!
                        mr = nextpos["row"]!
                        mc = nextpos["column"]!
                        
                        // tunnel through entrance wall
                        mazegrid[ml-1][mr-1][mc-1]["w_back"] = false
                        
                    } else {
                        // if not start or end then add to next iteration
                        nextbranchlist.append(nextpos)
                    }
                }
            }
        }
        
        // check for cleanup branches
        if (cleanuplist.count > 0) {
            // init next iteration
            nextcleanuplist = []
            
            var vcleanup: Cleanup
            
            // process list
            for cleanup in cleanuplist {
                // copy object
                vcleanup = cleanup
                
                // count down delay
                if vcleanup.Delay() {
                    // not zero, add to next iteration
                    nextcleanuplist.append(vcleanup)
                } else {
                    // delay expired
                    nextbranchlist.append(vcleanup.position)
                }
            }
            
            // set next iteration
            cleanuplist = nextcleanuplist
        }
        
        // set next iteration
        branchlist = nextbranchlist
    }
    
    var mcfunction: String = ""
    var mcfunctionnorth: String = ""
    var mcfunctionsouth: String = ""
    var mcfunctioneast: String = ""
    var mcfunctionwest: String = ""

    let xoffset = -(((entryrow - 1) * cellsizex) + 2)
    let yoffset = -(((entrylevel - 1) * cellsizey) + 1)
    let zoffset = 10

    var xl: Int
    var xr: Int
    var yd: Int
    var yu: Int
    var zf: Int
    var zb: Int
    var x1: Int
    var y1: Int
    var z1: Int
    var x2: Int
    var y2: Int
    var z2: Int
    
    print("Checking skin")

    // check if ksar skin
    if (mazeskin == "moroccan") {
        
        print("Generating skin")

        // front wall

        xl = (-1 + xoffset)
        xr = ((numrows * cellsizex) + 1 + xoffset)
        yd = 1 + yoffset
        yu = ((numlevels * cellsizey) + 1 + yoffset)
        zf = (-1 + zoffset)
        zb = zf

        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:smooth_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:smooth_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:smooth_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:smooth_red_sandstone\r"

        // front left tower

        xl = (-2 + xoffset)
        xr = xl + 8
        yd = 1 + yoffset
        yu = ((numlevels * cellsizey) + 7 + yoffset)
        zf = (-2 + zoffset)
        zb = zf
        
        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:smooth_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:smooth_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:smooth_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:smooth_red_sandstone\r"
        
        // front left pillar
        
        xl = (1 + xoffset)
        xr = xl + 2
        yd = 1 + yoffset
        yu = (((numlevels * cellsizey) / 2) + yoffset)
        zf = (-3 + zoffset)
        zb = zf
        
        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:cut_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:cut_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:cut_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:cut_red_sandstone\r"
        
        xl = (2 + xoffset)
        xr = xl
        yd = 1 + yoffset
        yu = (((numlevels * cellsizey) / 2) + yoffset)
        zf = (-3 + zoffset)
        zb = zf
        
        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:smooth_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:smooth_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:smooth_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:smooth_red_sandstone\r"
            
        // front left pillar cap
        
        x1 = (1 + xoffset)
        y1 = (((numlevels * cellsizey) / 2) + yoffset + 1)
        z1 = (-3 + zoffset)
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        
        x1 = x1 + 1
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:cut_red_sandstone\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:cut_red_sandstone\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:cut_red_sandstone\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:cut_red_sandstone\r"
        
        x1 = x1 + 1
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        
        x1 = x1 - 1
        y1 = y1 + 1
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        
        // front left base
        
        x1 = (-3 + xoffset)
        x2 = x1 + 3
        
        y1 = 1 + yoffset
        y2 = y1
        
        z1 = (-3 + zoffset)
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        
        x1 = x2
        
        z1 = z2 - 1
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        
        x1 = x2 + 1
        x2 = x1 + 3
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        
        x1 = x2
        
        z1 = z2 + 1
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        
        x1 = x2 + 1
        x2 = x1 + 2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        
        x1 = x2
        
        z1 = z2 + 1
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        
        // front right tower
        
        xl = ((numrows * cellsizex) - 6 + xoffset)
        xr = xl + 8
        yd = 1 + yoffset
        yu = ((numlevels * cellsizey) + 7 + yoffset)
        zf = (-2 + zoffset)
        zb = zf
        
        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:smooth_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:smooth_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:smooth_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:smooth_red_sandstone\r"
        
        // front right pillar
        
        xl = ((numrows * cellsizex) - 3 + xoffset)
        xr = xl + 2
        yd = 1 + yoffset
        yu = (((numlevels * cellsizey) / 2) + yoffset)
        zf = (-3 + zoffset)
        zb = zf
        
        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:cut_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:cut_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:cut_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:cut_red_sandstone\r"
        
        xl = ((numrows * cellsizex) - 2 + xoffset)
        xr = xl
        yd = 1 + yoffset
        yu = (((numlevels * cellsizey) / 2) + yoffset)
        zf = (-3 + zoffset)
        zb = zf
        
        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:smooth_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:smooth_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:smooth_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:smooth_red_sandstone\r"
        
        // front right pillar cap
        
        x1 = ((numrows * cellsizex) - 3 + xoffset)
        y1 = (((numlevels * cellsizey) / 2) + yoffset + 1)
        z1 = (-3 + zoffset)
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        
        x1 = x1 + 1
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:cut_red_sandstone\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:cut_red_sandstone\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:cut_red_sandstone\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:cut_red_sandstone\r"
        
        x1 = x1 + 1
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        
        x1 = x1 - 1
        y1 = y1 + 1
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        
        // front right base
        
        x1 = ((numrows * cellsizex) - 7 + xoffset)
        x2 = x1
        
        y1 = 1 + yoffset
        y2 = y1
        
        z1 = (-2 + zoffset)
        z2 = z1 - 1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        
        x1 = x2 + 1
        x2 = x1 + 2
        
        z1 = z2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        
        x1 = x2
        
        z1 = z2 - 1
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        
        x1 = x2 + 1
        x2 = x1 + 3
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        
        x1 = x2
        
        z1 = z2 + 1
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        
        x1 = x2 + 1
        x2 = x1 + 2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        
        // left wall
        
        xl = (-1 + xoffset)
        xr = xl
        yd = 1 + yoffset
        yu = ((numlevels * cellsizey) + 1 + yoffset)
        zf = (-1 + zoffset)
        zb = ((numcolumns * cellsizez) + 1 + zoffset)
        
        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:smooth_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:smooth_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:smooth_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:smooth_red_sandstone\r"
        
        // left front tower
        
        xl = (-2 + xoffset)
        xr = xl
        yd = 1 + yoffset
        yu = ((numlevels * cellsizey) + 7 + yoffset)
        zf = (-2 + zoffset)
        zb = zf + 8
        
        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:smooth_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:smooth_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:smooth_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:smooth_red_sandstone\r"
        
        // left front pillar
        
        xl = (-3 + xoffset)
        xr = xl
        yd = 1 + yoffset
        yu = (((numlevels * cellsizey) / 2) + yoffset)
        zf = (1 + zoffset)
        zb = zf + 2
        
        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:cut_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:cut_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:cut_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:cut_red_sandstone\r"
        
        xl = (-3 + xoffset)
        xr = xl
        yd = 1 + yoffset
        yu = (((numlevels * cellsizey) / 2) + yoffset)
        zf = (2 + zoffset)
        zb = zf
        
        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:smooth_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:smooth_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:smooth_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:smooth_red_sandstone\r"
        
        // left front pillar cap
        
        x1 = (-3 + xoffset)
        y1 = (((numlevels * cellsizey) / 2) + yoffset + 1)
        z1 = (1 + zoffset)
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        
        z1 = z1 + 1
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:cut_red_sandstone\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:cut_red_sandstone\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:cut_red_sandstone\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:cut_red_sandstone\r"
        
        z1 = z1 + 1
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        
        y1 = y1 + 1
        z1 = z1 - 1
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        
        // left front base
        
        x1 = (-2 + xoffset)
        x2 = x1 - 1
        
        y1 = 1 + yoffset
        y2 = y1
        
        z1 = (7 + zoffset)
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        
        x1 = x2
        
        z1 = z2 - 1
        z2 = z1 - 2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        
        x1 = x2 - 1
        x2 = x1
        
        z1 = z2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        
        x1 = x2
        
        z1 = z2 - 1
        z2 = z1 - 3
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        
        x1 = x2 + 1
        x2 = x1
        
        z1 = z2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        
        z1 = z2 - 1
        z2 = z1 - 1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        
        // left back tower
        
        xl = (-2 + xoffset)
        xr = xl
        yd = 1 + yoffset
        yu = ((numlevels * cellsizey) + 7 + yoffset)
        zf = ((numcolumns * cellsizez) - 6 + zoffset)
        zb = zf + 8
        
        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:smooth_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:smooth_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:smooth_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:smooth_red_sandstone\r"
        
        // left back pillar
        
        xl = (-3 + xoffset)
        xr = xl
        yd = 1 + yoffset
        yu = (((numlevels * cellsizey) / 2) + yoffset)
        zf = ((numcolumns * cellsizez) - 3 + zoffset)
        zb = zf + 2
        
        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:cut_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:cut_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:cut_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:cut_red_sandstone\r"
        
        xl = (-3 + xoffset)
        xr = xl
        yd = 1 + yoffset
        yu = (((numlevels * cellsizey) / 2) + yoffset)
        zf = ((numcolumns * cellsizez) - 2 + zoffset)
        zb = zf
        
        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:smooth_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:smooth_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:smooth_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:smooth_red_sandstone\r"
        
        // left back pillar cap
        
        x1 = (-3 + xoffset)
        y1 = (((numlevels * cellsizey) / 2) + yoffset + 1)
        z1 = ((numcolumns * cellsizez) - 3 + zoffset)
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        
        z1 = z1 + 1
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:cut_red_sandstone\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:cut_red_sandstone\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:cut_red_sandstone\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:cut_red_sandstone\r"
        
        z1 = z1 + 1
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        
        y1 = y1 + 1
        z1 = z1 - 1
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        
        // left back base
        
        x1 = (-3 + xoffset)
        x2 = x1
        
        y1 = 1 + yoffset
        y2 = y1
        
        z1 = ((numcolumns * cellsizez) + 3 + zoffset)
        z2 = z1 - 3
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        
        x1 = x2 - 1
        x2 = x1
        
        z1 = z2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        
        z1 = z2 - 1
        z2 = z1 - 3
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        
        x1 = x2 + 1
        x2 = x1
        
        z1 = z2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        
        z1 = z2 - 1
        z2 = z1 - 2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        
        x1 = x2 + 1
        x2 = x1
        
        z1 = z2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        
        // right wall
        
        xl = ((numrows * cellsizex) + 1 + xoffset)
        xr = xl
        yd = 1 + yoffset
        yu = ((numlevels * cellsizey) + 1 + yoffset)
        zf = (-1 + zoffset)
        zb = ((numcolumns * cellsizez) + 1 + zoffset)
        
        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:smooth_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:smooth_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:smooth_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:smooth_red_sandstone\r"
        
        // right front tower
        
        xl = ((numrows * cellsizex) + 2 + xoffset)
        xr = xl
        yd = 1 + yoffset
        yu = ((numlevels * cellsizey) + 7 + yoffset)
        zf = (-2 + zoffset)
        zb = zf + 8
        
        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:smooth_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:smooth_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:smooth_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:smooth_red_sandstone\r"
        
        // right front pillar
        
        xl = ((numrows * cellsizex) + 3 + xoffset)
        xr = xl
        yd = 1 + yoffset
        yu = (((numlevels * cellsizey) / 2) + yoffset)
        zf = (1 + zoffset)
        zb = zf + 2
        
        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:cut_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:cut_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:cut_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:cut_red_sandstone\r"
        
        xl = ((numrows * cellsizex) + 3 + xoffset)
        xr = xl
        yd = 1 + yoffset
        yu = (((numlevels * cellsizey) / 2) + yoffset)
        zf = (2 + zoffset)
        zb = zf
        
        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:smooth_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:smooth_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:smooth_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:smooth_red_sandstone\r"
        
        // right front pillar cap
        
        x1 = ((numrows * cellsizex) + 3 + xoffset)
        y1 = (((numlevels * cellsizey) / 2) + yoffset + 1)
        z1 = (1 + zoffset)
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        
        z1 = z1 + 1
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:cut_red_sandstone\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:cut_red_sandstone\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:cut_red_sandstone\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:cut_red_sandstone\r"
        
        z1 = z1 + 1
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        
        y1 = y1 + 1
        z1 = z1 - 1
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        
        // right front base
        
        x1 = ((numrows * cellsizex) + 3 + xoffset)
        x2 = x1
        
        y1 = 1 + yoffset
        y2 = y1
        
        z1 = (-2 + zoffset)
        z2 = z1 + 2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        
        x1 = x2 + 1
        x2 = x1
        
        z1 = z2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        
        z1 = z2 + 1
        z2 = z1 + 3
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        
        x1 = x2 - 1
        x2 = x1
        
        z1 = z2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        
        z1 = z2 + 1
        z2 = z1 + 2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        
        x1 = x2 - 1
        x2 = x1
        
        z1 = z2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        
        // right back tower
        
        xl = ((numrows * cellsizex) + 2 + xoffset)
        xr = xl
        yd = 1 + yoffset
        yu = ((numlevels * cellsizey) + 7 + yoffset)
        zf = ((numcolumns * cellsizez) - 6 + zoffset)
        zb = zf + 8
        
        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:smooth_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:smooth_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:smooth_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:smooth_red_sandstone\r"
        
        // right back pillar
        
        xl = ((numrows * cellsizex) + 3 + xoffset)
        xr = xl
        yd = 1 + yoffset
        yu = (((numlevels * cellsizey) / 2) + yoffset)
        zf = ((numcolumns * cellsizez) - 3 + zoffset)
        zb = zf + 2
        
        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:cut_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:cut_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:cut_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:cut_red_sandstone\r"
        
        xl = ((numrows * cellsizex) + 3 + xoffset)
        xr = xl
        yd = 1 + yoffset
        yu = (((numlevels * cellsizey) / 2) + yoffset)
        zf = ((numcolumns * cellsizez) - 2 + zoffset)
        zb = zf
        
        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:smooth_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:smooth_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:smooth_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:smooth_red_sandstone\r"
        
        // right back pillar cap
        
        x1 = ((numrows * cellsizex) + 3 + xoffset)
        y1 = (((numlevels * cellsizey) / 2) + yoffset + 1)
        z1 = ((numcolumns * cellsizez) - 3 + zoffset)
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        
        z1 = z1 + 1
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:cut_red_sandstone\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:cut_red_sandstone\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:cut_red_sandstone\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:cut_red_sandstone\r"
        
        z1 = z1 + 1
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        
        y1 = y1 + 1
        z1 = z1 - 1
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        
        // right back base
        
        x1 = ((numrows * cellsizex) + 2 + xoffset)
        x2 = x1 + 1
        
        y1 = 1 + yoffset
        y2 = y1
        
        z1 = ((numcolumns * cellsizez) - 7 + zoffset)
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        
        x1 = x2
        
        z1 = z2 + 1
        z2 = z1 + 2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        
        x1 = x2 + 1
        x2 = x1
        
        z1 = z2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        
        z1 = z2 + 1
        z2 = z1 + 3
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        
        x1 = x2 - 1
        x2 = x1
        
        z1 = z2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        
        z1 = z2 + 1
        z2 = z1 + 2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        
        // back wall
        
        xl = (-1 + xoffset)
        xr = ((numrows * cellsizex) + 1 + xoffset)
        yd = 1 + yoffset
        yu = ((numlevels * cellsizey) + 1 + yoffset)
        zf = ((numcolumns * cellsizez) + 1 + zoffset)
        zb = zf
        
        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:smooth_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:smooth_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:smooth_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:smooth_red_sandstone\r"
        
        // back left tower
        
        xl = (-2 + xoffset)
        xr = xl + 8
        yd = 1 + yoffset
        yu = ((numlevels * cellsizey) + 7 + yoffset)
        zf = ((numcolumns * cellsizez) + 2 + zoffset)
        zb = zf
        
        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:smooth_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:smooth_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:smooth_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:smooth_red_sandstone\r"
        
        // back left pillar
        
        xl = (1 + xoffset)
        xr = xl + 2
        yd = 1 + yoffset
        yu = (((numlevels * cellsizey) / 2) + yoffset)
        zf = ((numcolumns * cellsizez) + 3 + zoffset)
        zb = zf
        
        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:cut_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:cut_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:cut_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:cut_red_sandstone\r"
        
        xl = (2 + xoffset)
        xr = xl
        yd = 1 + yoffset
        yu = (((numlevels * cellsizey) / 2) + yoffset)
        zf = ((numcolumns * cellsizez) + 3 + zoffset)
        zb = zf
        
        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:smooth_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:smooth_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:smooth_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:smooth_red_sandstone\r"
        
        // back left pillar cap
        
        x1 = (1 + xoffset)
        y1 = (((numlevels * cellsizey) / 2) + yoffset + 1)
        z1 = ((numcolumns * cellsizez) + 3 + zoffset)
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        
        x1 = x1 + 1
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:cut_red_sandstone\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:cut_red_sandstone\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:cut_red_sandstone\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:cut_red_sandstone\r"
        
        x1 = x1 + 1
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        
        x1 = x1 - 1
        y1 = y1 + 1
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        
        // back left base
        
        x1 = (7 + xoffset)
        x2 = x1
        
        y1 = 1 + yoffset
        y2 = y1
        
        z1 = ((numcolumns * cellsizez) + 2 + zoffset)
        z2 = z1 + 1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        
        x1 = x2 - 1
        x2 = x1 - 2
        
        z1 = z2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        
        x1 = x2
        
        z1 = z2 + 1
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        
        x1 = x2 - 1
        x2 = x1 - 3
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        
        x1 = x2
        
        z1 = z2 - 1
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        
        x1 = x2 - 1
        x2 = x1 - 1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        
        // back right tower
        
        xl = ((numrows * cellsizex) - 6 + xoffset)
        xr = xl + 8
        yd = 1 + yoffset
        yu = ((numlevels * cellsizey) + 7 + yoffset)
        zf = ((numcolumns * cellsizez) + 2 + zoffset)
        zb = zf
        
        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:smooth_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:smooth_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:smooth_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:smooth_red_sandstone\r"
        
        // back right pillar
        
        xl = ((numrows * cellsizex) - 3 + xoffset)
        xr = xl + 2
        yd = 1 + yoffset
        yu = (((numlevels * cellsizey) / 2) + yoffset)
        zf = ((numcolumns * cellsizez) + 3 + zoffset)
        zb = zf
        
        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:cut_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:cut_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:cut_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:cut_red_sandstone\r"
        
        xl = ((numrows * cellsizex) - 2 + xoffset)
        xr = xl
        yd = 1 + yoffset
        yu = (((numlevels * cellsizey) / 2) + yoffset)
        zf = ((numcolumns * cellsizez) + 3 + zoffset)
        zb = zf
        
        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:smooth_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:smooth_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:smooth_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:smooth_red_sandstone\r"
        
        // back left pillar cap
        
        x1 = ((numrows * cellsizex) - 3 + xoffset)
        y1 = (((numlevels * cellsizey) / 2) + yoffset + 1)
        z1 = ((numcolumns * cellsizez) + 3 + zoffset)
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        
        x1 = x1 + 1
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:cut_red_sandstone\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:cut_red_sandstone\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:cut_red_sandstone\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:cut_red_sandstone\r"
        
        x1 = x1 + 1
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        
        x1 = x1 - 1
        y1 = y1 + 1
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        
        // back right base
        
        x1 = ((numrows * cellsizex) + 2 + xoffset)
        x2 = x1 - 2
        
        y1 = 1 + yoffset
        y2 = y1
        
        z1 = ((numcolumns * cellsizez) + 2 + zoffset)
        z2 = z1 + 1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        
        x1 = x2
        
        z1 = z2 + 1
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        
        x1 = x2 - 1
        x2 = x1 - 3
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        
        x1 = x2
        
        z1 = z2 - 1
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        
        x1 = x2 - 1
        x2 = x1 - 2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        
        x1 = x2
        
        z1 = z2 - 1
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        
        // roof
        
        xl = (-1 + xoffset)
        xr = ((numrows * cellsizex) + 1 + xoffset)
        yd = ((numlevels * cellsizey) + 1 + yoffset)
        yu = yd
        zf = (-1 + zoffset)
        zb = ((numcolumns * cellsizez) + 1 + zoffset)
        
        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:smooth_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:smooth_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:smooth_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:smooth_red_sandstone\r"
        
        // roof front edge
        
        x1 = xl + 8
        x2 = xr - 8
        
        y1 = yu
        y2 = yu
        
        z1 = zf
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
            
        // roof front windows
        
        y1 = yu - 3
        y2 = y1 + 1
        
        z1 = zf
        z2 = z1
        
        for x1 in stride( from:(xl + 9), to: (xr - 8), by: 2 ) {
        
            x2 = x1
        
            mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:dark_oak_trapdoor[facing=south,open=true]\r"
            mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:dark_oak_trapdoor[facing=north,open=true]\r"
            mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:dark_oak_trapdoor[facing=west,open=true]\r"
            mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:dark_oak_trapdoor[facing=east,open=true]\r"
        
        }
        
        // roof front sill
        
        x1 = xl + 8
        x2 = xr - 8
        
        y1 = yu - 4
        y2 = y1
        
        z1 = zf
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:cut_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:cut_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:cut_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:cut_red_sandstone\r"
        
        y1 = y1 - 1
        y2 = y1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        
        // roof back edge
        
        x1 = xl + 8
        x2 = xr - 8
        
        y1 = yu
        y2 = yu
        
        z1 = zb
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        
        // roof back windows
        
        y1 = yu - 3
        y2 = y1 + 1
        
        z1 = zb
        z2 = z1
        
        for x1 in stride( from: (xl + 9), to: (xr - 8), by: 2) {
            
            x2 = x1
            
            mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:dark_oak_trapdoor[facing=north,open=true]\r"
            mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:dark_oak_trapdoor[facing=south,open=true]\r"
            mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:dark_oak_trapdoor[facing=east,open=true]\r"
            mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:dark_oak_trapdoor[facing=west,open=true]\r"
        
        }
        
        // roof back sill
        
        x1 = xl + 8
        x2 = xr - 8
        
        y1 = yu - 4
        y2 = y1
        
        z1 = zb
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:cut_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:cut_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:cut_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:cut_red_sandstone\r"
        
        y1 = y1 - 1
        y2 = y1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        
        // roof left edge
        
        x1 = xl
        x2 = x1
        
        y1 = yu
        y2 = yu
        
        z1 = zf + 8
        z2 = zb - 8
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        
        // roof left windows
        
        x1 = xl
        x2 = x1
        
        y1 = yu - 3
        y2 = y1 + 1
        
        for z1 in stride( from: (zf + 9), to: (zb - 8), by: 2 ) {
            
            z2 = z1
            
            mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:dark_oak_trapdoor[facing=west,open=true]\r"
            mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:dark_oak_trapdoor[facing=east,open=true]\r"
            mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:dark_oak_trapdoor[facing=north,open=true]\r"
            mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:dark_oak_trapdoor[facing=south,open=true]\r"
        
        }
        
        // roof left sill
        
        x1 = xl
        x2 = x1
        
        y1 = yu - 4
        y2 = y1
        
        z1 = zf + 8
        z2 = zb - 8
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:cut_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:cut_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:cut_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:cut_red_sandstone\r"
        
        y1 = y1 - 1
        y2 = y1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        
        // roof right edge
        
        x1 = xr
        x2 = x1
        
        y1 = yu
        y2 = yu
        
        z1 = zf + 8
        z2 = zb - 8
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        
        // roof right windows
        
        x1 = xr
        x2 = x1
        
        y1 = yu - 3
        y2 = y1 + 1
        
        for z1 in stride( from: (zf + 9), to: (zb - 8), by: 2 ) {
            
            z2 = z1
            
            mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:dark_oak_trapdoor[facing=east,open=true]\r"
            mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:dark_oak_trapdoor[facing=west,open=true]\r"
            mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:dark_oak_trapdoor[facing=south,open=true]\r"
            mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:dark_oak_trapdoor[facing=north,open=true]\r"
        
        }
        
        // roof right sill
        
        x1 = xr
        x2 = x1
        
        y1 = yu - 4
        y2 = y1
        
        z1 = zf + 8
        z2 = zb - 8
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:cut_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:cut_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:cut_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:cut_red_sandstone\r"
        
        y1 = y1 - 1
        y2 = y1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        
        // ----------------
        // -- FRONT WALL --
        // ----------------
        
        // front left tower arches
        
        x1 = xl
        x2 = x1 + 2
        
        y1 = yu - 6
        y2 = y1 + 4
        
        z1 = zf - 1
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:air\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:air\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:air\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:air\r"
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, (z1 + 1), "north"))\(mineCoords(x2, y2, (z2 + 1), "north")) minecraft:brown_terracotta\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, (z1 + 1), "south"))\(mineCoords(x2, y2, (z2 + 1), "south")) minecraft:brown_terracotta\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, (z1 + 1), "east"))\(mineCoords(x2, y2, (z2 + 1), "east")) minecraft:brown_terracotta\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, (z1 + 1), "west"))\(mineCoords(x2, y2, (z2 + 1), "west")) minecraft:brown_terracotta\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y2, z1, "north")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y2, z1, "south")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y2, z1, "east")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y2, z1, "west")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x2, y2, z1, "north")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x2, y2, z1, "south")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x2, y2, z1, "east")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x2, y2, z1, "west")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        
        x1 = x2 + 2
        x2 = x1 + 2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:air\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:air\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:air\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:air\r"
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, (z1 + 1), "north"))\(mineCoords(x2, y2, (z2 + 1), "north")) minecraft:brown_terracotta\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, (z1 + 1), "south"))\(mineCoords(x2, y2, (z2 + 1), "south")) minecraft:brown_terracotta\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, (z1 + 1), "east"))\(mineCoords(x2, y2, (z2 + 1), "east")) minecraft:brown_terracotta\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, (z1 + 1), "west"))\(mineCoords(x2, y2, (z2 + 1), "west")) minecraft:brown_terracotta\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y2, z1, "north")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y2, z1, "south")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y2, z1, "east")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y2, z1, "west")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x2, y2, z1, "north")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x2, y2, z1, "south")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x2, y2, z1, "east")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x2, y2, z1, "west")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        
        x1 = xl - 1
        x2 = x1 + 8
        
        y1 = yu - 7
        y2 = y1
        
        z1 = zf - 1
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:cut_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:cut_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:cut_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:cut_red_sandstone\r"
        
        // front left tower windows
        
        y1 = yu + 2
        y2 = y1
        
        z1 = zf - 1
        z2 = z1
        
        for x1 in stride( from: xl, to: (xl + 7), by: 2 ) {
        
            x2 = x1
            
            mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:air\r"
            mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:air\r"
            mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:air\r"
            mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:air\r"
            
            mcfunctionnorth += "fill\(mineCoords(x1, (y1 + 2), z1, "north"))\(mineCoords(x2, (y2 + 2), z2, "north")) minecraft:air\r"
            mcfunctionsouth += "fill\(mineCoords(x1, (y1 + 2), z1, "south"))\(mineCoords(x2, (y2 + 2), z2, "south")) minecraft:air\r"
            mcfunctioneast += "fill\(mineCoords(x1, (y1 + 2), z1, "east"))\(mineCoords(x2, (y2 + 2), z2, "east")) minecraft:air\r"
            mcfunctionwest += "fill\(mineCoords(x1, (y1 + 2), z1, "west"))\(mineCoords(x2, (y2 + 2), z2, "west")) minecraft:air\r"
        
        }
        
        // front left tower ledge
        
        x1 = xl - 2
        x2 = x1 + 10
        
        y1 = yu - 12
        y2 = y1
        
        z1 = zf - 2
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        
        x1 = x2
        
        z1 = z2 + 1
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        
        // front left tower rim
        
        x1 = xl - 2
        x2 = x1 + 10
        
        y1 = yu + 6
        y2 = y1
        
        z1 = zf - 2
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        
        x1 = x2
        
        z1 = z2 + 1
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        
        // front left tower peaks
        
        y1 = yu + 7
        y2 = y1
        
        z1 = zf - 2
        z2 = z1
        
        for x1 in stride( from: (xl), to: (xl + 9), by: 2 ) {
            
            x2 = x1
            
            mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_wall\r"
            mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_wall\r"
            mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_wall\r"
            mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_wall\r"
            
        }
        
        // front right arches
        
        x1 = xr - 6
        x2 = x1 + 2
        
        y1 = yu - 6
        y2 = y1 + 4
        
        z1 = zf - 1
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:air\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:air\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:air\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:air\r"
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, (z1 + 1), "north"))\(mineCoords(x2, y2, (z2 + 1), "north")) minecraft:brown_terracotta\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, (z1 + 1), "south"))\(mineCoords(x2, y2, (z2 + 1), "south")) minecraft:brown_terracotta\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, (z1 + 1), "east"))\(mineCoords(x2, y2, (z2 + 1), "east")) minecraft:brown_terracotta\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, (z1 + 1), "west"))\(mineCoords(x2, y2, (z2 + 1), "west")) minecraft:brown_terracotta\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y2, z1, "north")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y2, z1, "south")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y2, z1, "east")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y2, z1, "west")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x2, y2, z1, "north")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x2, y2, z1, "south")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x2, y2, z1, "east")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x2, y2, z1, "west")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        
        x1 = x2 + 2
        x2 = x1 + 2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:air\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:air\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:air\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:air\r"
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, (z1 + 1), "north"))\(mineCoords(x2, y2, (z2 + 1), "north")) minecraft:brown_terracotta\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, (z1 + 1), "south"))\(mineCoords(x2, y2, (z2 + 1), "south")) minecraft:brown_terracotta\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, (z1 + 1), "east"))\(mineCoords(x2, y2, (z2 + 1), "east")) minecraft:brown_terracotta\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, (z1 + 1), "west"))\(mineCoords(x2, y2, (z2 + 1), "west")) minecraft:brown_terracotta\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y2, z1, "north")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y2, z1, "south")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y2, z1, "east")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y2, z1, "west")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x2, y2, z1, "north")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x2, y2, z1, "south")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x2, y2, z1, "east")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x2, y2, z1, "west")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        
        x1 = xr - 7
        x2 = x1 + 8
        
        y1 = yu - 7
        y2 = y1
        
        z1 = zf - 1
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:cut_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:cut_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:cut_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:cut_red_sandstone\r"
        
        // front right tower windows
        
        y1 = yu + 2
        y2 = y1
        
        z1 = zf - 1
        z2 = z1
        
        for x1 in stride( from: (xr - 6), to: (xr + 1), by: 2 ) {
            
            x2 = x1
            
            mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:air\r"
            mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:air\r"
            mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:air\r"
            mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:air\r"
            
            mcfunctionnorth += "fill\(mineCoords(x1, (y1 + 2), z1, "north"))\(mineCoords(x2, (y2 + 2), z2, "north")) minecraft:air\r"
            mcfunctionsouth += "fill\(mineCoords(x1, (y1 + 2), z1, "south"))\(mineCoords(x2, (y2 + 2), z2, "south")) minecraft:air\r"
            mcfunctioneast += "fill\(mineCoords(x1, (y1 + 2), z1, "east"))\(mineCoords(x2, (y2 + 2), z2, "east")) minecraft:air\r"
            mcfunctionwest += "fill\(mineCoords(x1, (y1 + 2), z1, "west"))\(mineCoords(x2, (y2 + 2), z2, "west")) minecraft:air\r"
        
        }
        
        // front right tower ledge
        
        x1 = xr - 8
        x2 = x1
        
        y1 = yu - 12
        y2 = y1
        
        z1 = zf - 1
        z2 = z1 - 1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        
        x1 = x2 + 1
        x2 = x1 + 9
        
        z1 = z2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        
        // front right tower rim
        
        x1 = xr - 8
        x2 = x1
        
        y1 = yu + 6
        y2 = y1
        
        z1 = zf - 1
        z2 = z1 - 1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        
        x1 = x2 + 1
        x2 = x1 + 9
        
        z1 = z2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        
        // front right tower peaks
        
        y1 = yu + 7
        y2 = y1
        
        z1 = zf - 2
        z2 = z1
        
        for x1 in stride( from: (xr - 8), to: (xr + 3), by: 2 ) {
            
            x2 = x1
            
            mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_wall\r"
            mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_wall\r"
            mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_wall\r"
            mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_wall\r"
            
        }
        
        // ----------------
        // -- RIGHT WALL --
        // ----------------
        
        // right front tower arches
        
        z1 = zf
        z2 = z1 + 2
        
        y1 = yu - 6
        y2 = y1 + 4
        
        x1 = xr + 1
        x2 = x1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:air\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:air\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:air\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:air\r"
        
        mcfunctionnorth += "fill\(mineCoords((x1 - 1), y1, z1, "north"))\(mineCoords((x2 - 1), y2, z2, "north")) minecraft:brown_terracotta\r"
        mcfunctionsouth += "fill\(mineCoords((x1 - 1), y1, z1, "south"))\(mineCoords((x2 - 1), y2, z2, "south")) minecraft:brown_terracotta\r"
        mcfunctioneast += "fill\(mineCoords((x1 - 1), y1, z1, "east"))\(mineCoords((x2 - 1), y2, z2, "east")) minecraft:brown_terracotta\r"
        mcfunctionwest += "fill\(mineCoords((x1 - 1), y1, z1, "west"))\(mineCoords((x2 - 1), y2, z2, "west")) minecraft:brown_terracotta\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y2, z1, "north")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y2, z1, "south")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y2, z1, "east")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y2, z1, "west")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x2, y2, z2, "north")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x2, y2, z2, "south")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x2, y2, z2, "east")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x2, y2, z2, "west")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        
        z1 = z2 + 2
        z2 = z1 + 2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:air\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:air\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:air\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:air\r"
        
        mcfunctionnorth += "fill\(mineCoords((x1 - 1), y1, z1, "north"))\(mineCoords((x2 - 1), y2, z2, "north")) minecraft:brown_terracotta\r"
        mcfunctionsouth += "fill\(mineCoords((x1 - 1), y1, z1, "south"))\(mineCoords((x2 - 1), y2, z2, "south")) minecraft:brown_terracotta\r"
        mcfunctioneast += "fill\(mineCoords((x1 - 1), y1, z1, "east"))\(mineCoords((x2 - 1), y2, z2, "east")) minecraft:brown_terracotta\r"
        mcfunctionwest += "fill\(mineCoords((x1 - 1), y1, z1, "west"))\(mineCoords((x2 - 1), y2, z2, "west")) minecraft:brown_terracotta\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y2, z1, "north")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y2, z1, "south")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y2, z1, "east")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y2, z1, "west")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x2, y2, z2, "north")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x2, y2, z2, "south")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x2, y2, z2, "east")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x2, y2, z2, "west")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        
        z1 = zf - 1
        z2 = z1 + 8
        
        y1 = yu - 7
        y2 = y1
        
        x1 = xr + 1
        x2 = x1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:cut_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:cut_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:cut_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:cut_red_sandstone\r"
        
        // right front tower windows
        
        y1 = yu + 2
        y2 = y1
        
        x1 = xr + 1
        x2 = x1
        
        for z1 in stride( from: zf, to: (zf + 7), by: 2 ) {
            
            z2 = z1
            
            mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:air\r"
            mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:air\r"
            mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:air\r"
            mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:air\r"
            
            mcfunctionnorth += "fill\(mineCoords(x1, (y1 + 2), z1, "north"))\(mineCoords(x2, (y2 + 2), z2, "north")) minecraft:air\r"
            mcfunctionsouth += "fill\(mineCoords(x1, (y1 + 2), z1, "south"))\(mineCoords(x2, (y2 + 2), z2, "south")) minecraft:air\r"
            mcfunctioneast += "fill\(mineCoords(x1, (y1 + 2), z1, "east"))\(mineCoords(x2, (y2 + 2), z2, "east")) minecraft:air\r"
            mcfunctionwest += "fill\(mineCoords(x1, (y1 + 2), z1, "west"))\(mineCoords(x2, (y2 + 2), z2, "west")) minecraft:air\r"
        
        }
        
        // right front tower ledge
        
        z1 = zf - 1
        z2 = z1 + 9
        
        y1 = yu - 12
        y2 = y1
        
        x1 = xr + 2
        x2 = x1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        
        z1 = z2
        
        x1 = x2 - 1
        x2 = x1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        
        // right front tower rim
        
        z1 = zf - 1
        z2 = z1 + 9
        
        y1 = yu + 6
        y2 = y1
        
        x1 = xr + 2
        x2 = x1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        
        z1 = z2
        
        x1 = x2 - 1
        x2 = x1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        
        // right front tower peaks
        
        y1 = yu + 7
        y2 = y1
        
        x1 = xr + 2
        x2 = x1
        
        for z1 in stride( from: (zf), to: (zf + 9), by: 2 ) {
            
            z2 = z1
            
            mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_wall\r"
            mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_wall\r"
            mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_wall\r"
            mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_wall\r"
        
        }
        
        // right back tower arches
        
        z1 = zb - 6
        z2 = z1 + 2
        
        y1 = yu - 6
        y2 = y1 + 4
        
        x1 = xr + 1
        x2 = x1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:air\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:air\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:air\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:air\r"
        
        mcfunctionnorth += "fill\(mineCoords((x1 - 1), y1, z1, "north"))\(mineCoords((x2 - 1), y2, z2, "north")) minecraft:brown_terracotta\r"
        mcfunctionsouth += "fill\(mineCoords((x1 - 1), y1, z1, "south"))\(mineCoords((x2 - 1), y2, z2, "south")) minecraft:brown_terracotta\r"
        mcfunctioneast += "fill\(mineCoords((x1 - 1), y1, z1, "east"))\(mineCoords((x2 - 1), y2, z2, "east")) minecraft:brown_terracotta\r"
        mcfunctionwest += "fill\(mineCoords((x1 - 1), y1, z1, "west"))\(mineCoords((x2 - 1), y2, z2, "west")) minecraft:brown_terracotta\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y2, z1, "north")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y2, z1, "south")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y2, z1, "east")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y2, z1, "west")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x2, y2, z2, "north")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x2, y2, z2, "south")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x2, y2, z2, "east")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x2, y2, z2, "west")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        
        z1 = z2 + 2
        z2 = z1 + 2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:air\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:air\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:air\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:air\r"
        
        mcfunctionnorth += "fill\(mineCoords((x1 - 1), y1, z1, "north"))\(mineCoords((x2 - 1), y2, z2, "north")) minecraft:brown_terracotta\r"
        mcfunctionsouth += "fill\(mineCoords((x1 - 1), y1, z1, "south"))\(mineCoords((x2 - 1), y2, z2, "south")) minecraft:brown_terracotta\r"
        mcfunctioneast += "fill\(mineCoords((x1 - 1), y1, z1, "east"))\(mineCoords((x2 - 1), y2, z2, "east")) minecraft:brown_terracotta\r"
        mcfunctionwest += "fill\(mineCoords((x1 - 1), y1, z1, "west"))\(mineCoords((x2 - 1), y2, z2, "west")) minecraft:brown_terracotta\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y2, z1, "north")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y2, z1, "south")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y2, z1, "east")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y2, z1, "west")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x2, y2, z2, "north")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x2, y2, z2, "south")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x2, y2, z2, "east")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x2, y2, z2, "west")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        
        z1 = zb - 7
        z2 = z1 + 8
        
        y1 = yu - 7
        y2 = y1
        
        x1 = xr + 1
        x2 = x1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:cut_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:cut_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:cut_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:cut_red_sandstone\r"
        
        // right back tower windows
        
        y1 = yu + 2
        y2 = y1
        
        x1 = xr + 1
        x2 = x1
        
        for z1 in stride( from: (zb - 6), to: (zb + 1), by: 2 ) {
            
            z2 = z1
            
            mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:air\r"
            mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:air\r"
            mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:air\r"
            mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:air\r"
            
            mcfunctionnorth += "fill\(mineCoords(x1, (y1 + 2), z1, "north"))\(mineCoords(x2, (y2 + 2), z2, "north")) minecraft:air\r"
            mcfunctionsouth += "fill\(mineCoords(x1, (y1 + 2), z1, "south"))\(mineCoords(x2, (y2 + 2), z2, "south")) minecraft:air\r"
            mcfunctioneast += "fill\(mineCoords(x1, (y1 + 2), z1, "east"))\(mineCoords(x2, (y2 + 2), z2, "east")) minecraft:air\r"
            mcfunctionwest += "fill\(mineCoords(x1, (y1 + 2), z1, "west"))\(mineCoords(x2, (y2 + 2), z2, "west")) minecraft:air\r"
        
        }
        
        // right back tower ledge
        
        z1 = zb - 8
        z2 = z1
        
        y1 = yu - 12
        y2 = y1
        
        x1 = xr + 1
        x2 = x1 + 1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        
        z1 = z2 + 1
        z2 = z1 + 9
        
        x1 = x2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        
        // right back tower rim
        
        z1 = zb - 8
        z2 = z1
        
        y1 = yu + 6
        y2 = y1
        
        x1 = xr + 1
        x2 = x1 + 1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        
        z1 = z2 + 1
        z2 = z1 + 9
        
        x1 = x2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        
        // right back tower peaks
        
        y1 = yu + 7
        y2 = y1
        
        x1 = xr + 2
        x2 = x1
        
        for z1 in stride( from: (zb - 8), to: (zb + 3), by: 2 ) {
            
            z2 = z1
            
            mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_wall\r"
            mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_wall\r"
            mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_wall\r"
            mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_wall\r"
            
        }
        
        // ---------------
        // -- BACK WALL --
        // ---------------
        
        // back right tower arches
        
        x1 = xr
        x2 = x1 - 2
        
        y1 = yu - 6
        y2 = y1 + 4
        
        z1 = zb + 1
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:air\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:air\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:air\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:air\r"
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, (z1 - 1), "north"))\(mineCoords(x2, y2, (z2 - 1), "north")) minecraft:brown_terracotta\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, (z1 - 1), "south"))\(mineCoords(x2, y2, (z2 - 1), "south")) minecraft:brown_terracotta\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, (z1 - 1), "east"))\(mineCoords(x2, y2, (z2 - 1), "east")) minecraft:brown_terracotta\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, (z1 - 1), "west"))\(mineCoords(x2, y2, (z2 - 1), "west")) minecraft:brown_terracotta\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y2, z1, "north")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y2, z1, "south")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y2, z1, "east")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y2, z1, "west")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x2, y2, z1, "north")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x2, y2, z1, "south")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x2, y2, z1, "east")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x2, y2, z1, "west")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        
        x1 = x2 - 2
        x2 = x1 - 2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:air\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:air\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:air\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:air\r"
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, (z1 - 1), "north"))\(mineCoords(x2, y2, (z2 - 1), "north")) minecraft:brown_terracotta\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, (z1 - 1), "south"))\(mineCoords(x2, y2, (z2 - 1), "south")) minecraft:brown_terracotta\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, (z1 - 1), "east"))\(mineCoords(x2, y2, (z2 - 1), "east")) minecraft:brown_terracotta\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, (z1 - 1), "west"))\(mineCoords(x2, y2, (z2 - 1), "west")) minecraft:brown_terracotta\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y2, z1, "north")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y2, z1, "south")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y2, z1, "east")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y2, z1, "west")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x2, y2, z1, "north")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x2, y2, z1, "south")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x2, y2, z1, "east")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x2, y2, z1, "west")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        
        x1 = xr + 1
        x2 = x1 - 8
        
        y1 = yu - 7
        y2 = y1
        
        z1 = zb + 1
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:cut_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:cut_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:cut_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:cut_red_sandstone\r"
        
        // back right tower windows
        
        y1 = yu + 2
        y2 = y1
        
        z1 = zb + 1
        z2 = z1
        
        for x1 in stride( from: xr, to: (xr - 7), by: -2 ) {
            
            x2 = x1
            
            mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:air\r"
            mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:air\r"
            mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:air\r"
            mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:air\r"
            
            mcfunctionnorth += "fill\(mineCoords(x1, (y1 + 2), z1, "north"))\(mineCoords(x2, (y2 + 2), z2, "north")) minecraft:air\r"
            mcfunctionsouth += "fill\(mineCoords(x1, (y1 + 2), z1, "south"))\(mineCoords(x2, (y2 + 2), z2, "south")) minecraft:air\r"
            mcfunctioneast += "fill\(mineCoords(x1, (y1 + 2), z1, "east"))\(mineCoords(x2, (y2 + 2), z2, "east")) minecraft:air\r"
            mcfunctionwest += "fill\(mineCoords(x1, (y1 + 2), z1, "west"))\(mineCoords(x2, (y2 + 2), z2, "west")) minecraft:air\r"
            
        }
        
        // back right tower ledge
        
        x1 = xr + 1
        x2 = x1 - 9
        
        y1 = yu - 12
        y2 = y1
        
        z1 = zb + 2
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        
        x1 = x2
        
        z1 = z2 - 1
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        
        // back right tower rim
        
        x1 = xr + 1
        x2 = x1 - 9
        
        y1 = yu + 6
        y2 = y1
        
        z1 = zb + 2
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        
        x1 = x2
        
        z1 = z2 - 1
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        
        // back right tower peaks
        
        y1 = yu + 7
        y2 = y1
        
        z1 = zb + 2
        z2 = z1
        
        for x1 in stride( from: (xr), to: (xr - 9), by: -2 ) {
            
            x2 = x1
            
            mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_wall\r"
            mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_wall\r"
            mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_wall\r"
            mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_wall\r"
            
        }
        
        // back left arches
        
        x1 = xl + 6
        x2 = x1 - 2
        
        y1 = yu - 6
        y2 = y1 + 4
        
        z1 = zb + 1
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:air\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:air\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:air\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:air\r"
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, (z1 - 1), "north"))\(mineCoords(x2, y2, (z2 - 1), "north")) minecraft:brown_terracotta\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, (z1 - 1), "south"))\(mineCoords(x2, y2, (z2 - 1), "south")) minecraft:brown_terracotta\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, (z1 - 1), "east"))\(mineCoords(x2, y2, (z2 - 1), "east")) minecraft:brown_terracotta\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, (z1 - 1), "west"))\(mineCoords(x2, y2, (z2 - 1), "west")) minecraft:brown_terracotta\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y2, z1, "north")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y2, z1, "south")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y2, z1, "east")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y2, z1, "west")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x2, y2, z1, "north")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x2, y2, z1, "south")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x2, y2, z1, "east")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x2, y2, z1, "west")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        
        x1 = x2 - 2
        x2 = x1 - 2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:air\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:air\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:air\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:air\r"
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, (z1 - 1), "north"))\(mineCoords(x2, y2, (z2 - 1), "north")) minecraft:brown_terracotta\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, (z1 - 1), "south"))\(mineCoords(x2, y2, (z2 - 1), "south")) minecraft:brown_terracotta\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, (z1 - 1), "east"))\(mineCoords(x2, y2, (z2 - 1), "east")) minecraft:brown_terracotta\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, (z1 - 1), "west"))\(mineCoords(x2, y2, (z2 - 1), "west")) minecraft:brown_terracotta\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y2, z1, "north")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y2, z1, "south")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y2, z1, "east")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y2, z1, "west")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x2, y2, z1, "north")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x2, y2, z1, "south")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x2, y2, z1, "east")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x2, y2, z1, "west")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        
        x1 = xl + 7
        x2 = x1 - 8
        
        y1 = yu - 7
        y2 = y1
        
        z1 = zb + 1
        z2 = z1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:cut_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:cut_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:cut_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:cut_red_sandstone\r"
        
        // back left tower windows
        
        y1 = yu + 2
        y2 = y1
        
        z1 = zb + 1
        z2 = z1
        
        for x1 in stride( from: (xl + 6), to: (xl - 1), by: -2 ) {
            
            x2 = x1
            
            mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:air\r"
            mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:air\r"
            mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:air\r"
            mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:air\r"
            
            mcfunctionnorth += "fill\(mineCoords(x1, (y1 + 2), z1, "north"))\(mineCoords(x2, (y2 + 2), z2, "north")) minecraft:air\r"
            mcfunctionsouth += "fill\(mineCoords(x1, (y1 + 2), z1, "south"))\(mineCoords(x2, (y2 + 2), z2, "south")) minecraft:air\r"
            mcfunctioneast += "fill\(mineCoords(x1, (y1 + 2), z1, "east"))\(mineCoords(x2, (y2 + 2), z2, "east")) minecraft:air\r"
            mcfunctionwest += "fill\(mineCoords(x1, (y1 + 2), z1, "west"))\(mineCoords(x2, (y2 + 2), z2, "west")) minecraft:air\r"
            
        }
        
        // back left tower ledge
        
        x1 = xl + 8
        x2 = x1
        
        y1 = yu - 12
        y2 = y1
        
        z1 = zb + 1
        z2 = z1 + 1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        
        x1 = x2 - 1
        x2 = x1 - 9
        
        z1 = z2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        
        // back left tower rim
        
        x1 = xl + 8
        x2 = x1
        
        y1 = yu + 6
        y2 = y1
        
        z1 = zb + 1
        z2 = z1 + 1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        
        x1 = x2 - 1
        x2 = x1 - 9
        
        z1 = z2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        
        // back left tower peaks
        
        y1 = yu + 7
        y2 = y1
        
        z1 = zb + 2
        z2 = z1
        
        for x1 in stride( from: (xl + 8), to: (xl - 3), by: -2 ) {
            
            x2 = x1
            
            mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_wall\r"
            mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_wall\r"
            mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_wall\r"
            mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_wall\r"
            
        }
        
        // ---------------
        // -- LEFT WALL --
        // ---------------
        
        // left back tower arches
        
        z1 = zb
        z2 = z1 - 2
        
        y1 = yu - 6
        y2 = y1 + 4
        
        x1 = xl - 1
        x2 = x1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:air\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:air\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:air\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:air\r"
        
        mcfunctionnorth += "fill\(mineCoords((x1 + 1), y1, z1, "north"))\(mineCoords((x2 + 1), y2, z2, "north")) minecraft:brown_terracotta\r"
        mcfunctionsouth += "fill\(mineCoords((x1 + 1), y1, z1, "south"))\(mineCoords((x2 + 1), y2, z2, "south")) minecraft:brown_terracotta\r"
        mcfunctioneast += "fill\(mineCoords((x1 + 1), y1, z1, "east"))\(mineCoords((x2 + 1), y2, z2, "east")) minecraft:brown_terracotta\r"
        mcfunctionwest += "fill\(mineCoords((x1 + 1), y1, z1, "west"))\(mineCoords((x2 + 1), y2, z2, "west")) minecraft:brown_terracotta\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y2, z1, "north")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y2, z1, "south")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y2, z1, "east")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y2, z1, "west")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x2, y2, z2, "north")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x2, y2, z2, "south")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x2, y2, z2, "east")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x2, y2, z2, "west")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        
        z1 = z2 - 2
        z2 = z1 - 2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:air\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:air\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:air\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:air\r"
        
        mcfunctionnorth += "fill\(mineCoords((x1 + 1), y1, z1, "north"))\(mineCoords((x2 + 1), y2, z2, "north")) minecraft:brown_terracotta\r"
        mcfunctionsouth += "fill\(mineCoords((x1 + 1), y1, z1, "south"))\(mineCoords((x2 + 1), y2, z2, "south")) minecraft:brown_terracotta\r"
        mcfunctioneast += "fill\(mineCoords((x1 + 1), y1, z1, "east"))\(mineCoords((x2 + 1), y2, z2, "east")) minecraft:brown_terracotta\r"
        mcfunctionwest += "fill\(mineCoords((x1 + 1), y1, z1, "west"))\(mineCoords((x2 + 1), y2, z2, "west")) minecraft:brown_terracotta\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y2, z1, "north")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y2, z1, "south")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y2, z1, "east")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y2, z1, "west")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x2, y2, z2, "north")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x2, y2, z2, "south")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x2, y2, z2, "east")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x2, y2, z2, "west")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        
        z1 = zb + 1
        z2 = z1 - 8
        
        y1 = yu - 7
        y2 = y1
        
        x1 = xl - 1
        x2 = x1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:cut_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:cut_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:cut_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:cut_red_sandstone\r"
        
        // left back tower windows
        
        y1 = yu + 2
        y2 = y1
        
        x1 = xl - 1
        x2 = x1
        
        for z1 in stride( from: zb, to: (zb - 7), by: -2 ) {
            
            z2 = z1
            
            mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:air\r"
            mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:air\r"
            mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:air\r"
            mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:air\r"
            
            mcfunctionnorth += "fill\(mineCoords(x1, (y1 + 2), z1, "north"))\(mineCoords(x2, (y2 + 2), z2, "north")) minecraft:air\r"
            mcfunctionsouth += "fill\(mineCoords(x1, (y1 + 2), z1, "south"))\(mineCoords(x2, (y2 + 2), z2, "south")) minecraft:air\r"
            mcfunctioneast += "fill\(mineCoords(x1, (y1 + 2), z1, "east"))\(mineCoords(x2, (y2 + 2), z2, "east")) minecraft:air\r"
            mcfunctionwest += "fill\(mineCoords(x1, (y1 + 2), z1, "west"))\(mineCoords(x2, (y2 + 2), z2, "west")) minecraft:air\r"
            
        }
        
        // left back tower ledge
        
        z1 = zb + 1
        z2 = z1 - 9
        
        y1 = yu - 12
        y2 = y1
        
        x1 = xl - 2
        x2 = x1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        
        z1 = z2
        
        x1 = x2 + 1
        x2 = x1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        
        // left back tower rim
        
        z1 = zb + 1
        z2 = z1 - 9
        
        y1 = yu + 6
        y2 = y1
        
        x1 = xl - 2
        x2 = x1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        
        z1 = z2
        
        x1 = x2 + 1
        x2 = x1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        
        // left back tower peaks
        
        y1 = yu + 7
        y2 = y1
        
        x1 = xl - 2
        x2 = x1
        
        for z1 in stride( from: (zb), to: (zb - 9), by: -2 ) {
            
            z2 = z1
            
            mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_wall\r"
            mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_wall\r"
            mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_wall\r"
            mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_wall\r"
            
        }
        
        // left front tower arches
        
        z1 = zf + 6
        z2 = z1 - 2
        
        y1 = yu - 6
        y2 = y1 + 4
        
        x1 = xl - 1
        x2 = x1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:air\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:air\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:air\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:air\r"
        
        mcfunctionnorth += "fill\(mineCoords((x1 + 1), y1, z1, "north"))\(mineCoords((x2 + 1), y2, z2, "north")) minecraft:brown_terracotta\r"
        mcfunctionsouth += "fill\(mineCoords((x1 + 1), y1, z1, "south"))\(mineCoords((x2 + 1), y2, z2, "south")) minecraft:brown_terracotta\r"
        mcfunctioneast += "fill\(mineCoords((x1 + 1), y1, z1, "east"))\(mineCoords((x2 + 1), y2, z2, "east")) minecraft:brown_terracotta\r"
        mcfunctionwest += "fill\(mineCoords((x1 + 1), y1, z1, "west"))\(mineCoords((x2 + 1), y2, z2, "west")) minecraft:brown_terracotta\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y2, z1, "north")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y2, z1, "south")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y2, z1, "east")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y2, z1, "west")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x2, y2, z2, "north")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x2, y2, z2, "south")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x2, y2, z2, "east")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x2, y2, z2, "west")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        
        z1 = z2 - 2
        z2 = z1 - 2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:air\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:air\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:air\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:air\r"
        
        mcfunctionnorth += "fill\(mineCoords((x1 + 1), y1, z1, "north"))\(mineCoords((x2 + 1), y2, z2, "north")) minecraft:brown_terracotta\r"
        mcfunctionsouth += "fill\(mineCoords((x1 + 1), y1, z1, "south"))\(mineCoords((x2 + 1), y2, z2, "south")) minecraft:brown_terracotta\r"
        mcfunctioneast += "fill\(mineCoords((x1 + 1), y1, z1, "east"))\(mineCoords((x2 + 1), y2, z2, "east")) minecraft:brown_terracotta\r"
        mcfunctionwest += "fill\(mineCoords((x1 + 1), y1, z1, "west"))\(mineCoords((x2 + 1), y2, z2, "west")) minecraft:brown_terracotta\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y2, z1, "north")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y2, z1, "south")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y2, z1, "east")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y2, z1, "west")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x2, y2, z2, "north")) minecraft:smooth_red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionsouth += "setblock\(mineCoords(x2, y2, z2, "south")) minecraft:smooth_red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctioneast += "setblock\(mineCoords(x2, y2, z2, "east")) minecraft:smooth_red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionwest += "setblock\(mineCoords(x2, y2, z2, "west")) minecraft:smooth_red_sandstone_stairs[facing=east,half=top]\r"
        
        z1 = zf + 7
        z2 = z1 - 8
        
        y1 = yu - 7
        y2 = y1
        
        x1 = xl - 1
        x2 = x1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:cut_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:cut_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:cut_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:cut_red_sandstone\r"
        
        // left front tower windows
        
        y1 = yu + 2
        y2 = y1
        
        x1 = xl - 1
        x2 = x1
        
        for z1 in stride( from: (zf + 6), to: (zf - 1), by: -2 ) {
            
            z2 = z1
            
            mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:air\r"
            mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:air\r"
            mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:air\r"
            mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:air\r"
            
            mcfunctionnorth += "fill\(mineCoords(x1, (y1 + 2), z1, "north"))\(mineCoords(x2, (y2 + 2), z2, "north")) minecraft:air\r"
            mcfunctionsouth += "fill\(mineCoords(x1, (y1 + 2), z1, "south"))\(mineCoords(x2, (y2 + 2), z2, "south")) minecraft:air\r"
            mcfunctioneast += "fill\(mineCoords(x1, (y1 + 2), z1, "east"))\(mineCoords(x2, (y2 + 2), z2, "east")) minecraft:air\r"
            mcfunctionwest += "fill\(mineCoords(x1, (y1 + 2), z1, "west"))\(mineCoords(x2, (y2 + 2), z2, "west")) minecraft:air\r"
            
        }
        
        // left front tower ledge
        
        z1 = zf + 8
        z2 = z1
        
        y1 = yu - 12
        y2 = y1
        
        x1 = xl - 1
        x2 = x1 - 1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        
        z1 = z2 - 1
        z2 = z1 - 8
        
        x1 = x2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        
        // left front tower rim
        
        z1 = zf + 8
        z2 = z1
        
        y1 = yu + 6
        y2 = y1
        
        x1 = xl - 1
        x2 = x1 - 1
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        
        z1 = z2 - 1
        z2 = z1 - 8
        
        x1 = x2
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        
        // left front tower peaks
        
        y1 = yu + 7
        y2 = y1
        
        x1 = xl - 2
        x2 = x1
        
        for z1 in stride( from: (zf + 8), to: (zf - 3), by: -2 ) {
            
            z2 = z1
            
            mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:red_sandstone_wall\r"
            mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:red_sandstone_wall\r"
            mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:red_sandstone_wall\r"
            mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:red_sandstone_wall\r"
            
        }
        
        // entrance
        
        x1 = ((entryrow - 1) * cellsizex) + xoffset
        x2 = x1 + cellsizex
        
        y1 = 1 + yoffset
        y2 = y1 + cellsizey
        
        z1 = zoffset - 2
        z2 = z1
        
        // door frame
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x2, y2, z2, "north")) minecraft:cut_red_sandstone\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x2, y2, z2, "south")) minecraft:cut_red_sandstone\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x2, y2, z2, "east")) minecraft:cut_red_sandstone\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x2, y2, z2, "west")) minecraft:cut_red_sandstone\r"
        
        mcfunctionnorth += "fill\(mineCoords((x1 + 1), y1, z1, "north"))\(mineCoords((x2 - 1), (y2 - 2), z2, "north")) minecraft:air\r"
        mcfunctionsouth += "fill\(mineCoords((x1 + 1), y1, z1, "south"))\(mineCoords((x2 - 1), (y2 - 2), z2, "south")) minecraft:air\r"
        mcfunctioneast += "fill\(mineCoords((x1 + 1), y1, z1, "east"))\(mineCoords((x2 - 1), (y2 - 2), z2, "east")) minecraft:air\r"
        mcfunctionwest += "fill\(mineCoords((x1 + 1), y1, z1, "west"))\(mineCoords((x2 - 1), (y2 - 2), z2, "west")) minecraft:air\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x1, (y1 + 3), z1, "north")) minecraft:chiseled_red_sandstone\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, (y1 + 3), z1, "south")) minecraft:chiseled_red_sandstone\r"
        mcfunctioneast += "setblock\(mineCoords(x1, (y1 + 3), z1, "east")) minecraft:chiseled_red_sandstone\r"
        mcfunctionwest += "setblock\(mineCoords(x1, (y1 + 3), z1, "west")) minecraft:chiseled_red_sandstone\r"
        
        mcfunctionnorth += "setblock\(mineCoords(x2, (y1 + 3), z1, "north")) minecraft:chiseled_red_sandstone\r"
        mcfunctionsouth += "setblock\(mineCoords(x2, (y1 + 3), z1, "south")) minecraft:chiseled_red_sandstone\r"
        mcfunctioneast += "setblock\(mineCoords(x2, (y1 + 3), z1, "east")) minecraft:chiseled_red_sandstone\r"
        mcfunctionwest += "setblock\(mineCoords(x2, (y1 + 3), z1, "west")) minecraft:chiseled_red_sandstone\r"
        
        // door base
        
        mcfunctionnorth += "fill\(mineCoords((x1 - 1), y1, z1, "north"))\(mineCoords((x1 - 1), y1, (z1 - 1), "north")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords((x1 - 1), y1, z1, "south"))\(mineCoords((x1 - 1), y1, (z1 - 1), "south")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords((x1 - 1), y1, z1, "east"))\(mineCoords((x1 - 1), y1, (z1 - 1), "east")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords((x1 - 1), y1, z1, "west"))\(mineCoords((x1 - 1), y1, (z1 - 1), "west")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        
        mcfunctionnorth += "fill\(mineCoords(x1, y1, (z1 - 1), "north"))\(mineCoords(x1, y1, (z1 - 1), "north")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y1, (z1 - 1), "south"))\(mineCoords(x1, y1, (z1 - 1), "south")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y1, (z1 - 1), "east"))\(mineCoords(x1, y1, (z1 - 1), "east")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y1, (z1 - 1), "west"))\(mineCoords(x1, y1, (z1 - 1), "west")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        
        mcfunctionnorth += "fill\(mineCoords(x2, y1, (z1 - 1), "north"))\(mineCoords((x2 + 1), y1, (z1 - 1), "north")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords(x2, y1, (z1 - 1), "south"))\(mineCoords((x2 + 1), y1, (z1 - 1), "south")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords(x2, y1, (z1 - 1), "east"))\(mineCoords((x2 + 1), y1, (z1 - 1), "east")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords(x2, y1, (z1 - 1), "west"))\(mineCoords((x2 + 1), y1, (z1 - 1), "west")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        
        mcfunctionnorth += "fill\(mineCoords((x2 + 1), y1, z1, "north"))\(mineCoords((x2 + 1), y1, z1, "north")) minecraft:red_sandstone_stairs[facing=west,half=bottom]\r"
        mcfunctionsouth += "fill\(mineCoords((x2 + 1), y1, z1, "south"))\(mineCoords((x2 + 1), y1, z1, "south")) minecraft:red_sandstone_stairs[facing=east,half=bottom]\r"
        mcfunctioneast += "fill\(mineCoords((x2 + 1), y1, z1, "east"))\(mineCoords((x2 + 1), y1, z1, "east")) minecraft:red_sandstone_stairs[facing=north,half=bottom]\r"
        mcfunctionwest += "fill\(mineCoords((x2 + 1), y1, z1, "west"))\(mineCoords((x2 + 1), y1, z1, "west")) minecraft:red_sandstone_stairs[facing=south,half=bottom]\r"
        
        // door top
        
        mcfunctionnorth += "fill\(mineCoords((x1 - 1), y2, z1, "north"))\(mineCoords((x1 - 1), y2, (z1 - 1), "north")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords((x1 - 1), y2, z1, "south"))\(mineCoords((x1 - 1), y2, (z1 - 1), "south")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctioneast += "fill\(mineCoords((x1 - 1), y2, z1, "east"))\(mineCoords((x1 - 1), y2, (z1 - 1), "east")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctionwest += "fill\(mineCoords((x1 - 1), y2, z1, "west"))\(mineCoords((x1 - 1), y2, (z1 - 1), "west")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        
        mcfunctionnorth += "fill\(mineCoords(x1, y2, (z1 - 1), "north"))\(mineCoords((x2 + 1), y2, (z1 - 1), "north")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords(x1, y2, (z1 - 1), "south"))\(mineCoords((x2 + 1), y2, (z1 - 1), "south")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        mcfunctioneast += "fill\(mineCoords(x1, y2, (z1 - 1), "east"))\(mineCoords((x2 + 1), y2, (z1 - 1), "east")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctionwest += "fill\(mineCoords(x1, y2, (z1 - 1), "west"))\(mineCoords((x2 + 1), y2, (z1 - 1), "west")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        
        mcfunctionnorth += "fill\(mineCoords((x2 + 1), y2, z1, "north"))\(mineCoords((x2 + 1), y2, z1, "north")) minecraft:red_sandstone_stairs[facing=west,half=top]\r"
        mcfunctionsouth += "fill\(mineCoords((x2 + 1), y2, z1, "south"))\(mineCoords((x2 + 1), y2, z1, "south")) minecraft:red_sandstone_stairs[facing=east,half=top]\r"
        mcfunctioneast += "fill\(mineCoords((x2 + 1), y2, z1, "east"))\(mineCoords((x2 + 1), y2, z1, "east")) minecraft:red_sandstone_stairs[facing=north,half=top]\r"
        mcfunctionwest += "fill\(mineCoords((x2 + 1), y2, z1, "west"))\(mineCoords((x2 + 1), y2, z1, "west")) minecraft:red_sandstone_stairs[facing=south,half=top]\r"
        
    }
    // end of ksar skin
    
    print("Generating structure")

    // init structures to compare while building
    let m_shaft = ["w_up": false, "w_down": false, "w_left": true, "w_right": true, "w_front": true, "w_back": true]
    let m_cap = ["w_up": true, "w_down": false, "w_left": true, "w_right": true, "w_front": true, "w_back": true]
    let m_pit = ["w_up": false, "w_down": true, "w_left": true, "w_right": true, "w_front": true, "w_back": true]
    let m_endl = ["w_up": true, "w_down": true, "w_left": true, "w_right": false, "w_front": true, "w_back": true]
    let m_endr = ["w_up": true, "w_down": true, "w_left": false, "w_right": true, "w_front": true, "w_back": true]
    let m_endf = ["w_up": true, "w_down": true, "w_left": true, "w_right": true, "w_front": true, "w_back": false]
    let m_endb = ["w_up": true, "w_down": true, "w_left": true, "w_right": true, "w_front": false, "w_back": true]
    let m_turnbl = ["w_up": true, "w_down": true, "w_left": false, "w_right": true, "w_front": true, "w_back": false]
    let m_turnbr = ["w_up": true, "w_down": true, "w_left": true, "w_right": false, "w_front": true, "w_back": false]
    let m_turnfl = ["w_up": true, "w_down": true, "w_left": false, "w_right": true, "w_front": false, "w_back": true]
    let m_turnfr = ["w_up": true, "w_down": true, "w_left": true, "w_right": false, "w_front": false, "w_back": true]
    let m_empty = ["w_up": true, "w_down": true, "w_left": true, "w_right": true, "w_front": true, "w_back": true]

    var emptycount: Int = 0
    var material: String
    var mazecell: [String: Int]
    
    for ml in 1...numlevels {

        material = BuildMaterial(ml, numlevels)
        
        yd = ((ml - 1) * cellsizey) + yoffset
        
        if ( ml == numlevels ) && ( roofcovered == true ) {
            yu = (yd + cellsizey)
        } else {
            yu = (yd + cellsizey - 1)
        }

        for mr in 1...numrows {

            xl = ((mr - 1) * cellsizex) + xoffset
            
            if (mr == numrows) {
              xr = (xl + cellsizex)
            } else {
              xr = (xl + cellsizex - 1)
            }

            for mc in 1...numcolumns {

                mazecell = ["level": ml, "row": mr, "column": mc]

                zb = ((mc - 1) * cellsizez) + zoffset

                if ( mc == numcolumns ) {
                    zf = zb + cellsizez
                } else {
                    zf = zb + cellsizez - 1
                }
                
                m_cell = mazegrid[ml-1][mr-1][mc-1]
                
                if ( m_cell == m_empty ) {
                    emptycount = emptycount + 1
                }
                
                mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north")) minecraft:air\r"
                mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south")) minecraft:air\r"
                mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east")) minecraft:air\r"
                mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west")) minecraft:air\r"
                
                if ( m_cell["w_left"] == true ) {
                    
                    mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xl, yu, zf, "north"))\(material)\r"
                    mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xl, yu, zf, "south"))\(material)\r"
                    mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xl, yu, zf, "east"))\(material)\r"
                    mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xl, yu, zf, "west"))\(material)\r"
                    
                } else {
                    
                    mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xl, yu, zb, "north"))\(material)\r"
                    mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xl, yu, zb, "south"))\(material)\r"
                    mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xl, yu, zb, "east"))\(material)\r"
                    mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xl, yu, zb, "west"))\(material)\r"
                    
                    if ( mc == numcolumns ) {
                        
                        mcfunctionnorth += "fill\(mineCoords(xl, yd, zf, "north"))\(mineCoords(xl, yu, zf, "north"))\(material)\r"
                        mcfunctionsouth += "fill\(mineCoords(xl, yd, zf, "south"))\(mineCoords(xl, yu, zf, "south"))\(material)\r"
                        mcfunctioneast += "fill\(mineCoords(xl, yd, zf, "east"))\(mineCoords(xl, yu, zf, "east"))\(material)\r"
                        mcfunctionwest += "fill\(mineCoords(xl, yd, zf, "west"))\(mineCoords(xl, yu, zf, "west"))\(material)\r"
                    
                    }
                }
                
                if ( mr == numrows ) {
                    
                    if ( m_cell["w_right"] == true ) {
                        
                        mcfunctionnorth += "fill\(mineCoords(xr, yd, zb, "north"))\(mineCoords(xr, yu, zf, "north"))\(material)\r"
                        mcfunctionsouth += "fill\(mineCoords(xr, yd, zb, "south"))\(mineCoords(xr, yu, zf, "south"))\(material)\r"
                        mcfunctioneast += "fill\(mineCoords(xr, yd, zb, "east"))\(mineCoords(xr, yu, zf, "east"))\(material)\r"
                        mcfunctionwest += "fill\(mineCoords(xr, yd, zb, "west"))\(mineCoords(xr, yu, zf, "west"))\(material)\r"
                        
                    } else {
                        
                        mcfunctionnorth += "fill\(mineCoords(xr, yd, zb, "north"))\(mineCoords(xr, yu, zb, "north"))\(material)\r"
                        mcfunctionsouth += "fill\(mineCoords(xr, yd, zb, "south"))\(mineCoords(xr, yu, zb, "south"))\(material)\r"
                        mcfunctioneast += "fill\(mineCoords(xr, yd, zb, "east"))\(mineCoords(xr, yu, zb, "east"))\(material)\r"
                        mcfunctionwest += "fill\(mineCoords(xr, yd, zb, "west"))\(mineCoords(xr, yu, zb, "west"))\(material)\r"
                        
                        if ( mc == numcolumns ) {
                        
                            mcfunctionnorth += "fill\(mineCoords(xr, yd, zf, "north"))\(mineCoords(xr, yu, zf, "north"))\(material)\r"
                            mcfunctionsouth += "fill\(mineCoords(xr, yd, zf, "south"))\(mineCoords(xr, yu, zf, "south"))\(material)\r"
                            mcfunctioneast += "fill\(mineCoords(xr, yd, zf, "east"))\(mineCoords(xr, yu, zf, "east"))\(material)\r"
                            mcfunctionwest += "fill\(mineCoords(xr, yd, zf, "west"))\(mineCoords(xr, yu, zf, "west"))\(material)\r"
        
                        }
                    }
                }
                
                if ( mc == numcolumns ) {
                    
                    if ( m_cell["w_front"] == true ) {
                        
                        mcfunctionnorth += "fill\(mineCoords((xl + 1), yd, zf, "north"))\(mineCoords(xr, yu, zf, "north"))\(material)\r"
                        mcfunctionsouth += "fill\(mineCoords((xl + 1), yd, zf, "south"))\(mineCoords(xr, yu, zf, "south"))\(material)\r"
                        mcfunctioneast += "fill\(mineCoords((xl + 1), yd, zf, "east"))\(mineCoords(xr, yu, zf, "east"))\(material)\r"
                        mcfunctionwest += "fill\(mineCoords((xl + 1), yd, zf, "west"))\(mineCoords(xr, yu, zf, "west"))\(material)\r"
                    
                    }
                
                }
            
                if ( m_cell["w_back"] == true ) {
            
                    mcfunctionnorth += "fill\(mineCoords((xl + 1), yd, zb, "north"))\(mineCoords(xr, yu, zb, "north"))\(material)\r"
                    mcfunctionsouth += "fill\(mineCoords((xl + 1), yd, zb, "south"))\(mineCoords(xr, yu, zb, "south"))\(material)\r"
                    mcfunctioneast += "fill\(mineCoords((xl + 1), yd, zb, "east"))\(mineCoords(xr, yu, zb, "east"))\(material)\r"
                    mcfunctionwest += "fill\(mineCoords((xl + 1), yd, zb, "west"))\(mineCoords(xr, yu, zb, "west"))\(material)\r"
            
                }
                
                if ( m_cell["w_down"] == true ) {
                    
                    mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yd, zf, "north"))\(material)\r"
                    mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yd, zf, "south"))\(material)\r"
                    mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yd, zf, "east"))\(material)\r"
                    mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yd, zf, "west"))\(material)\r"
                    
                } else {
                    
                    if !((m_cell == m_cap) || (m_cell == m_shaft)) {
                        
                        mcfunctionnorth += "fill\(mineCoords(xl, yd, zb, "north"))\(mineCoords(xr, yd, zf, "north"))\(material)\r"
                        mcfunctionsouth += "fill\(mineCoords(xl, yd, zb, "south"))\(mineCoords(xr, yd, zf, "south"))\(material)\r"
                        mcfunctioneast += "fill\(mineCoords(xl, yd, zb, "east"))\(mineCoords(xr, yd, zf, "east"))\(material)\r"
                        mcfunctionwest += "fill\(mineCoords(xl, yd, zb, "west"))\(mineCoords(xr, yd, zf, "west"))\(material)\r"
                        
                    } else {
                        
                        x1 = xl + (cellsizex / 2)
                        y1 = yd
                        z1 = zb + ((cellsizez / 2) + 1)
                        
                        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north"))\(material)\r"
                        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south"))\(material)\r"
                        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east"))\(material)\r"
                        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west"))\(material)\r"
                        
                    }
                    
                    x1 = xl + (cellsizex / 2)
                    y1 = yd
                    z1 = zb + (cellsizez / 2)
                    
                    mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:ladder[facing=south]\r"
                    mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:ladder[facing=north]\r"
                    mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:ladder[facing=west]\r"
                    mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:ladder[facing=east]\r"
                
                }
                
                if ( m_cell["w_up"] == true ) {
                    
                    if ( ml == numlevels ) && ( roofcovered == true ) {
                        
                        mcfunctionnorth += "fill\(mineCoords(xl, yu, zb, "north"))\(mineCoords(xr, yu, zf, "north"))\(material)\r"
                        mcfunctionsouth += "fill\(mineCoords(xl, yu, zb, "south"))\(mineCoords(xr, yu, zf, "south"))\(material)\r"
                        mcfunctioneast += "fill\(mineCoords(xl, yu, zb, "east"))\(mineCoords(xr, yu, zf, "east"))\(material)\r"
                        mcfunctionwest += "fill\(mineCoords(xl, yu, zb, "west"))\(mineCoords(xr, yu, zf, "west"))\(material)\r"
    
                    }

                    if ( m_cell == m_cap ) {
                        
                        x1 = xl + (cellsizex / 2)
                        y1 = yd + 1
                        y2 = yd + (cellsizey - 1)
                        z1 = zb + ((cellsizez / 2) + 1)
                        z2 = zb + (cellsizez / 2)
                        
                        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x1, y2, z1, "north"))\(material)\r"
                        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x1, y2, z1, "south"))\(material)\r"
                        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x1, y2, z1, "east"))\(material)\r"
                        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x1, y2, z1, "west"))\(material)\r"
                        
                        mcfunctionnorth += "fill\(mineCoords(x1, y1, z2, "north"))\(mineCoords(x1, y2, z2, "north")) minecraft:ladder[facing=south]\r"
                        mcfunctionsouth += "fill\(mineCoords(x1, y1, z2, "south"))\(mineCoords(x1, y2, z2, "south")) minecraft:ladder[facing=north]\r"
                        mcfunctioneast += "fill\(mineCoords(x1, y1, z2, "east"))\(mineCoords(x1, y2, z2, "east")) minecraft:ladder[facing=west]\r"
                        mcfunctionwest += "fill\(mineCoords(x1, y1, z2, "west"))\(mineCoords(x1, y2, z2, "west")) minecraft:ladder[facing=east]\r"
                    
                    }

                } else {

                    if ( mazecell == mazeend ) && ( mazeexit == "roof" ) {

                        if ( ml == numlevels) && ( roofcovered == true ) {

                            mcfunctionnorth += "fill\(mineCoords(xl, yu, zb, "north"))\(mineCoords(xr, yu, zf, "north"))\(material)\r"
                            mcfunctionsouth += "fill\(mineCoords(xl, yu, zb, "south"))\(mineCoords(xr, yu, zf, "south"))\(material)\r"
                            mcfunctioneast += "fill\(mineCoords(xl, yu, zb, "east"))\(mineCoords(xr, yu, zf, "east"))\(material)\r"
                            mcfunctionwest += "fill\(mineCoords(xl, yu, zb, "west"))\(mineCoords(xr, yu, zf, "west"))\(material)\r"

                        }

                        x1 = xl + (cellsizex / 2)
                        y1 = yd + 1
                        y2 = yd + (cellsizey - 1)
                        z1 = zb + ((cellsizez / 2) + 1)
                        z2 = zb + (cellsizez / 2)

                        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x1, y2, z1, "north"))\(material)\r"
                        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x1, y2, z1, "south"))\(material)\r"
                        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x1, y2, z1, "east"))\(material)\r"
                        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x1, y2, z1, "west"))\(material)\r"

                        if ( mazeskin == "moroccan" ) {

                            mcfunctionnorth += "fill\(mineCoords(x1, y1, z2, "north"))\(mineCoords(x1, (y2 + 2), z2, "north")) minecraft:ladder[facing=south]\r"
                            mcfunctionsouth += "fill\(mineCoords(x1, y1, z2, "south"))\(mineCoords(x1, (y2 + 2), z2, "south")) minecraft:ladder[facing=north]\r"
                            mcfunctioneast += "fill\(mineCoords(x1, y1, z2, "east"))\(mineCoords(x1, (y2 + 2), z2, "east")) minecraft:ladder[facing=west]\r"
                            mcfunctionwest += "fill\(mineCoords(x1, y1, z2, "west"))\(mineCoords(x1, (y2 + 2), z2, "west")) minecraft:ladder[facing=east]\r"

                        } else {

                            mcfunctionnorth += "fill\(mineCoords(x1, y1, z2, "north"))\(mineCoords(x1, (y2 + 1), z2, "north")) minecraft:ladder[facing=south]\r"
                            mcfunctionsouth += "fill\(mineCoords(x1, y1, z2, "south"))\(mineCoords(x1, (y2 + 1), z2, "south")) minecraft:ladder[facing=north]\r"
                            mcfunctioneast += "fill\(mineCoords(x1, y1, z2, "east"))\(mineCoords(x1, (y2 + 1), z2, "east")) minecraft:ladder[facing=west]\r"
                            mcfunctionwest += "fill\(mineCoords(x1, y1, z2, "west"))\(mineCoords(x1, (y2 + 1), z2, "west")) minecraft:ladder[facing=east]\r"

                        }

                    } else {

                        x1 = xl + (cellsizex / 2)
                        y1 = yd + 1
                        y2 = yd + (cellsizey - 1)
                        z1 = zb + ((cellsizez / 2) + 1)
                        z2 = zb + (cellsizez / 2)

                        mcfunctionnorth += "fill\(mineCoords(x1, y1, z1, "north"))\(mineCoords(x1, y2, z1, "north"))\(material)\r"
                        mcfunctionsouth += "fill\(mineCoords(x1, y1, z1, "south"))\(mineCoords(x1, y2, z1, "south"))\(material)\r"
                        mcfunctioneast += "fill\(mineCoords(x1, y1, z1, "east"))\(mineCoords(x1, y2, z1, "east"))\(material)\r"
                        mcfunctionwest += "fill\(mineCoords(x1, y1, z1, "west"))\(mineCoords(x1, y2, z1, "west"))\(material)\r"

                        mcfunctionnorth += "fill\(mineCoords(x1, y1, z2, "north"))\(mineCoords(x1, y2, z2, "north")) minecraft:ladder[facing=south]\r"
                        mcfunctionsouth += "fill\(mineCoords(x1, y1, z2, "south"))\(mineCoords(x1, y2, z2, "south")) minecraft:ladder[facing=north]\r"
                        mcfunctioneast += "fill\(mineCoords(x1, y1, z2, "east"))\(mineCoords(x1, y2, z2, "east")) minecraft:ladder[facing=west]\r"
                        mcfunctionwest += "fill\(mineCoords(x1, y1, z2, "west"))\(mineCoords(x1, y2, z2, "west")) minecraft:ladder[facing=east]\r"

                    }
                }
            }
        }
    }
    
    print("Checking lighting")

    if ( lighting == true ) {
        
        print("Generating lighting")

        for ml in 1...numlevels {
    
            yd = ((ml - 1) * cellsizey) + yoffset
    
            for mr in 1...numrows {
    
                xl = ((mr - 1) * cellsizex) + xoffset
    
                for mc in 1...numcolumns {
    
                    zb = ((mc - 1) * cellsizez) + zoffset
                    
                    m_cell = mazegrid[ml-1][mr-1][mc-1]
                    
                    if ( m_cell == m_cap ) || ( m_cell == m_pit ) {
                        
                        x1 = xl + (cellsizex / 2)
                        y1 = yd + (cellsizey - 1)
                        z1 = zb + 1
                        
                        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:wall_torch[facing=north]\r"
                        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:wall_torch[facing=south]\r"
                        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:wall_torch[facing=east]\r"
                        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:wall_torch[facing=west]\r"
                        
                    }
                    
                    if ( m_cell == m_endl ) {
                        
                        x1 = xl + 1
                        y1 = yd + (cellsizey - 1)
                        z1 = zb + (cellsizez / 2)
                        
                        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:wall_torch[facing=east]\r"
                        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:wall_torch[facing=west]\r"
                        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:wall_torch[facing=south]\r"
                        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:wall_torch[facing=north]\r"
                        
                    }
                    
                    if ( m_cell == m_endr ) {
                        
                        x1 = xl + (cellsizex - 1)
                        y1 = yd + (cellsizey - 1)
                        z1 = zb + (cellsizez / 2)
                        
                        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:wall_torch[facing=west]\r"
                        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:wall_torch[facing=east]\r"
                        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:wall_torch[facing=north]\r"
                        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:wall_torch[facing=south]\r"
                        
                    }
                    
                    if ( m_cell == m_endf ) {
                        
                        x1 = xl + (cellsizex / 2)
                        y1 = yd + (cellsizey - 1)
                        z1 = zb + (cellsizez - 1)
                        
                        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:wall_torch[facing=south]\r"
                        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:wall_torch[facing=north]\r"
                        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:wall_torch[facing=west]\r"
                        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:wall_torch[facing=east]\r"
                        
                    }
                    
                    if ( m_cell == m_endb ) {
                        
                        x1 = xl + (cellsizex / 2)
                        y1 = yd + (cellsizey - 1)
                        z1 = zb + 1
                        
                        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:wall_torch[facing=north]\r"
                        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:wall_torch[facing=south]\r"
                        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:wall_torch[facing=east]\r"
                        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:wall_torch[facing=west]\r"
                        
                    }
                    
                    if ( m_cell == m_turnfl ) || ( m_cell == m_turnfr ) {
                        
                        x1 = xl + (cellsizex / 2)
                        y1 = yd + (cellsizey - 1)
                        z1 = zb + 1
                        
                        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:wall_torch[facing=north]\r"
                        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:wall_torch[facing=south]\r"
                        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:wall_torch[facing=east]\r"
                        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:wall_torch[facing=west]\r"
                        
                    }
                    
                    if ( m_cell == m_turnbl ) || (m_cell == m_turnbr ) {
                        
                        x1 = xl + (cellsizex / 2)
                        y1 = yd + (cellsizey - 1)
                        z1 = zb + (cellsizez - 1)
                        
                        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:wall_torch[facing=south]\r"
                        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:wall_torch[facing=north]\r"
                        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:wall_torch[facing=west]\r"
                        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:wall_torch[facing=east]\r"
                        
                    }
                    
                    if ( m_cell["w_up"] == false ) && (!(m_cell == m_pit)) {
                        
                        if ( m_cell["w_front"] == false ) {
                            
                            x1 = xl + (cellsizex / 2)
                            y1 = yd + (cellsizey - 1)
                            z1 = zb + cellsizez
                            
                            mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:wall_torch[facing=north]\r"
                            mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:wall_torch[facing=south]\r"
                            mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:wall_torch[facing=east]\r"
                            mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:wall_torch[facing=west]\r"
                    
                        } else {
                    
                            if ( m_cell["w_back"] == true ) && (( m_cell["w_left"] == false ) || ( m_cell["w_right"] == false )) {
                                
                                x1 = xl + (cellsizex / 2)
                                y1 = yd + (cellsizey - 1)
                                z1 = zb + 1
                                
                                mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:wall_torch[facing=north]\r"
                                mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:wall_torch[facing=south]\r"
                                mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:wall_torch[facing=east]\r"
                                mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:wall_torch[facing=west]\r"
                                
                            }
                        }
                    }

                    if ( m_cell["w_down"] == false ) && (!((m_cell == m_cap) || (m_cell == m_shaft))) {
                    
                        if ( m_cell["w_back"] == true ) && (( m_cell["w_left"] == false ) || ( m_cell["w_right"] == false ) || ( m_cell["w_front"] == false )) {
                            
                            x1 = xl + (cellsizex / 2)
                            y1 = yd + (cellsizey - 1)
                            z1 = zb + 1
                            
                            mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north")) minecraft:wall_torch[facing=north]\r"
                            mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south")) minecraft:wall_torch[facing=south]\r"
                            mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east")) minecraft:wall_torch[facing=east]\r"
                            mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west")) minecraft:wall_torch[facing=west]\r"
    
                        }
                    }
                }
            }
        }
    }
    // end of lighting
    
    print("Adding signs")

    var northsign: String
    var southsign: String
    var eastsign: String
    var westsign: String

    if ( mazeskin == "moroccan" ) {
        
        x1 = (entryrow * cellsizex) + 2 + xoffset
        y1 = ((entrylevel - 1) * cellsizey) + 3 + yoffset
        z1 = -2 + zoffset
        
        northsign = " minecraft:acacia_wall_sign[facing=south]{Text2:\"{\\\"text\\\":\\\"\(mazesign)\(rndseedname)\\\"}\",Text3:\"{\\\"text\\\":\\\"Entrance\\\"}\"}"
        southsign = " minecraft:acacia_wall_sign[facing=north]{Text2:\"{\\\"text\\\":\\\"\(mazesign)\(rndseedname)\\\"}\",Text3:\"{\\\"text\\\":\\\"Entrance\\\"}\"}"
        eastsign = " minecraft:acacia_wall_sign[facing=west]{Text2:\"{\\\"text\\\":\\\"\(mazesign)\(rndseedname)\\\"}\",Text3:\"{\\\"text\\\":\\\"Entrance\\\"}\"}"
        westsign = " minecraft:acacia_wall_sign[facing=east]{Text2:\"{\\\"text\\\":\\\"\(mazesign)\(rndseedname)\\\"}\",Text3:\"{\\\"text\\\":\\\"Entrance\\\"}\"}"
    
    } else {
        
        x1 = (entryrow * cellsizex) + 1 + xoffset
        y1 = ((entrylevel - 1) * cellsizey) + 2 + yoffset
        z1 = -1 + zoffset
        
        northsign = " minecraft:oak_wall_sign[facing=south]{Text2:\"{\\\"text\\\":\\\"\(mazesign)\(rndseedname)\\\"}\",Text3:\"{\\\"text\\\":\\\"Entrance\\\"}\"}"
        southsign = " minecraft:oak_wall_sign[facing=north]{Text2:\"{\\\"text\\\":\\\"\(mazesign)\(rndseedname)\\\"}\",Text3:\"{\\\"text\\\":\\\"Entrance\\\"}\"}"
        eastsign = " minecraft:oak_wall_sign[facing=west]{Text2:\"{\\\"text\\\":\\\"\(mazesign)\(rndseedname)\\\"}\",Text3:\"{\\\"text\\\":\\\"Entrance\\\"}\"}"
        westsign = " minecraft:oak_wall_sign[facing=east]{Text2:\"{\\\"text\\\":\\\"\(mazesign)\(rndseedname)\\\"}\",Text3:\"{\\\"text\\\":\\\"Entrance\\\"}\"}"
    
    }
    
    mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north"))\(northsign)\r"
    mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south"))\(southsign)\r"
    mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east"))\(eastsign)\r"
    mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west"))\(westsign)\r"
    
    if ( mazeskin == "moroccan" ) {
        
        xl = ((entryrow - 1) * cellsizex) + 1 + xoffset
        yd = ((entrylevel - 1) * cellsizey) + 1 + yoffset
        zf = (-1 + zoffset)
        xr = xl + 2
        yu = yd + 2
        zb = zf
        
        mcfunctionnorth += "fill\(mineCoords(xl, yd, zf, "north"))\(mineCoords(xr, yu, zb, "north")) minecraft:air\r"
        mcfunctionsouth += "fill\(mineCoords(xl, yd, zf, "south"))\(mineCoords(xr, yu, zb, "south")) minecraft:air\r"
        mcfunctioneast += "fill\(mineCoords(xl, yd, zf, "east"))\(mineCoords(xr, yu, zb, "east")) minecraft:air\r"
        mcfunctionwest += "fill\(mineCoords(xl, yd, zf, "west"))\(mineCoords(xr, yu, zb, "west")) minecraft:air\r"
    
    }
    
    if !( mazeexit == "roof" ) {
        
        if ( mazeskin == "moroccan" ) {
            
            x1 = ((entryrow - 1) * cellsizex) - 2 + xoffset
            y1 = ((entrylevel - 1) * cellsizey) + 3 + yoffset
            z1 = (numcolumns * cellsizez) + 2 + zoffset
            
            northsign = " minecraft:acacia_wall_sign[facing=north]{Text2:\"{\\\"text\\\":\\\"\(mazesign)\(rndseedname)\\\"}\",Text3:\"{\\\"text\\\":\\\"Exit\\\"}\"}"
            southsign = " minecraft:acacia_wall_sign[facing=south]{Text2:\"{\\\"text\\\":\\\"\(mazesign)\(rndseedname)\\\"}\",Text3:\"{\\\"text\\\":\\\"Exit\\\"}\"}"
            eastsign = " minecraft:acacia_wall_sign[facing=east]{Text2:\"{\\\"text\\\":\\\"\(mazesign)\(rndseedname)\\\"}\",Text3:\"{\\\"text\\\":\\\"Exit\\\"}\"}"
            westsign = " minecraft:acacia_wall_sign[facing=west]{Text2:\"{\\\"text\\\":\\\"\(mazesign)\(rndseedname)\\\"}\",Text3:\"{\\\"text\\\":\\\"Exit\\\"}\"}"

        } else {
            
            x1 = ((entryrow - 1) * cellsizex) - 1 + xoffset
            y1 = ((entrylevel - 1) * cellsizey) + 2 + yoffset
            z1 = (numcolumns * cellsizez) + 1 + zoffset
            
            northsign = " minecraft:oak_wall_sign[facing=north]{Text2:\"{\\\"text\\\":\\\"\(mazesign)\(rndseedname)\\\"}\",Text3:\"{\\\"text\\\":\\\"Exit\\\"}\"}"
            southsign = " minecraft:oak_wall_sign[facing=south]{Text2:\"{\\\"text\\\":\\\"\(mazesign)\(rndseedname)\\\"}\",Text3:\"{\\\"text\\\":\\\"Exit\\\"}\"}"
            eastsign = " minecraft:oak_wall_sign[facing=east]{Text2:\"{\\\"text\\\":\\\"\(mazesign)\(rndseedname)\\\"}\",Text3:\"{\\\"text\\\":\\\"Exit\\\"}\"}"
            westsign = " minecraft:oak_wall_sign[facing=west]{Text2:\"{\\\"text\\\":\\\"\(mazesign)\(rndseedname)\\\"}\",Text3:\"{\\\"text\\\":\\\"Exit\\\"}\"}"

        }
        
        mcfunctionnorth += "setblock\(mineCoords(x1, y1, z1, "north"))\(northsign)\r"
        mcfunctionsouth += "setblock\(mineCoords(x1, y1, z1, "south"))\(southsign)\r"
        mcfunctioneast += "setblock\(mineCoords(x1, y1, z1, "east"))\(eastsign)\r"
        mcfunctionwest += "setblock\(mineCoords(x1, y1, z1, "west"))\(westsign)\r"
    
    }
    
    print("Saving files")
    
    let filesaver = mcFileSaver("\(mazename)\(rndseedname).mcfunction")
    
    if ( !filesaver.ready ) {
        print("Problem with save dialog")
        
        return
    }
    
    var mcfunctionfile: String = "\(filesaver.savename).mcfunction"

    mcfunction += "execute if entity @p[y_rotation=135..-134.9] run function autobuild:subroutines/\(filesaver.savename)_north\r"
    mcfunction += "execute if entity @p[y_rotation=-45..44.9] run function autobuild:subroutines/\(filesaver.savename)_south\r"
    mcfunction += "execute if entity @p[y_rotation=-135..-44.9] run function autobuild:subroutines/\(filesaver.savename)_east\r"
    mcfunction += "execute if entity @p[y_rotation=45..134.9] run function autobuild:subroutines/\(filesaver.savename)_west\r"
    
    if filesaver.saveFile(mcfunction, mcfunctionfile) {
        print("Saved main function \(mcfunctionfile) in \(filesaver.rooturl)")
        
    } else {
        print("Problem saving main function \(mcfunctionfile) in \(filesaver.rooturl)")
    }
    
    mcfunctionfile = "subroutines/\(filesaver.savename)_north.mcfunction"
    
    if filesaver.saveFile(mcfunctionnorth, mcfunctionfile) {
        print("Saved north function \(mcfunctionfile) in \(filesaver.rooturl)")
        
    } else {
        print("Problem saving north function \(mcfunctionfile) in \(filesaver.rooturl)")
    }

    mcfunctionfile = "subroutines/\(filesaver.savename)_south.mcfunction"
    
    if filesaver.saveFile(mcfunctionsouth, mcfunctionfile) {
        print("Saved south function \(mcfunctionfile) in \(filesaver.rooturl)")
        
    } else {
        print("Problem saving south function \(mcfunctionfile) in \(filesaver.rooturl)")
    }

    mcfunctionfile = "subroutines/\(filesaver.savename)_east.mcfunction"
    
    if filesaver.saveFile(mcfunctioneast, mcfunctionfile) {
        print("Saved east function \(mcfunctionfile) in \(filesaver.rooturl)")
        
    } else {
        print("Problem saving east function \(mcfunctionfile) in \(filesaver.rooturl)")
    }

    mcfunctionfile = "subroutines/\(filesaver.savename)_west.mcfunction"
    
    if filesaver.saveFile(mcfunctionwest, mcfunctionfile) {
        print("Saved west function \(mcfunctionfile) in \(filesaver.rooturl)")
        
    } else {
        print("Problem saving west function \(mcfunctionfile) in \(filesaver.rooturl)")
    }
    
}


struct Cleanup {
    
    var delay: Int
    var position: [String: Int]
    
    init( delay: Int, position: [String: Int] ) {
        self.delay = delay
        self.position = position
    }
    
    mutating func Delay() -> Bool {
        delay -= 1
        return (delay <= 0)
    }
}


func mineCoords(_ vx: Int, _ vy: Int, _ vz: Int, _ vdirection: String) -> String {
    
    var minex: Int
    var miney: Int
    var minez: Int
    
    switch (vdirection) {
        
    case "north":
        minex = vx
        miney = vy
        minez = -vz
        
    case "south":
        minex = -vx
        miney = vy
        minez = vz
        
    case "east":
        minex = vz
        miney = vy
        minez = vx
        
    case "west":
        minex = -vz
        miney = vy
        minez = -vx
        
    default:
        minex = vx
        miney = vy
        minez = -vz
        
    }
    
    var posx: String
    var posy: String
    var posz: String
    
    if ( minex == 0 ) {
        posx = " ~"
    } else {
        posx = " ~\(minex)"
    }
    
    if ( miney == 0 ) {
        posy = " ~"
    } else {
        posy = " ~\(miney)"
    }
    
    if ( minez == 0 ) {
        posz = " ~"
    } else {
        posz = " ~\(minez)"
    }
    
    return "\(posx)\(posy)\(posz)"
}


func BuildMaterial(_ layernum: Int, _ numlevels: Int) -> String {
    
    if numlevels == 1 {
        return " minecraft:green_terracotta"
    }
    
    switch ( layernum % 16 ) {
        
    case 1:
        return " minecraft:brown_terracotta"
        
    case 2:
        return " minecraft:orange_terracotta"

    case 3:
        return " minecraft:red_terracotta"

    case 4:
        return " minecraft:pink_terracotta"

    case 5:
        return " minecraft:purple_terracotta"

    case 6:
        return " minecraft:light_gray_terracotta"

    case 7:
        return " minecraft:white_terracotta"

    case 8:
        return " minecraft:cyan_terracotta"

    case 9:
        return " minecraft:green_terracotta"

    case 10:
        return " minecraft:lime_terracotta"

    case 11:
        return " minecraft:yellow_terracotta"

    case 12:
        return " minecraft:magenta_terracotta"

    case 13:
        return " minecraft:light_blue_terracotta"

    case 14:
        return " minecraft:blue_terracotta"

    case 15:
        return " minecraft:gray_terracotta"

    case 0:
        return " minecraft:black_terracotta"

    default:
        return " minecraft:green_terracotta"

    }
}


struct mcFileSaver {
    
    var ready: Bool = false
    var rooturl: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    var savename: String = ""
    
    init ( _ filename: String ) {
        fileSaveDialog( filename )
    }
    
    mutating func fileSaveDialog( _ filename: String ) {

        let savePanel = NSSavePanel()

        savePanel.directoryURL = rooturl
        savePanel.title = "Save MC Function..."
        savePanel.prompt = "Save to file"
        savePanel.nameFieldLabel = "Pick a name"
        savePanel.nameFieldStringValue = filename
        savePanel.canSelectHiddenExtension = true
        savePanel.allowedFileTypes = ["mcfunction"]

        let result = savePanel.runModal()

        switch result {

        case .OK:
            guard let saveurl = savePanel.url else { return }

            rooturl = saveurl.deletingLastPathComponent()

            savename = saveurl.deletingPathExtension().lastPathComponent
            savename = savename.components(separatedBy: CharacterSet.alphanumerics.inverted).joined(separator: "")
            savename = savename.lowercased()
            
            ready = true

        case .cancel:
            print("User Cancelled")

        default:
            print("Panel shouldn't be anything other than OK or Cancel")
        }
    }
    
    func saveFile( _ filecontent: String, _ filepath: String ) -> Bool {
        
        let fileurl = URL( fileURLWithPath: filepath, relativeTo: rooturl )
        
        do
        {
            try FileManager.default.createDirectory(at: fileurl.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError
        {
            print("Unable to create directory \(error.debugDescription)")
            return false
        }

        do {
            try filecontent.write( to: fileurl, atomically: true, encoding: String.Encoding.utf8 )
            return true
            
        }
        catch let error as NSError
        {
            print("Unable to save file \(error.debugDescription)")
            return false
        }
    }
}
