
proc stage_str*(stage: int): string =
  case stage
    of 0: "Printing"
    of 1: "Auto bed leveling"
    of 2: "Heatbed preheating"
    of 3: "Sweeping XY mech mode"
    of 4: "Changing filament"
    of 5: "M400 pause"
    of 6: "Paused due to filament runout"
    of 7: "Heating hotend"
    of 8: "Calibrating extrusion"
    of 9: "Scanning bed surface"
    of 10: "Inspecting first layer"
    of 11: "Identifying build plate type"
    of 12: "Calibrating Micro Lidar"
    of 13: "Homing toolhead"
    of 14: "Cleaning nozzle tip"
    of 15: "Checking extruder temperature"
    of 16: "Printing was paused by the user"
    of 17: "Pause of front cover falling"
    of 18: "Calibrating the micro lida"
    of 19: "Calibrating extrusion flow"
    of 20: "Paused due to nozzle temperature malfunction"
    of 21: "Paused due to heat bed temperature malfunction"
    else: "?"


