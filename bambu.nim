

import nmqtt, asyncdispatch, json, tables, strutils, os

var data: Table[string, string]


proc decode(body: string) =

  proc aux(j: JsonNode, prefix: string) =
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

  let j = parseJson(body)
  #echo j.pretty()
  aux(j, "")


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
  p "progress: {print.mc_percent}%, ETA {print.mc_remaining_time} min"
  p "layer: {print.layer_num}/{print.total_layer_num}"
  p "bed temp: {print.bed_temper}°C ({print.bed_target_temper}°C)"
  p "nozzle temp: {print.nozzle_temper}°C ({print.nozzle_target_temper}°C)"
  p "chamber temp: {print.chamber_temper}°C"

  if data["print.print_error"] != "0" or data["print.mc_print_error_code"] != "0":
    p "error: {print.print_error} {print.mc_print_error_code}"

  if data["print.fail_reason"] != "0":
    p "fail reason: {print.fail_reason}"
  

proc start() =
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
      dump()

    await ctx.subscribe("device/00M09A330500140/report", 2, on_data)

  asyncCheck mqttSub()
  asyncCheck ctx.publish("device/00M09A330500140/request", """{"pushing":{"command":"pushall","push_target":1,"sequence_id":"20001","version":1}}""", 2)

  
  #asyncCheck ctx.publish("device/00M09A330500140/request", """{"pushing":{"command":"resume","sequence_id":"20001","version":1}}""", 2)

start()
runForever()


