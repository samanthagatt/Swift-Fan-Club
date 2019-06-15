import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    
    router.get("setup") { req -> String in
        let item1 = Forum(id: 1, name: "Taylor's Songs")
        let item2 = Forum(id: 2, name: "Taylor's Albums")
        let item3 = Forum(id: 3, name: "Taylor's Concerts")
        
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
            print("FORUMS:", forums)
            let context = HomeContent(username: getUsername(req), forums: forums)
            return try req.view().render("home", context)
        }
    }
}

func getUsername(_ req: Request) -> String? {
    return "Testing"
}
