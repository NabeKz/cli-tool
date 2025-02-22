import std/asynchttpserver
import std/asyncdispatch

import src/shared/db/conn
import src/shared/handler
import src/dependency

type 
  App = ref object
    server: AsyncHttpServer

func newApp(db: DbConn): App =
  App(
    server: newAsyncHttpServer()
  )  

proc run(self: App) {.async.} =
  var db = dbConn("db.sqlite3")
  defer: db.close()
  
  self.server.listen(Port 5000)
  echo "server is running at 5000"
  
  let deps = newDependency()

  proc router(req: Request) {.async, closure, gcsafe.}  =

    list "/products", deps.productListController(req)
    post "/products", deps.productPostController(req)
    
    read "/cart", deps.shoppingCartGetController(req)
    post "/cart", deps.shoppingCartPostController(req)
    
    list "/information", deps.informationListController(req)


    await req.respond(Http404, $Http404)

  while true:
    if self.server.shouldAcceptRequest():
      await self.server.acceptRequest(router)
    else:
      await sleepAsync(500)


let db = dbConn("db.sqlite3")
let app = newApp(db)
waitFor app.run()
