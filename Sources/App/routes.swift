import Routing
import Vapor
import Fluent
import FluentSQLite
import Crypto

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    let forums = router.grouped("forums", Int.parameter)
    let users = router.grouped("users")
    
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
    users.get("create") { req in
        try req.view().render("create-user")
    }
    users.post("create") { req -> Future<View> in
        var user = try req.content.syncDecode(User.self)
        return User
            .query(on: req)
            .filter(\.username == user.username)
            .first()
            .flatMap(to: View.self) { found in
                if found != nil {
                    return try req.view().render("create-user", ["error": "true"])
                } else {
                    user.password = try BCrypt.hash(user.password)
                    return user.save(on: req).flatMap(to: View.self) { _ in
                        return try req.view().render("welcome-user")
                    }
                }
        }
    }
    users.get("login") { req in
        try req.view().render("login-user")
    }
    users.post(User.self, at: "login") { req, user -> Future<View> in
        return User
            .query(on: req)
            .filter(\.username == user.username)
            .first()
            .flatMap(to: View.self) { found in
                if let found = found {
                    if try BCrypt.verify(user.password, created: found.password) {
                        try req.session()["username"] = found.username
                        return try req.view().render("welcome-user")
                    } else {
                        let context = ["error":
                            "Username and password do not match"]
                        return try req.view().render("login-user", context)
                    }
                } else {
                    let context = ["error": "No user found with username"]
                    return try req.view().render("login-user", context)
                }
        }
    }
}

func getUsername(_ req: Request) -> String? { try? req.session()["username"] }
