
import std/asyncdispatch
import std/json
import std/tables
import std/httpclient
import std/strutils

var error_list: Table[string, string]

proc download_ecodes*() {.async.} = 
  let client = newAsyncHttpClient()
  let body = await client.getContent("https://e.bambulab.com/query.php?lang=en")
  let j = parseJson(body)
  for item in j["data"]["device_error"]["en"]:
    let ecode = item["ecode"].getStr()
    let intro = item["intro"].getStr()
    error_list[ecode] = intro


# Convert the given error code to a string, using the online database if
# necessary

proc ecode_str*(ecode: int): Future[string] {.async.} =
  if error_list.len == 0:
    await download_ecodes()
  let ecode_str = ecode.toHex(8)
  if ecode_str in error_list:
    return error_list[ecode_str]
  else:
    return "Unknown error code: " & ecode_str

