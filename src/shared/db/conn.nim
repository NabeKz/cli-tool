import std/json
import std/os
import std/tables
import std/sequtils
import std/strformat
import std/strutils
import db_connector/db_sqlite

type DbConn* = db_sqlite.DbConn

type WriteModel* = concept x
  x.tableName() is string

type ReadModel* = concept x
  x.tableName() is string
  x.id is int64

type Fields = ref object
  keys: seq[string]
  values: seq[string]


func joinedKeys*(self: Fields): string = self.keys.join(",")
func placeholders*(self: Fields): string = self.keys.mapIt("?").join(",")

func dbConn*(filename: string): DbConn =
  open(filename, "", "", "")


func getFields(t: ref object): Fields =
  result = Fields()
  let node = %* t
  for (key, val) in node.pairs:
    result.keys.add(key)
    result.values.add($val)


iterator select*[T: ReadModel](self: DbConn, t: T, limit: uint64 = 100): JsonNode =
  let fields = getFields(t)
  let query = &"""SELECT {fields.joinedKeys()} FROM {t.tableName()} LIMIT 100"""
  for row in self.rows(sql query):
    let table = zip(fields.keys, row).toTable()
    yield (% table)


proc save*(self: DbConn, t: WriteModel): int64 =
  let fields = getFields(t)
  let query = &"""INSERT INTO {t.tableName()} ({fields.joinedKeys()}) VALUES ({fields.placeholders()})"""
  self.insertID(sql query, fields.values)


when not defined(release):
  import std/os
  import std/algorithm
  import std/sequtils

  export db_sqlite except DbConn
  # export db_sqlite.exec

  proc execDDL(db: DbConn) =
    let ddls = toSeq(walkDirRec("src")).filterIt(it.endsWith(".sql")).sorted()
    for ddl in ddls:
      let query = readFile(ddl)
      echo query
      let success = db.tryExec(sql query)
      if not success:
        echo "exec sql failure " & ddl

  ## use only dev
  template dbSetup*(filename: string, db, op: untyped): untyped =
    let db = dbConn(filename)
    execDDL(db)
    op

  template dbOnMemory*(db, op: untyped): untyped =
    let db = dbConn(":memory:")
    execDDL(db)
    op

when isMainModule:
  import std/os
  import std/algorithm
  import std/sequtils

  let db = dbConn(getCurrentDir() & "/db.sqlite3")
  let ddls = toSeq(walkDirRec("src")).filterIt(it.endsWith(".sql")).sorted()
  for ddl in ddls:
    let query = readFile(ddl)
    echo query
    let success = db.tryExec(sql query)
    if not success:
      echo "exec sql failure " & ddl
    