import std/asynchttpserver
import std/asyncdispatch
import std/json
import std/macros
import std/re
import std/options

type ContentType = enum
  text = "text/plane; charset=utf-8"
  json = "application/json"


func newHttpHeaders(contentType: ContentType): HttpHeaders = 
  newHttpHeaders([("ContentType", $contentTYpe)])

proc json*(req: Request, code: HttpCode, content: ref object): Future[void] =
  let headers = newHttpHeaders(ContentType.json)
  let c = % content
  req.respond(code, $c, headers)

proc text*(req: Request, code: HttpCode, content: string): Future[void] =
  let headers = newHttpHeaders(ContentType.text)
  
  req.respond(code, content, headers)


func parsePathParam(path1, path2: string): string =
  let (begin, to) = (path1.len + 1, path2.len)
  path2[begin..<to]

func match(req: Request, p: string, httpMethod: HttpMethod, ): bool =
  let ptn = re ("^" & p & "/[a-zA-Z0-9]*$")
  req.reqMethod == httpMethod and req.url.path.match(ptn)


macro list*(p: string, body: untyped): untyped =
  let req = ident "req"
  result = quote do:
    if `req`.reqMethod == HttpGet and `req`.url.path == `p`:
      `body`


macro create*(p: string, body: untyped): untyped =
  let req = ident "req"
  result = quote do:
    if `req`.reqMethod == HttpPost and `req`.url.path == `p`:
      `body`


macro read*(p: string, arg, body: untyped): untyped =
  let req = ident "req"

  result = quote do:
    if `req`.match(`p`, HttpGET):
      let `arg` = parsePathParam(`p`, `req`.url.path)
      `body`


macro update*(p: string, arg, body: untyped): untyped =
  let req = ident "req"

  result = quote do:
    let ptn = re ("^" & `p` & "/[a-zA-Z0-9]*$")
    let path = `req`.url.path

    if `req`.reqMethod == HttpPut and path.match(ptn):
      let `arg` = parsePathParam(`p`, path)
      `body`


macro delete*(p: string, arg, body: untyped): untyped =
  let req = ident "req"

  result = quote do:
    let ptn = re ("^" & `p` & "/[a-zA-Z0-9]*$")
    let path = `req`.url.path

    if `req`.reqMethod == HttpDelete and path.match(ptn):
      let `arg` = parsePathParam(`p`, path)
      `body`
