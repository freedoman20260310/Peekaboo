import Foundation
import PeekabooFoundation
import Testing
@testable import PeekabooCLI

@Suite("SeeCommand safe timeout")
struct SeeCommandTimeoutTests {
    @Test("returns result before timeout")
    func returnsBeforeTimeout() async throws {
        let result = try await SeeCommand.withSafeTimeout(seconds: 1.0) {
            "ok"
        }
        #expect(result == "ok")
    }

    @Test("throws detectionTimedOut when operation exceeds deadline")
    func timesOut() async {
        let error = await #expect(throws: CaptureError.self) {
            try await SeeCommand.withSafeTimeout(seconds: 0.05) {
                try await Task.sleep(nanoseconds: 200_000_000)
                return "late"
            }
        }

        switch error {
        case let .detectionTimedOut(seconds):
            #expect(seconds == 0.05, "Timeout should propagate configured deadline")
        default:
            Issue.record("Unexpected capture error: \(error)")
        }
    }
}
