import Foundation

enum NetworkError: Error {
    case incorrectCodeStatus(Int)
    case dataError
}

private let httpStatusCodeSuccess = 200..<300
private let httpStatusCodeClientError = 400..<500
private let httpStatusCodeServerError = 500..<600

extension URLSession {
    func dataTask(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        var task: URLSessionDataTask?

        return try await withTaskCancellationHandler {
            return try await withCheckedThrowingContinuation { continuation in
                task = self.dataTask(with: urlRequest) { (data, response, error) in
                    if let result = response as? HTTPURLResponse, let data {
                        if httpStatusCodeSuccess.contains(result.statusCode) {
                            continuation.resume(returning: (data, result))
                        } else if let error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(throwing: NetworkError.incorrectCodeStatus(result.statusCode))
                        }
                    } else {
                        continuation.resume(throwing: NetworkError.dataError)
                    }
                }
                task?.resume()
            }
        } onCancel: { [weak task] in
            task?.cancel()
        }
    }
}
