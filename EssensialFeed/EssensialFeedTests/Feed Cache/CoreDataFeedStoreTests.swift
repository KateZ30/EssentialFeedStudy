//
//  CoreDataFeedStoreTests.swift
//  EssensialFeedTests
//
//  Created by Kate Zemskova on 4/12/24.
//

import XCTest
import EssensialFeed
import CoreData

final class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache() throws {
        try makeSUT { sut in
            self.assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
        }
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() throws {
        try makeSUT { sut in
            self.assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
        }
    }

    func test_retrieve_deliversFoundValuesOnNonEmptyCache() throws {
        try makeSUT { sut in
            self.assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
        }
    }

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() throws {
        try makeSUT { sut in
            self.assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
        }
    }

    func test_insert_deliversNoErrorOnEmptyCache() throws {
        try makeSUT { sut in
            self.assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
        }
    }

    func test_insert_deliversNoErrorOnNonEmptyCache() throws {
        try makeSUT { sut in
            self.assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
        }
    }

    func test_insert_overridesPreviouslyInsertedCacheValues() throws {
        try makeSUT { sut in
            self.assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
        }
    }

    func test_delete_deliversNoErrorOnEmptyCache() throws {
        try makeSUT { sut in
            self.assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
        }
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() throws {
        try makeSUT { sut in
            self.assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
        }
    }

    func test_delete_deliversNoErrorOnNonEmptyCache() throws {
        try makeSUT { sut in
            self.assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
        }
    }

    func test_delete_emptiesPreviouslyInsertedCache() throws {
        try makeSUT { sut in
            self.assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
        }
    }

    func test_delete_removesAllObjects() throws {
        try makeSUT { sut in
            self.insert((uniqueImageFeed().local, Date()), to: sut)
            self.deleteCache(from: sut)
        }

        let context = try NSPersistentContainer.load(
            name: CoreDataFeedStore.modelName,
            model: XCTUnwrap(CoreDataFeedStore.model),
            url: inMemoryStoreURL()
        ).viewContext

        let existingObjects = try context.allExistingObjects()

        XCTAssertEqual(existingObjects, [], "found orphaned objects in Core Data")
    }

    func test_imageEntity_properties() throws {
        let entity = try XCTUnwrap(
            CoreDataFeedStore.model?.entitiesByName["ManagedFeedImage"]
        )

        // Instructions: update the attribute
        // names if they don't match the names
        // on your Core Data entity

        entity.verify(attribute: "id", hasType: .UUIDAttributeType, isOptional: false)
        entity.verify(attribute: "imageDescription", hasType: .stringAttributeType, isOptional: true)
        entity.verify(attribute: "location", hasType: .stringAttributeType, isOptional: true)
        entity.verify(attribute: "url", hasType: .URIAttributeType, isOptional: false)
    }

    // - MARK: Helpers

    private func makeSUT(_ test: @escaping (CoreDataFeedStore) -> Void,
                         file: StaticString = #filePath, line: UInt = #line) throws {
        let sut = try CoreDataFeedStore(storeURL: inMemoryStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)

        let exp = expectation(description: "Wait for operation")
        sut.perform {
            test(sut)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    private func inMemoryStoreURL() -> URL {
        URL(fileURLWithPath: "/dev/null")
            .appendingPathComponent("\(type(of: self)).store")
    }
}

extension CoreDataFeedStore.ModelNotFound: CustomStringConvertible {
    public var description: String {
        "Core Data Model '\(modelName).xcdatamodeld' not found. You need to create it in the production target."
    }
}

