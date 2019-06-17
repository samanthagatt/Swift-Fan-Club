import Routing
import Vapor
import Fluent
import FluentSQLite

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    
    router.get("setup") { req -> String in
        let item1 = Message(id: 1, forum: 1, title: "Welcome", body: "Hello!", parent: 0, user: "twostraws", date: Date())
        let item2 = Message(id: 2, forum: 1, title: "Second post", body: "Hello!", parent: 0, user: "twostraws", date: Date())
        let item3 = Message(id: 3, forum: 1, title: "Test reply", body: "Yay!", parent: 1, user: "twostraws", date: Date())
        
        _ = item1.create(on: req)
        _ = item2.create(on: req)
        _ = item3.create(on: req)
        
        return "Hello, world!"
    }
    
    router.get { req -> Future<View> in
        struct HomeContent: Codable {
            var username: String?
            var forums: [Forum]
        }
        return Forum.query(on: req).all().flatMap(to: View.self) { forums in
            let context = HomeContent(username: getUsername(req), forums: forums)
            return try req.view().render("home", context)
        }
    }
    
    router.get("forum", Int.parameter) { req -> Future<View> in
        struct ForumContext: Codable {
            var username: String?
            var forum: Forum
            var messages: [Message]
        }
        let forumID = try req.parameters.next(Int.self)
        return Forum.find(forumID, on: req).flatMap(to: View.self) { forum in
            guard let forum = forum else {
                throw Abort(.notFound)
            }
            let query = Message.query(on: req)
                .filter(\.forum == forum.id!)
                .filter(\.parent == 0)
                .all()
            return query.flatMap(to: View.self) { messages in
                let context = ForumContext(username: getUsername(req), forum: forum, messages: messages)
                return try req.view().render("forum", context)
            }
        }
    }
}

func getUsername(_ req: Request) -> String? {
    return "Testing"
}
