import std/json
import ./model


type 
  CartFetchUsecase* = concept x
    x.invoke() is CartFetchOutputDto
  CartFetchUsecaseImpl*  = ref object
    queryService: ShoppingCartQueryService
  CartFetchOutputDto* = JsonNode
    

func init*(_: type CartFetchUsecaseImpl, queryService: ShoppingCartQueryService): CartFetchUsecaseImpl = 
  CartFetchUsecaseImpl(queryService: queryService)

proc invoke*(self: CartFetchUsecaseImpl): CartFetchOutputDto = 
  let cart = newShoppingCart()
  let items = @[
    newProductItem(productId = 1, amount = 2),
    newProductItem(productId = 2, amount = 3),
  ]
  %* cart.add(items)


type 
  CartItemAddUsecase* = concept x
    x.invoke(JsonNode) is ProductItemOutputDto
  CartItemAddUsecaseImpl* = ref object
  ProductItemOutputDto = JsonNode


func init*(_: type CartItemAddUsecaseImpl, queryService: ShoppingCartQueryService): CartFetchUsecaseImpl = 
  CartFetchUsecaseImpl(queryService: queryService)

proc invoke*(self: CartItemAddUsecaseImpl, jsonNode: JsonNode): ProductItemOutputDto = 
  let cart = newShoppingCart()
  let item = newProductItem(productId = 1, amount = 2)
  %* cart.add(item)
