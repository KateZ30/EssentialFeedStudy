//
//  FeedViewControllerTests.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 4/24/24.
//

import XCTest
import UIKit
import EssensialFeed
import EssensialFeediOS
import EssensialApp
import Combine

class FeedUIIntegrationTests: XCTestCase {
    func test_feedView_hasTitle() {
        let (sut, _) = makeSUT()

        sut.simulateAppearance()

        XCTAssertEqual(sut.title, feedTitle)
    }

    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view is loaded")

        sut.simulateAppearance()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request once view is loaded")

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request once user initiates a load")

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected a third loading request once user initiates another load")
    }

    func test_loadMoreActions_requestMoreFromLoader() {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage()])

        XCTAssertEqual(loader.loadMoreCallCount, 0, "Expected no request before load more action")

        sut.simulateLoadMoreFeedAction()
        XCTAssertEqual(loader.loadMoreCallCount, 1, "Expected a load more request")

        sut.simulateLoadMoreFeedAction()
        XCTAssertEqual(loader.loadMoreCallCount, 1, "Expected no request while already loading more")

        loader.completeLoadMore(lastPage: false, at: 0)
        sut.simulateLoadMoreFeedAction()
        XCTAssertEqual(loader.loadMoreCallCount, 2, "Expected request after load more completed with more pages")

        loader.completeLoadMoreWithError(at: 1)
        sut.simulateLoadMoreFeedAction()
        XCTAssertEqual(loader.loadMoreCallCount, 3, "Expected request after load more failure")

        loader.completeLoadMore(lastPage: true, at: 2)
        sut.simulateLoadMoreFeedAction()
        XCTAssertEqual(loader.loadMoreCallCount, 3, "Expected no request after last page loaded")
    }

    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")

        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")

        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")

        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }

    func test_loadingMoreIndicator_isVisibleWhileLoadingMore() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        XCTAssertFalse(sut.isShowingLoadingMoreIndicator, "Expected no loading more indicator once view is loaded")

        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingMoreIndicator, "Expected no loading more indicator once loading completes successfully")

        sut.simulateLoadMoreFeedAction()
        XCTAssertTrue(sut.isShowingLoadingMoreIndicator, "Expected loading more indicator on load more action")

        loader.completeLoadMore(at: 0)
        XCTAssertFalse(sut.isShowingLoadingMoreIndicator, "Expected no loading more indicator once loading completes successfully")

        sut.simulateLoadMoreFeedAction()
        XCTAssertTrue(sut.isShowingLoadingMoreIndicator, "Expected loading more indicator on second load more action")

        loader.completeLoadMoreWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingMoreIndicator, "Expected no loading more indicator once loading completes with error")
    }

    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        let image2 = makeImage(description: "another description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        assertThat(sut, isRendering: [])

        loader.completeFeedLoading(with: [image0, image1], at: 0)
        assertThat(sut, isRendering: [image0, image1])

        sut.simulateLoadMoreFeedAction()
        loader.completeLoadMore(with: [image0, image1, image2, image3], at: 0)
        assertThat(sut, isRendering: [image0, image1, image2, image3])

        sut.simulateUserInitiatedReload()
        loader.completeFeedLoading(with: [image0, image1], at: 1)
        assertThat(sut, isRendering: [image0, image1])
    }

    func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterNonEmptyFeed() {
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])

        sut.simulateLoadMoreFeedAction()
        loader.completeLoadMore(with: [image0, image1], at: 0)
        assertThat(sut, isRendering: [image0, image1])

        sut.simulateUserInitiatedReload()
        loader.completeFeedLoading(with: [], at: 1)
        assertThat(sut, isRendering: [])
    }

    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage()
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])

        sut.simulateUserInitiatedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])

        sut.simulateLoadMoreFeedAction()
        loader.completeLoadMoreWithError(at: 0)
        assertThat(sut, isRendering: [image0])
    }

    func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeFeedLoading()
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_loadMoreCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading()
        sut.simulateLoadMoreFeedAction()

        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeLoadMore()
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_feedImageView_loadsImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "http://a-url.com")!)
        let image1 = makeImage(url: URL(string: "http://another-url.com")!)
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visible")

        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL request once first view becomes visible")

        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URL request once second view becomes visible")
    }

    func test_feedImageView_cancelsImageLoadingWhenNotVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "http://a-url.com")!)
        let image1 = makeImage(url: URL(string: "http://another-url.com")!)
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until views become visible")

        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected first cancelled image URL request once first view is not visible anymore")

        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected second cancelled image URL request once second view is not visible anymore")
    }

    func test_feedImageViewLoadingIndicator_isShownWhileLoadingImage() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])

        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)

        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator for first view while loading first image")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected loading indicator for second view while loading second image")

        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected loading indicator still showing for second view once first image loading completes successfully")


        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no loading indicatorfor second view once second image loading completes with error")
    }

    func test_feedImageView_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])

        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)

        XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")


        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image state change for second view once first image loading completes successfully")


        let imageData1 = UIImage.make(withColor: .green).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected no image state change for first view once second image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, imageData1, "Expected image for second view once second image loading completes successfully")
    }

    func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])

        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view while loading first image")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for second view while loading second image")

        let imageData = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData, at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action state change for second view once first image loading completes successfully")


        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingRetryAction, true, "Expected retry action for second view once second image loading completes with error")
    }

    func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage()])

        let view = sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, false, "Expected no retry action while loading image")

        let invalidImageData = Data("invalid image data".utf8)
        loader.completeImageLoading(with: invalidImageData, at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, true, "Expected retry action once image loading completes with invalid image data")
    }

    func test_feedImageViewRetryAction_retriesImageLoad() {
        let (sut, loader) = makeSUT()
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1])

        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected two image URL requests for the two visible views")

        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected only two image URL requests before retry action")

        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url], "Expected third image URL request after first view retry action")

        loader.completeImageLoadingWithError(at: 1)
        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url, image1.url], "Expected forth image URL request after second view retry action")
    }

    func test_feedImageView_preloadsImageURLWhenNearVisible() {
        let (sut, loader) = makeSUT()
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1])
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until image is near visible")

        sut.simulateFeedImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL request once first image is near visible")

        sut.simulateFeedImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URL request once second image is near visible")
    }

    func test_feedImageView_cancelsImageURLPreloadingWhenNotNearVisibleAnymore() {
        let (sut, loader) = makeSUT()
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not near visible anymore")

        sut.simulateFeedImageViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected first cancelled image URL request once first image is not near visible anymore")

        sut.simulateFeedImageViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected second cancelled image URL request once second image is not near visible anymore")
    }

    func test_feedImageView_doesNotShowDataFromPreviousRequestWhenCellIsReused() throws {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])

        let view0 = try XCTUnwrap(sut.simulateFeedImageViewVisible(at: 0))
        view0.prepareForReuse()

        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)

        XCTAssertEqual(view0.renderedImage, .none, "Expected no image state change for reused view once image loading completes successfully")
    }

    func test_feedImageView_doesNotRenderImageWhenNotVisibleAnymore() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage()])

        let view = sut.simulateFeedImageViewNotVisible(at: 0)
        loader.completeImageLoading(with: anyImageData(), at: 0)
        XCTAssertNil(view?.renderedImage, "Expected no rendered image when an image is not visible anymore")
    }

    func test_loadImageDataCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage()])
        _ = sut.simulateFeedImageViewVisible(at: 0)

        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeImageLoading(with: self.anyImageData(), at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_loadFeedCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        XCTAssertEqual(sut.errorMessage, nil)

        loader.completeFeedLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.errorMessage, nil)
    }

    func test_loadMoreCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading()

        sut.simulateLoadMoreFeedAction()
        XCTAssertEqual(sut.loadMoreFeedErrorMessage, nil)

        loader.completeLoadMoreWithError()
        XCTAssertEqual(sut.loadMoreFeedErrorMessage, loadError)

        sut.simulateLoadMoreFeedAction()
        XCTAssertEqual(sut.loadMoreFeedErrorMessage, nil)
    }

    func test_tapOnErrorView_hidesErrorMessage() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        XCTAssertEqual(sut.errorMessage, nil)

        loader.completeFeedLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)

        sut.simulateTapOnErrorView()
        XCTAssertEqual(sut.errorMessage, nil)
    }

    func test_tapOnLoadMoreErrorView_loadsMore() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading()

        sut.simulateLoadMoreFeedAction()
        XCTAssertEqual(loader.loadMoreCallCount, 1)

        sut.simulateTapOnLoadMoreErrorView()
        XCTAssertEqual(loader.loadMoreCallCount, 1)

        loader.completeLoadMoreWithError()
        sut.simulateTapOnLoadMoreErrorView()
        XCTAssertEqual(loader.loadMoreCallCount, 2)
    }

    func test_imageSelection_notifiesHandler() {
        let image0 = makeImage()
        let image1 = makeImage()
        var selectedImages = [FeedImage]()
        let (sut, loader) = makeSUT(selection: { selectedImages.append($0) })

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1])

        sut.simulateTapOnFeedImageView(at: 0)
        XCTAssertEqual(selectedImages, [image0])

        sut.simulateTapOnFeedImageView(at: 1)
        XCTAssertEqual(selectedImages, [image0, image1])
    }

    // MARK: - Helpers
    private func makeSUT(selection: @escaping (FeedImage) -> Void = { _ in },
                         file: StaticString = #filePath, line: UInt = #line) -> (ListViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.feedComposedWith(feedLoader: loader.loadPublisher,
                                                  imageLoader: loader.loadImageDataPublisher,
                                                  selection: selection)

        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, loader)
    }

    private func makeImage(description: String? = nil, location: String? = nil, url: URL = anyURL()) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: url)
    }

    private func anyImageData() -> Data {
        UIImage.make(withColor: .red).pngData()!
    }

    private func assertThat(_ sut: ListViewController, hasViewConfiguredFor image: FeedImage, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.feedImageView(at: index)

        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }

        XCTAssertEqual(cell.locationContainer.isHidden, image.location == nil, "Expected location container to be \(image.location == nil) for image \(index)", file: file, line: line)
        XCTAssertEqual(cell.locationLabel.text, image.location, "Expected location label to be \(String(describing: image.location)) for image \(index)", file: file, line: line)
        XCTAssertEqual(cell.descriptionLabel.text, image.description, "Expected description label to be \(String(describing: image.description)) for image \(index)", file: file, line: line)
    }

    private func assertThat(_ sut: ListViewController, isRendering feed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        sut.tableView.enforceLayoutCycle()

        guard feed.count == sut.numberOfRenderedFeedImageViews else {
            return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews) instead", file: file, line: line)
        }

        feed.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }

        executeRunLoopToCleanUpReferences()
    }

    private func executeRunLoopToCleanUpReferences() {
        RunLoop.current.run(until: Date())
    }

    private class LoaderSpy {
        // MARK: - FeedLoader
        private(set) var feedRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()
        var loadFeedCallCount: Int { feedRequests.count }

        func loadPublisher() -> AnyPublisher<Paginated<FeedImage>, Error> {
            let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
            feedRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }

        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            feedRequests[index].send(Paginated(items: feed, loadMorePublisher: { [weak self] in
                self?.loadMorePublisher() ?? Empty().eraseToAnyPublisher()
            }))
        }

        func completeFeedLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            feedRequests[index].send(completion: .failure(error))
        }

        // MARK: - LoadMoreFeedLoader
        private(set) var loadMoreRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()
        var loadMoreCallCount: Int { loadMoreRequests.count }

        func loadMorePublisher() -> AnyPublisher<Paginated<FeedImage>, Error> {
            let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
            loadMoreRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }

        func completeLoadMore(with feed: [FeedImage] = [], lastPage: Bool = false, at index: Int = 0) {
            loadMoreRequests[index].send(Paginated(
                items: feed,
                loadMorePublisher: lastPage ? nil : { [weak self] in
                    self?.loadMorePublisher() ?? Empty().eraseToAnyPublisher()
                }))
        }

        func completeLoadMoreWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            loadMoreRequests[index].send(completion: .failure(error))
        }

        // MARK: - FeedImageDataLoader
        private var imageRequests = [(url: URL, publisher: PassthroughSubject<Data, Error>)]()

        var loadedImageURLs: [URL] {
            return imageRequests.map { $0.url }
        }

        private(set) var cancelledImageURLs = [URL]()

        func loadImageDataPublisher(from url: URL) -> AnyPublisher<Data, Error> {
            let publisher = PassthroughSubject<Data, Error>()
            imageRequests.append((url, publisher))
            return publisher.handleEvents(receiveCancel: { [weak self] in
                self?.cancelledImageURLs.append(url)
            }).eraseToAnyPublisher()
        }

        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].publisher.send(imageData)
            imageRequests[index].publisher.send(completion: .finished)
        }

        func completeImageLoadingWithError(at index: Int = 0) {
            imageRequests[index].publisher.send(completion: .failure(anyNSError()))
        }
    }
}

extension UIView {
    public func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
