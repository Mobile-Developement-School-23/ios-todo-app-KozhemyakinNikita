import Foundation
import CocoaLumberjackSwift

enum APIErrors: Error {
    case badRequest(String)
    case notAuthorized(String)
    case serverError(String)
    case notFound(String)
}

private enum HttpMethod: String {
    case get = "GET"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol NetworkingService {
    func getList() async throws -> [ToDoItem]
    func patchList(_ toDoItem: [ToDoItem]) async throws -> [ToDoItem]
//    func getItem(_ id: String) async throws -> ToDoItem
    func postItem(_ toDoItem: ToDoItem) async throws -> ToDoItem
//    func putItem(_ toDoItem: ToDoItem) async throws -> ToDoItem
//    func deleteItem(_ id: String) async throws -> ToDoItem
}

class DefaultNetworkingService: NetworkingService {
    private let token = "symmetric"
    private let userName = "Kozhemjakin_N"
    private var revision: Int = 0
    
    static let shared = DefaultNetworkingService()

    let baseUrl = "https://beta.mrdekk.ru/todobackend"

    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case versionRevision
    }
    
    private let urlSession = URLSession.shared
    
    var latestKnownRevision: Int {
        get {
            return userDefaults.integer(forKey: Keys.versionRevision.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.versionRevision.rawValue)
        }
    }
    
    private func createURL(httpMethod: HttpMethod, Revision: Bool, endPoint: String) throws -> URLRequest {
        guard let url = URL(string: baseUrl + endPoint) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        if Revision {
            request.setValue("\(latestKnownRevision)", forHTTPHeaderField: "X-Last-Known-Revision")
        }
        
        return request
    }
    
    private func parseToDoList(from data: Data) async throws -> [ToDoItem] {
        let parse = try JSONSerialization.jsonObject(with: data)
        
        guard
            let jsonArray = parse as? [String: Any],
            let toDoList = jsonArray["list"] as? [[String: Any]],
            let revision = jsonArray["revision"] as? Int
        else {
            throw APIErrors.badRequest("error request")
        }
        
        var toDoItemsArray: [ToDoItem] = []
        try toDoList.forEach { jsonItem in
            guard let item = ToDoItem.parse(json: jsonItem) else {
                throw APIErrors.badRequest("failed to parse json")
            }
            toDoItemsArray.append(item)
        }
        
        self.latestKnownRevision = revision
        print(parse)
        return toDoItemsArray
    }
    
    private func parseItem(from data: Data) async throws -> ToDoItem {
        let json = try JSONSerialization.jsonObject(with: data)
        guard
            let jsonArray = json as? [String: Any],
            let element = jsonArray["element"] as? [String: Any],
            let revision = jsonArray["revision"] as? Int,
            let todoItem = ToDoItem.parse(json: element)
        else {
            throw APIErrors.badRequest("Invalid response format")
        }
        
        self.revision = revision
        
        return todoItem
    }

    
    func getList() async throws -> [ToDoItem] {
        let requestURL = try createURL(
            httpMethod: HttpMethod.get,
            Revision: false,
            endPoint: "/list"
        )
        
        let (data, _) = try await urlSession.dataTask(for: requestURL)
        return try await parseToDoList(from: data)
    }
    
    func patchList(_ toDoItem: [ToDoItem]) async throws -> [ToDoItem] {
        var requestURL = try createURL(
            httpMethod: HttpMethod.patch,
            Revision: false,
            endPoint: "/list"
        )
        
        let json = toDoItem.map { $0.json }
        requestURL.httpBody = try JSONSerialization.data(withJSONObject: ["list": json], options: .fragmentsAllowed)
        
        do {
            let (data, _) = try await urlSession.dataTask(for: requestURL)
            return try await parseToDoList(from: data)
        } catch {
            throw APIErrors.serverError(error.localizedDescription)
        }
    }
//
//    func getItem(_ id: String) async throws -> ToDoItem {
//        <#code#>
//    }
//
    func postItem(_ toDoItem: ToDoItem) async throws -> ToDoItem {
        var requestURL = try createURL(
            httpMethod: HttpMethod.post,
            Revision: true,
            endPoint: "/list"
        )
        let request = try JSONSerialization.data(withJSONObject: ["element": toDoItem.json], options: .prettyPrinted)
        requestURL.httpBody = request
//        let json: [String: Any] = [
//            "status": "ok",
//            "element": todoItem.getJsonForNet(deviceID: self.deviceID)
//        ]
        
        do {
            let (data, _) = try await urlSession.dataTask(for: requestURL)
            print(data)
            return try await parseItem(from: data)
        } catch {
            print(APIErrors.serverError(error.localizedDescription))
            throw APIErrors.serverError(error.localizedDescription)
        }
    }
//
//    func putItem(_ toDoItem: ToDoItem) async throws -> ToDoItem {
//        <#code#>
//    }
//
//    func deleteItem(_ id: String) async throws -> ToDoItem {
//        <#code#>
//    }
    

}
