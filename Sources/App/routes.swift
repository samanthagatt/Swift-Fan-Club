import Routing
import Vapor
import Fluent
import FluentSQLite

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    let forums = router.grouped("forums", Int.parameter)
    
    router.get { req -> Future<View> in
        struct Context: Codable {
            var username: String?
            var forums: [Forum]
        }
        // Queries for all forums, then
        return Forum.query(on: req).all().flatMap(to: View.self) { forums in
            let context = Context(username: getUsername(req), forums: forums)
            return try req.view().render("home", context)
        }
    }
    forums.get { req -> Future<View> in
        struct Context: Codable {
            var username: String?
            var forum: Forum
            var messages: [Message]
        }
        let forumID = try req.parameters.next(Int.self)
        return Forum.find(forumID, on: req).flatMap(to: View.self) { forum in
            guard let forum = forum, let id = forum.id else {
                throw Abort(.notFound)
            }
            return Message
                .query(on: req)
                .filter(\.forum == id)
                .filter(\.parent == 0)
                .all()
                .flatMap(to: View.self) { messages in
                    let context = Context(username: getUsername(req),
                                          forum: forum,
                                          messages: messages)
                    return try req.view().render("forum", context)
            }
        }
    }
    forums.get(Int.parameter) { req -> Future<View> in
        struct Context: Codable {
            var username: String?
            var forum: Forum
            var message: Message
            var replies: [Message]
        }
        let forumID = try req.parameters.next(Int.self)
        let messageID = try req.parameters.next(Int.self)
        // Find forum object by id
        return Forum.find(forumID, on: req).flatMap(to: View.self) { forum in
            guard let forum = forum else { throw Abort(.notFound) }
            // Find message by id
            return Message
                .find(messageID, on: req)
                .flatMap(to: View.self) { message in
                    guard let message = message else { throw Abort(.notFound) }
                    // Find all reply message by parent and forum
                    return Message.query(on: req)
                        .filter(\.forum == forumID)
                        .filter(\.parent == messageID)
                        .all()
                        .flatMap(to: View.self) { replies in
                            let context = Context(username: getUsername(req),
                                                  forum: forum,
                                                  message: message,
                                                  replies: replies)
                            return try req.view().render("message", context)
                    }
            }
        }
    }
}

func getUsername(_ req: Request) -> String? { "Testing" }
