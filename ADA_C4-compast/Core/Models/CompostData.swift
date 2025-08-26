//
//  CompostData.swift
//  ADA_C4-compast
//
//  Created by Komang Wikananda on 20/08/25.
//

import Foundation
import SwiftData

@Model
final class CompostMethod {
    @Attribute(.unique) var compostMethodId: Int
    var name: String
    var descriptionText: String
    
    var compostDuration1: Int
    var compostDuration2: Int
    var spaceNeeded1: Int
    var spaceNeeded2: Int
    
//    var compostSpaceId: Int
    
    // Relationships
    var compostFrequencyId: CompostFrequency?
    var compostContainerId: CompostContainer?
    
    @Relationship(deleteRule: .cascade, inverse: \CompostMethodSteps.compostMethodId)
    var compostMethodSteps: [CompostMethodSteps] = []
    
    @Relationship(deleteRule: .cascade, inverse: \CompostItem.compostMethodId)
    var compostItems: [CompostItem] = []
    
    init(compostMethodId: Int, name: String, descriptionText: String, compostDuration1: Int, compostDuration2: Int, spaceNeeded1: Int, spaceNeeded2: Int) {
        self.compostMethodId = compostMethodId
        self.name = name
        self.descriptionText = descriptionText
        self.compostDuration1 = compostDuration1
        self.compostDuration2 = compostDuration2
        self.spaceNeeded1 = spaceNeeded1
        self.spaceNeeded2 = spaceNeeded2
    }
}

@Model
final class CompostMethodSteps {
    @Attribute(.unique) var compostMethodStepsId: Int
    var name: String
    var descriptionText: String
    var oneTimeOnly: Bool
    var frequency: Int
    
    // Relationship
    var compostMethodId: CompostMethod?
    
    init(compostMethodStepsId: Int, name: String, descriptionText: String, oneTimeOnly: Bool, frequency: Int) {
        self.compostMethodStepsId = compostMethodStepsId
        self.name = name
        self.descriptionText = descriptionText
        self.oneTimeOnly = oneTimeOnly
        self.frequency = frequency
    }
}

@Model
final class CompostItem {
    @Attribute(.unique) var compostItemId: Int
    var name: String
    var temperatureCategory: String
    var moistureCategory: String
    var creationDate: Date
    var isHealthy: Bool
    var lastLogged: Date
    var harvestedAt: Date?
    
    var estimatedHarvestAt: Date? // auto-recomputed


    // Relationships
    var compostMethodId: CompostMethod?

    @Relationship(deleteRule: .cascade, inverse: \CompostStack.compostItemId)
    var compostStacks: [CompostStack] = []

    @Relationship(deleteRule: .cascade, inverse: \PileBand.compostItemId)
    var pileBands: [PileBand] = []

    @Relationship(deleteRule: .cascade, inverse: \TurnEvent.compostItem)
    var turnEvents: [TurnEvent] = []     // <<< NEW

    enum Status { case healthy, needAction, harvested }

    init(name: String) {
        self.compostItemId = UUID().hashValue
        self.name = name
        self.temperatureCategory = "Cold"
        self.moistureCategory = "Dry"
        self.creationDate = Date()
        self.isHealthy = true
        self.lastLogged = Date()
    }

    // MARK: - Status
    var compostStatus: Status {
        if harvestedAt != nil { return .harvested }
        return isHealthy ? .healthy : .needAction
    }

    // MARK: - Turn helpers
    /// Number of times the pile has been turned.
    var turnCount: Int { turnEvents.count }

    /// Most recent turning date, if any.
    var lastTurnedOver: Date? {
        turnEvents.max(by: { $0.date < $1.date })?.date
    }

    /// Days since last turning (nil if never turned).
    var daysSinceLastTurn: Int? {
        guard let last = lastTurnedOver else { return nil }
        return Calendar.current.dateComponents([.day], from: last, to: Date()).day
    }
}

extension CompostItem {
    func turnNow(in context: ModelContext) {
        let event = TurnEvent(date: Date())
        event.compostItem = self
        turnEvents.append(event)
        event.compostItem?.recomputeAndStoreETA(in: context)
        
        
        
        try? context.save()
    }
}

extension CompostItem {
    var totalGreen: Int { compostStacks.reduce(0) { $0 + $1.greenAmount } }
    var totalBrown: Int { compostStacks.reduce(0) { $0 + $1.brownAmount } }
}

@Model
final class PileBand {
    @Attribute(.unique) var pileBandId: Int
    var materialType: String
    var isShredded: Bool
    var order: Int
    var createdAt: Date

    // Relationship
    var compostItemId: CompostItem?
    
    init(materialType: String, isShredded: Bool, order: Int) {
        self.pileBandId = UUID().hashValue
        self.materialType = materialType
        self.isShredded = isShredded
        self.order = order
        self.createdAt = Date()
    }
}

@Model
final class CompostStack {
    @Attribute(.unique) var compostStackId: Int
    
    var brownAmount: Int
    var greenAmount: Int
    var createdAt: Date
    var isShredded: Bool
    
    // Relationship
    var compostItemId: CompostItem?
    
    init(brownAmount: Int, greenAmount: Int, createdAt: Date, isShredded: Bool) {
        self.compostStackId = UUID().hashValue
        self.brownAmount = brownAmount
        self.greenAmount = greenAmount
        self.createdAt = createdAt
        self.isShredded = isShredded
    }
}

@Model
final class CompostFrequency {
    @Attribute(.unique) var compostFrequencyId: Int
    var timeName: String
    var timeDescription: String
    var timeDuration: Int
    
    init(compostFrequencyId: Int, timeName: String, timeDescription: String, timeDuration: Int) {
        self.compostFrequencyId = compostFrequencyId
        self.timeName = timeName
        self.timeDescription = timeDescription
        self.timeDuration = timeDuration
    }
}

@Model
final class CompostContainer {
    @Attribute(.unique) var compostContainerId: Int
    var containerName: String
    var containerDescription: String
    
    init(compostContainerId: Int, containerName: String, containerDescription: String) {
        self.compostContainerId = compostContainerId
        self.containerName = containerName
        self.containerDescription = containerDescription
    }
}

@Model
final class TurnEvent {
    @Attribute(.unique) var turnEventId: Int
    var date: Date

    // Relationship
    var compostItem: CompostItem?

    init(date: Date = Date()) {
        self.turnEventId = UUID().hashValue
        self.date = date
    }
}



