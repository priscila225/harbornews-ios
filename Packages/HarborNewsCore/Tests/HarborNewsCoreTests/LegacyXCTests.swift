#if canImport(XCTest)
import XCTest
@testable import HarborNewsCore

final class ViewStateXCTests: XCTestCase {
    func testEqualityComparesOnlyTheCase() {
        XCTAssertEqual(ViewState<Int>.success(1), .success(2))
        XCTAssertNotEqual(ViewState<Int>.idle, .loading)
    }
}
#endif
