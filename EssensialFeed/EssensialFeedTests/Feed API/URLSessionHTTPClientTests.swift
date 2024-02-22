//
//  URLSessionHTTPClientTests.swift
//  EssensialFeedTests
//
//  Created by Kate Zemskova on 2/21/24.
//

import XCTest
import EssensialFeed

class URLSessionHTTPClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error {
                completion(.failure(error))
            }
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    func test_getFromURL_failsOnRequestError() {
        URLProtocolStub.startInterceptingRequests()
        let url = URL(string: "https://a-given-url.com")!
        let sut = URLSessionHTTPClient()
        let error = NSError(domain: "any error", code: 1)
        URLProtocolStub.stub(url: url, error: error)

        let exp = expectation(description: "Wait for completion")

        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.domain, error.domain)
                XCTAssertEqual(receivedError.code, error.code)
            default:
                XCTFail("Expected failure with error \(error), got \(result) instead")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
        URLProtocolStub.stopInterceptingRequests()
    }

    // MARK: - Helpers
    private class URLProtocolStub: URLProtocol  {
        private static var stubs: [URL: Stub] = [:]

        private struct Stub {
            let error: Error?
        }

        static func stub(url: URL, error: Error? = nil) {
            Self.stubs[url] = Stub(error: error)
        }

        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }

        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            Self.stubs = [:]
        }

        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            return Self.stubs[url] != nil
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            guard let url = request.url, let stub = Self.stubs[url] else { return }
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }

            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() { }
    }
}