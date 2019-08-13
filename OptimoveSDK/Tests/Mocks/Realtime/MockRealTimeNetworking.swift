// Copiright 2019 Optimove

@testable import OptimoveSDK

final class MockRealTimeNetworking: RealTimeNetworking {

    var assertFunction: ((RealtimeEvent) -> Result<String, Error>) = { _ in
        return .success("")
    }

    func report(event: RealtimeEvent, completion: @escaping (Result<String, Error>) -> Void) throws {
        completion(assertFunction(event))
    }

}
