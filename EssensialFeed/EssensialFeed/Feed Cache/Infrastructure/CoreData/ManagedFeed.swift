//
// Copyright © Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ManagedFeed)
final class ManagedFeed: NSManagedObject {
	@NSManaged var timestamp: Date
	@NSManaged var images: NSOrderedSet

	var managedImages: [ManagedFeedImage] {
		images.compactMap { $0 as? ManagedFeedImage }
	}

	var localFeedImages: [LocalFeedImage] {
		managedImages.compactMap { LocalFeedImage(id: $0.id,
		                                          description: $0.imageDescription,
		                                          location: $0.location,
		                                          url: $0.url) }
	}

	static func find(in context: NSManagedObjectContext) throws -> ManagedFeed? {
		let request = NSFetchRequest<ManagedFeed>(entityName: entity().name!)
		request.returnsObjectsAsFaults = false
		return try context.fetch(request).first
	}

	@discardableResult
	static func createUniqueFeed(in context: NSManagedObjectContext, timestamp: Date, feed: [LocalFeedImage]) throws -> ManagedFeed {
		try find(in: context).map(context.delete)
		let managedFeed = ManagedFeed(context: context)
		managedFeed.timestamp = timestamp
		managedFeed.images = NSOrderedSet(array: feed.managedFeedImages(context))
		return managedFeed
	}
}

private extension Array where Element == LocalFeedImage {
	func managedFeedImages(_ context: NSManagedObjectContext) -> [ManagedFeedImage] {
		self.compactMap { local in
			let managed = ManagedFeedImage(context: context)
			managed.id = local.id
			managed.imageDescription = local.description
			managed.location = local.location
			managed.url = local.url
			return managed
		}
	}
}
