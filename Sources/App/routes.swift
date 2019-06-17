import Routing
import Vapor
import Fluent
import FluentSQLite

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    
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
    
    let forum = router.grouped("forum", Int.parameter)
    
    forum.get() { req -> Future<View> in
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
    
    forum.get(Int.parameter) { req -> Future<View> in
        struct MessageContext: Codable {
            var username: String?
            var forum: Forum
            var message: Message
            var replies: [Message]
        }
        let forumID = try req.parameters.next(Int.self)
        let messageID = try req.parameters.next(Int.self)
        return Forum.find(forumID, on: req).flatMap(to: View.self) { forum in
            guard let forum = forum else {
                throw Abort(.notFound)
            }
            return Message.find(messageID, on: req).flatMap(to: View.self) { message in
                guard let message = message else {
                    throw Abort(.notFound)
                }
                let query = Message.query(on: req)
                    .filter(\.parent == message.id!)
                    .all()
                return query.flatMap(to: View.self) { replies in
                    let context = MessageContext(username: getUsername(req), forum: forum, message: message, replies: replies)
                    return try req.view().render("message", context)
                }
            }
        }
    }
}

func getUsername(_ req: Request) -> String? {
    return "Testing"
}
