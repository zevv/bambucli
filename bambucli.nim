
import std/asyncdispatch

import bambu

proc start() {.async.} =

  let b = newBambu()
  await b.discover()

  
asyncCheck start()
runForever()

