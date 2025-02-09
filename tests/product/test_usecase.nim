import std/unittest
import std/options

import src/entities/product/repository
import src/entities/product/usecase

let repo = newProductRepositoryOnMemory().toInterface()


block add:
  let addUsecase = newProductCreateUsecase repo
  let value = ProductInputDto(
    name: "a",
    description: "",
    price: 10,
    stock: 10,
  )

  let errors = addUsecase.invoke(value)

  if (errors.isSome()):
    raise newException(ValueError, $errors)
  
  check errors.isNone() == true
  
  