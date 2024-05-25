//
//  SpaceVolume.swift
//  
//
//  Created by 리아 on 5/24/24.
//

import Foundation

struct SpaceVolume {
    let minX: Float
    let maxX: Float
    let minY: Float
    let maxY: Float
    let minZ: Float
    let maxZ: Float
}

extension Array where Element == SpaceTime {
    func calculateSpaceVolume() -> SpaceVolume {
        var minX: Float = .greatestFiniteMagnitude
        var maxX: Float = -.greatestFiniteMagnitude
        var minY: Float = .greatestFiniteMagnitude
        var maxY: Float = -.greatestFiniteMagnitude
        var minZ: Float = .greatestFiniteMagnitude
        var maxZ: Float = -.greatestFiniteMagnitude

        for spaceTime in self {
            minX = Swift.min(minX, spaceTime.positionX)
            maxX = Swift.max(maxX, spaceTime.positionX)
            minY = Swift.min(minY, spaceTime.positionY)
            maxY = Swift.max(maxY, spaceTime.positionY)
            minZ = Swift.min(minZ, spaceTime.positionZ)
            maxZ = Swift.max(maxZ, spaceTime.positionZ)
        }

        let marginX = (maxX - minX) * 0.1
        let marginY = (maxY - minY) * 0.1
        let marginZ = (maxZ - minZ) * 0.1

        return SpaceVolume(
            minX: minX - marginX,
            maxX: maxX + marginX,
            minY: minY - marginY,
            maxY: maxY + marginY,
            minZ: minZ - marginZ,
            maxZ: maxZ + marginZ
        )
    }
}
