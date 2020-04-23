import XCTest
@testable import Peasy

final class ServerTests: XCTestCase {

    func testBindPort() throws {
        let server = Server()
        
        let port = 8880
        server.start(port: port)
        server.respond(with: Response(status: .ok))
        
        let address = URL(string: "http://localhost:\(port)")!
        
        let expectation = self.expectation(description: "Completion")
        let dataTask = URLSession.shared.dataTask(with: address) { (data, response, error) in
            XCTAssertNil(error)
            XCTAssertEqual((response as! HTTPURLResponse).statusCode, 200)
            expectation.fulfill()
            server.stop()
        }
        dataTask.resume()
        
        wait(for: [expectation], timeout: 5.0)
    }
}
    