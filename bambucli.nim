
import std/asyncdispatch

import bambu

proc run() {.async.} =
  let b = newBambu()
  await b.discover()

  
asyncCheck run()
runForever()

