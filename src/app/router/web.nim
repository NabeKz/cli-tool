import std/strutils
import std/htmlgen

import src/shared/handler
import src/pages/home
import src/pages/books

const headers = { 
  "Content-Type": "text/html charset=utf8;"
}

proc resp(req: Request, status: HttpCode, content: string): Future[void] =
  req.respond(status, content, headers.newHttpHeaders())

proc resp(req: Request, content: string): Future[void] =
  resp(req, Http200, content)

proc match(req: Request, path: string, reqMethod: HttpMethod): bool =
  req.url.path == path

template build(body: varargs[string]): string =
  ""

proc asideNav(path: string): string =
  htmlgen.li(
    htmlgen.a(
      href = path,
      path
    )
  )

proc layout(body: string): string =  
  htmlgen.head(
    htmlgen.style(
      "ul, li { margin: 0 }",
      "label { display: grid; }",
      "form { button { margin-top: 8px; } }",
      ".layout { display: flex; margin:auto; max-width: 1400px; height: 100vh; gap: 24px; padding: 36px; }",
      ".aside { display: flex; }",
    ),
    htmlgen.div(
      class = "layout",
      htmlgen.aside(
        class = "aside",
        htmlgen.ul(
          asideNav("/siginin"),
          asideNav("/books"),
          asideNav("/books/create")
        ),
      ),
      body
    )
  )


proc router*(req: Request) {.async, gcsafe.}  =
   if req.match("/", HttpGet):
    await resp(req, layout home.index())

   if req.match("/books", HttpGet):
    await resp(req, layout books.index())
   
   if req.match("/books/create", HttpGet):
    await resp(req, layout books.create())

   await req.respond(Http404, $Http404)