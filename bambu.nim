

import nmqtt, asyncdispatch, json, tables, strutils, os, strformat, httpclient, std/wordwrap

var data: Table[string, string]
var error_list: Table[string, string]


proc decode(body: string) =

  #echo body

  proc aux(j: JsonNode, prefix="") =
    case j.kind
      of JInt, JFloat, JBool:
        data[prefix] = $j
      of JString:
        data[prefix] = j.getStr
      of JObject:
        for k, jc in j:
          aux(jc, if prefix == "": $k else: prefix & "." & $k)
      of JArray:
        var n = 0
        for jc in j:
          aux(jc, prefix & "[" & $n & "]")
          inc n
      of JNull:
        discard

  aux(parseJSon(body))

  let f = open("/tmp/bambu.json", fmWrite)
  for k, v in data:
    f.writeLine($k & ": " & $v)
  f.close()



proc dump() =
  proc p(s: string) =
    var s = s
    while true:
      let f1 = s.find("{")
      let f2 = s.find("}")
      if f1 == -1 or f2 == -1:
        break
      let key = s[f1+1..f2-1]
      if key in data:
        s = s[0..f1-1] & "\e[1m" & data[key] & "\e[0m" & s[f2+1..s.len-1]
      else:
        s = s[0..f1-1] & "?" & s[f2+1..s.len-1]
    echo s

  echo ""
  #echo "\e[2J\e[0H"
  p "task: {print.subtask_name}"
  p "stage: {print.mc_print_stage}.{print.mc_print_sub_stage}"
  p "progress: {print.mc_percent}%, layer {print.layer_num}/{print.total_layer_num}, -{print.mc_remaining_time} min"
  p "bed temp: {print.bed_temper}°C ({print.bed_target_temper}°C)"
  p "nozzle temp: {print.nozzle_temper}°C ({print.nozzle_target_temper}°C)"
  p "chamber temp: {print.chamber_temper}°C"
  p "fans: part: {print.cooling_fan_speed}, aux: {print.big_fan1_speed}, chamber: {print.big_fan2_speed}"
  p "AMS humidity: {print.ams.ams[0].humidity}"
  var filament = ""
  for i in 0..3:
    let key = "print.ams.ams[0].tray[" & $i & "].tray_color"
    if key in data:
      let c = data["print.ams.ams[0].tray[" & $i & "].tray_color"]
      var t = data["print.ams.ams[0].tray[" & $i & "].tray_sub_brands"]
      if t == "":
        t = data["print.ams.ams[0].tray[" & $i & "].tray_type"]
      let r = c[0..1].parseHexInt()
      let g = c[2..3].parseHexInt()
      let b = c[4..5].parseHexInt()
      filament &= $i & ": " & t & " " & &"\x1b[48;2;{r};{g};{b}m   \e[0m "
  echo "filament: " & filament

  if data["print.fail_reason"] != "0":
    p "fail reason: {print.fail_reason}"

  if data["print.print_error"] != "0" or data["print.mc_print_error_code"] != "0":
    p "error: {print.print_error} {print.mc_print_error_code}"
    # convert to hex string
    let ecode = data["print.print_error"].parseInt().toHex(8)
    if ecode in error_list:
      echo "--------------------"
      echo "\e[1;31mError: " & error_list[ecode].wrapWords(80) & "\e[0m"
      echo "--------------------"

  

proc get_ecodes() {.async.} = 
  let client = newAsyncHttpClient()
  let body = await client.getContent("https://e.bambulab.com/query.php?lang=en")
  let j = parseJson(body)
  for item in j["data"]["device_error"]["en"]:
    let ecode = item["ecode"].getStr()
    let intro = item["intro"].getStr()
    error_list[ecode] = intro

 
  
proc start() {.async.} =

  # Get error code list from bambu
  await get_ecodes()

  # Read user config
  let cfg = readFile(getHomeDir() & "/.bambu").strip()
  let ps = cfg.split(":")
  let (host, pass) = (ps[0], ps[1])

  let ctx = newMqttCtx("bambu")
  ctx.set_host(host, 8883, true)
  ctx.set_auth("bblp", pass)
  ctx.set_ping_interval(3)

  proc mqttSub() {.async.} =
    await ctx.start()
    proc on_data(topic: string, message: string) =
      decode(message)
      try:
        dump()
      except:
        discard

    await ctx.subscribe("#", 2, on_data)

  await mqttSub()
  await ctx.publish("device/00M09A330500140/request", """{"pushing":{"command":"pushall","push_target":1,"sequence_id":"20001","version":1}}""", 2)

  
  #asyncCheck ctx.publish("device/00M09A330500140/request", """{"pushing":{"command":"resume","sequence_id":"20001","version":1}}""", 2)

asyncCheck start()
runForever()


