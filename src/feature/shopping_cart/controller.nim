import std/asynchttpserver
import std/asyncdispatch
import src/server/handler
import src/shared/port/http
import std/json

import ./usecase


type ShoppingCartListController* = ref object
type ShoppingCartPostController* = ref object


template init*(_: type ShoppingCartListController, usecase: CartFetchUsecase): untyped =
  let form = req.body.toJson()
  let data = usecase.invoke(form)
  await req.json(Http200, data)



generateUnmarshal(ProductItemInputDto)
proc init*(_: type ShoppingCartPostController, usecase: CartFetchUsecase): proc(req: Request): Future[void]{.gcsafe.} =
  proc(req: Request): Future[void]{.gcsafe.} =
    let form = req.body.toJson().unmarshal()
    let data = usecase.invoke(form)
    await req.json(Http200, data)
