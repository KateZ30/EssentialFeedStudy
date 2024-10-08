//
//  Copyright © Essential Developer. All rights reserved.
//

import CoreData

public final class CoreDataFeedStore {
    public static let modelName = "FeedStore"
    public static let model = NSManagedObjectModel(name: modelName, in: Bundle(for: CoreDataFeedStore.self))

    private let container: NSPersistentContainer
    let context: NSManagedObjectContext

    public struct ModelNotFound: Error {
        public let modelName: String
    }

    public enum ContextQueueType {
        case main
        case background
    }

    public var contextQueueType: ContextQueueType {
        context == container.viewContext ? .main : .background
    }

    public init(storeURL: URL, contextQueueType: ContextQueueType = .background) throws {
        guard let model = CoreDataFeedStore.model else {
            throw ModelNotFound(modelName: CoreDataFeedStore.modelName)
        }

        container = try NSPersistentContainer.load(
            name: CoreDataFeedStore.modelName,
            model: model,
            url: storeURL
        )
        context = contextQueueType == .background ? container.newBackgroundContext() : container.viewContext
    }

    deinit {
        cleanUpReferencesToPersistentStores()
    }

    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }

    public func perform(_ action: @escaping () -> Void) {
        context.perform(action)
    }
}
