import Testing
@testable import HarborNewsCore

@Suite("ViewState")
struct ViewStateTests {
    @Test func equalityComparesOnlyTheCase() {
        #expect(ViewState<Int>.success(1) == .success(2))
        #expect(ViewState<Int>.error("a") == .error("b"))
        #expect(ViewState<Int>.idle != .loading)
        #expect(ViewState<Int>.success(1) != .error("x"))
    }
}
