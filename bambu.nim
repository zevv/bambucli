

import nmqtt, asyncdispatch, json, tables, strutils, os, strformat, httpclient, std/wordwrap, net, asyncnet

import discover
import ecode
import stage


type
  Bambu = ref object
    ctx: MqttCtx
    device: string
    ip: string
    data: Table[string, string]



proc decode(b: Bambu, body: string) =

  # Recursively unpack the JSON HMS data into 
  # a string/string table with dotted keys
  proc aux(j: JsonNode, prefix="") =
    case j.kind
      of JInt, JFloat, JBool:
        b.data[prefix] = $j
      of JString:
        b.data[prefix] = j.getStr
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

  # For debugging purpuses, dump the current data to file
  let f = open("/tmp/bambu.data", fmWrite)
  for k, v in b.data:
    f.writeLine($k & ": " & $v)
  f.close()



proc dump(b: Bambu) {.async.} =
  proc p(s: string) =
    var s = s
    while true:
      let f1 = s.find("{")
      let f2 = s.find("}")
      if f1 == -1 or f2 == -1:
        break
      let key = s[f1+1..f2-1]
      if key in b.data:
        s = s[0..f1-1] & "\e[1m" & b.data[key] & "\e[0m" & s[f2+1..s.len-1]
      else:
        s = s[0..f1-1] & "-" & s[f2+1..s.len-1]
    echo s

  try:
    echo ""
    #echo "\e[2J\e[0H"
    p "task: {print.subtask_name}"
    p "stage: {print.stg_cur}.{print.mc_print_stage}.{print.mc_print_sub_stage} " & stage_str(b.data["print.stg_cur"].parseInt())
    p "progress: {print.mc_percent}%, layer {print.layer_num}/{print.total_layer_num}, -{print.mc_remaining_time} min at {print.spd_mag}% speed"
    p "bed temp: {print.bed_temper}°C ({print.bed_target_temper}°C)"
    p "nozzle temp: {print.nozzle_temper}°C ({print.nozzle_target_temper}°C)"
    p "chamber temp: {print.chamber_temper}°C"
    p "fans: part: {print.cooling_fan_speed}, aux: {print.big_fan1_speed}, chamber: {print.big_fan2_speed}"
    p "AMS humidity: {print.ams.ams[0].humidity}"
    p "filament: "
    for i in 0..3:
      let key = "print.ams.ams[0].tray[" & $i & "].tray_color"
      if key in b.data:
        let c = b.data["print.ams.ams[0].tray[" & $i & "].tray_color"]
        var t = b.data["print.ams.ams[0].tray[" & $i & "].tray_sub_brands"]
        if t == "":
          t = b.data["print.ams.ams[0].tray[" & $i & "].tray_type"]
        let r = c[0..1].parseHexInt()
        let g = c[2..3].parseHexInt()
        let b = c[4..5].parseHexInt()
        echo $i & ": " & &"\x1b[48;2;{r};{g};{b}m   \e[0m " & t

    if b.data["print.fail_reason"] != "0":
      p "fail reason: {print.fail_reason}"

    if b.data["print.print_error"] != "0" or b.data["print.mc_print_error_code"] != "0":
      p "error: {print.print_error} {print.mc_print_error_code}"
      # convert to hex string
      let ecode = b.data["print.print_error"].parseInt()
      let msg = await ecode_str(ecode)
      echo "--------------------"
      echo "\e[1;31mError: " & msg.wrapWords(80) & "\e[0m"
      echo "--------------------"
  except:
    discard
 

proc pub(b: Bambu, meth: string, msg: string) {.async.} =
  let topic = "device/" & b.device & "/" & meth
  await b.ctx.publish(topic, msg, 2)


proc command(b: Bambu, command: string) {.async.} =
  await b.pub("request", """{"pushing":{"command":"","sequence_id":"20001","version":1}}""")


proc start*(b: Bambu, device: string, ip: string) {.async.} =

  b.device = device
  b.ip = ip

  # Read user config
  let cfg = readFile(getHomeDir() & "/.bambu").strip()
  let ps = cfg.split(":")
  let (host, pass) = (ps[0], ps[1])

  b.ctx.set_host(host, 8883, true)
  b.ctx.set_auth("bblp", pass)
  b.ctx.set_ping_interval(3)
  await b.ctx.start()
  
  proc on_data(topic: string, message: string) =
    b.decode(message)
    asyncCheck b.dump()

  await b.ctx.subscribe("device/" & b.device & "/#", 2, on_data)
  await b.pub("request", """{"pushing":{"command":"pushall","push_target":1,"sequence_id":"20001","version":1}}""")


proc resume*(b: Bambu) {.async.} =
  await b.pub("request", """{"pushing":{"command":"resume","sequence_id":"20001","version":1}}""")


proc discover*(b: Bambu) {.async.} =
  let res = await discover()
  echo "Discovered " & res.device & " at " & res.ip
  b.start(res.device, res.ip)


proc newBambu*(): Bambu =
  let bambu = Bambu()
  bambu.ctx = newMqttCtx("bambu")
  return bambu


