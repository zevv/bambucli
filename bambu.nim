

import nmqtt, asyncdispatch, json, tables, strutils, os, strformat, httpclient, std/wordwrap, net, asyncnet, terminal, colors

import discover
import ecode
import stage


type

  Temperature = float

  Bambu = ref object
    ctx: MqttCtx
    device: string
    ip: string
    data: Table[string, string]

    progress: int

    layer_num: int
    layer_cur: int

    task: string
    stage: int

    bed_temp, bed_target_temp: Temperature
    nozzle_temp, nozzle_target_temp: Temperature
    chamber_temp: Temperature
    fan_part: int
    fan_aux: int
    fan_chamber: int

    filExt: Filament
    FilAms: array[16, Filament]

  Filament = object
    color: string
    brand: string
    typ: string



proc decode(b: Bambu, body: string) =

  let j = parseJSon(body)

  #echo j.pretty
 
  eraseScreen()
  setCursorPos(0, 0)

  proc get(key: string): JsonNode =
    var j = j
    for k in split(key, "."):
      case j.kind:
        of JObject:
          j = j[k]
        of JArray:
          j = j[k.parseInt()]
        else:
          discard
    return j
  
  proc getInt(val: var int, key: string, scale=1.0) =
    try:
      let j = get(key)
      val = if j.kind == JString: j.getStr().parseInt() else: j.getInt()
      val = (val.float * scale).int
    except:
      discard

  proc getFloat(val: var float, key: string, scale=1.0) =
    try:
      val = get(key).getFloat() * scale
    except:
      discard
  
  proc getString(val: var string, key: string) =
    try:
      val = get(key).getStr()
    except:
      discard

  proc getFilament(f: var Filament, prefix: string) =
    getString(f.color, prefix & ".tray_color")
    getString(f.brand, prefix & ".tray_sub_brands")
    getString(f.typ, prefix & ".tray_type")

  getString(b.task, "print.subtask_name")
  getInt(b.stage, "print.stg_cur")
  getInt(b.progress, "print.mc_percent")
  getInt(b.layer_num, "print.total_layer_num")
  getInt(b.layer_cur, "print.layer_num")
  getFloat(b.bed_temp, "print.bed_temper")
  getFloat(b.bed_target_temp, "print.bed_target_temper")
  getFloat(b.nozzle_temp, "print.nozzle_temper")
  getFloat(b.nozzle_target_temp, "print.nozzle_target_temper")
  getFloat(b.chamber_temp, "print.chamber_temper")
  getInt(b.fan_part, "print.cooling_fan_speed", 100/15.0)
  getInt(b.fan_aux, "print.big_fan1_speed", 100/15.0)
  getInt(b.fan_chamber, "print.big_fan2_speed", 100/15.0)
  getFilament(b.filExt, "print.vt_tray")
  getFilament(b.FilAms[0], "print.ams.ams.0.tray.0")
  getFilament(b.FilAms[1], "print.ams.ams.0.tray.1")
  getFilament(b.FilAms[2], "print.ams.ams.0.tray.2")
  getFilament(b.FilAms[3], "print.ams.ams.0.tray.3")




proc dump_filament(b: Bambu, label: string, f: Filament) =
  if f.typ != "":
    stdout.write "  " & label & ": "
    let c = f.color
    if c.len > 0:
      let color = rgb(c[0..1].parseHexInt(), c[2..3].parseHexInt(), c[4..5].parseHexInt())
      stdout.setBackgroundColor(color)
      stdout.write "   "
      stdout.resetAttributes()
      stdout.write(" ")
    stdout.styledWriteLine styleBright, f.typ & " " & f.brand


proc dump(b: Bambu) {.async.} =

  enableTrueColors()

  stdout.styledWriteLine "task: ", styleBright, b.task
  stdout.styledWriteLine "stage: ", styleBright, stage_str(b.stage) & " (" & $b.stage & ")"
  if b.progress > 0:
    stdout.styledWriteLine "progress: ", styleBright, $b.progress & "%, layer " & $b.layer_cur & "/" & $b.layer_num

  stdout.styledWriteLine "Temperatures:"
  stdout.styledWriteLine "  bed:     ", styleBright, $b.bed_temp & "°C (" & $b.bed_target_temp & "°C)"
  stdout.styledWriteLine "  nozzle:  ", styleBright, $b.nozzle_temp & "°C (" & $b.nozzle_target_temp & "°C)"
  stdout.styledWriteLine "  chamber: ", styleBright, $b.chamber_temp & "°C"

  stdout.styledWriteLine "Fans:"
  stdout.styledWriteLine "  part:    ", styleBright, $b.fan_part & "%"
  stdout.styledWriteLine "  aux:     ", styleBright, $b.fan_aux & "%"
  stdout.styledWriteLine "  chamber: ", styleBright, $b.fan_chamber & "%"

  stdout.styledWriteLine "Filament:"
  b.dump_filament("ext", b.filExt)
  for ams in 0..3:
    for spool in 0..3:
      b.dump_filament($(ams+1) & "." & $(spool+1), b.FilAms[ams * 4 + spool])




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
  await b.start(res.device, res.ip)


proc newBambu*(): Bambu =
  let bambu = Bambu()
  bambu.ctx = newMqttCtx("bambu")
  return bambu


