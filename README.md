
![NPeg](/bambucli.png)

This is an experimental CLI interface to the Bambu printer family. I
exclusively use my printer in LAN only mode, and it makes me happy to see that
Bambu chose to use standard open protocols for their interface.



## Building

- `nimble install nmqtt`
- `nim c -d:ssl bambu.nim`


## Usage

Create a file `~/.bambu` containing one line with the IP address of your printer and the password, separated by a `:`, mine looks
like this:

```
10.0.0.30:734f29a1
```
 
run `./bambu`


## TODO

- basic control (pause, resume, etc)
- uPnP device discovery


Example JSON dump:

```
{
  "print": {
    "ams": {
      "ams": [
        {
          "humidity": "2",
          "id": "0",
          "temp": "35.4",
          "tray": [
            {
              "bed_temp": "45",
              "bed_temp_type": "1",
              "cali_idx": 9000,
              "cols": [
                "4C5F71FF"
              ],
              "ctype": 0,
              "drying_temp": "55",
              "drying_time": "8",
              "id": "0",
              "nozzle_temp_max": "230",
              "nozzle_temp_min": "190",
              "remain": 0,
              "tag_uid": "20B0225F00000100",
              "tray_color": "4C5F71FF",
              "tray_diameter": "1.75",
              "tray_id_name": "A00-B1",
              "tray_info_idx": "GFA00",
              "tray_sub_brands": "PLA Basic",
              "tray_type": "PLA",
              "tray_uuid": "493AD2525AF844A1896A85D339036C9E",
              "tray_weight": "1000",
              "xcam_info": "8813100EE803E8030000003F"
            },
            {
              "bed_temp": "35",
              "bed_temp_type": "1",
              "cali_idx": 8891,
              "cols": [
                "DDE5EDFF"
              ],
              "ctype": 0,
              "drying_temp": "55",
              "drying_time": "8",
              "id": "1",
              "nozzle_temp_max": "230",
              "nozzle_temp_min": "190",
              "remain": 0,
              "tag_uid": "0D57FB9300000100",
              "tray_color": "DDE5EDFF",
              "tray_diameter": "1.75",
              "tray_id_name": "A09-W3",
              "tray_info_idx": "GFA09",
              "tray_sub_brands": "PLA Tough",
              "tray_type": "PLA",
              "tray_uuid": "B979F0B6EF424B37A34E93B50BA32024",
              "tray_weight": "1000",
              "xcam_info": "A4388813E803E803CDCC4C3F"
            },
            {
              "id": "2"
            },
            {
              "bed_temp": "0",
              "bed_temp_type": "0",
              "cali_idx": -1,
              "cols": [
                "698D95FE"
              ],
              "ctype": 0,
              "drying_temp": "0",
              "drying_time": "0",
              "id": "3",
              "nozzle_temp_max": "240",
              "nozzle_temp_min": "190",
              "remain": 0,
              "tag_uid": "0000000000000000",
              "tray_color": "698D95FE",
              "tray_diameter": "0.00",
              "tray_id_name": "",
              "tray_info_idx": "GFL99",
              "tray_sub_brands": "",
              "tray_type": "PLA",
              "tray_uuid": "00000000000000000000000000000000",
              "tray_weight": "0",
              "xcam_info": "000000000000000000000000"
            }
          ]
        }
      ],
      "ams_exist_bits": "1",
      "insert_flag": true,
      "power_on_flag": false,
      "tray_exist_bits": "f",
      "tray_is_bbl_bits": "b",
      "tray_now": "0",
      "tray_pre": "0",
      "tray_read_done_bits": "f",
      "tray_reading_bits": "0",
      "tray_tar": "0",
      "version": 289
    },
    "ams_rfid_status": 2,
    "ams_status": 768,
    "aux_part_fan": true,
    "bed_target_temper": 55,
    "bed_temper": 55,
    "big_fan1_speed": "10",
    "big_fan2_speed": "8",
    "cali_version": 0,
    "chamber_temper": 41,
    "command": "push_status",
    "cooling_fan_speed": "15",
    "fail_reason": "0",
    "fan_gear": 10072831,
    "filam_bak": [],
    "force_upgrade": false,
    "gcode_file": "/data/Metadata/plate_1.gcode",
    "gcode_file_prepare_percent": "100",
    "gcode_start_time": "1694697808",
    "gcode_state": "RUNNING",
    "heatbreak_fan_speed": "15",
    "hms": [],
    "home_flag": 114959,
    "hw_switch_state": 1,
    "ipcam": {
      "ipcam_dev": "1",
      "ipcam_record": "disable",
      "mode_bits": 2,
      "resolution": "1080p",
      "rtsp_url": "rtsps://10.0.0.30/streaming/live/1",
      "timelapse": "disable",
      "tutk_server": "disable"
    },
    "layer_num": 52,
    "lifecycle": "product",
    "lights_report": [
      {
        "mode": "on",
        "node": "chamber_light"
      },
      {
        "mode": "flashing",
        "node": "work_light"
      }
    ],
    "maintain": 3,
    "mc_percent": 97,
    "mc_print_error_code": "0",
    "mc_print_stage": "2",
    "mc_print_sub_stage": 0,
    "mc_remaining_time": 2,
    "mess_production_state": "active",
    "msg": 0,
    "nozzle_diameter": "0.4",
    "nozzle_target_temper": 220,
    "nozzle_temper": 220,
    "nozzle_type": "hardened_steel",
    "online": {
      "ahb": false,
      "ext": false,
      "version": 9
    },
    "print_error": 0,
    "print_gcode_action": 0,
    "print_real_action": 0,
    "print_type": "local",
    "profile_id": "0",
    "project_id": "0",
    "queue_est": 0,
    "queue_number": 0,
    "queue_sts": 0,
    "queue_total": 0,
    "s_obj": [],
    "sdcard": true,
    "sequence_id": "11199",
    "spd_lvl": 2,
    "spd_mag": 100,
    "stg": [
      2,
      14,
      13
    ],
    "stg_cur": 0,
    "subtask_id": "0",
    "subtask_name": "shimano-002_plate_1",
    "task_id": "2247",
    "total_layer_num": 58,
    "upgrade_state": {
      "ahb_new_version_number": "",
      "ams_new_version_number": "",
      "consistency_request": false,
      "dis_state": 0,
      "err_code": 0,
      "ext_new_version_number": "",
      "force_upgrade": false,
      "idx": 9,
      "message": "",
      "module": "null",
      "new_version_state": 0,
      "ota_new_version_number": "",
      "progress": "0",
      "sequence_id": 0,
      "sn": "00M09A330500140",
      "status": "IDLE"
    },
    "upload": {
      "file_size": 0,
      "finish_size": 0,
      "message": "Good",
      "oss_url": "",
      "progress": 0,
      "sequence_id": "0903",
      "speed": 0,
      "status": "idle",
      "task_id": "",
      "time_remaining": 0,
      "trouble_id": ""
    },
    "vt_tray": {
      "bed_temp": "0",
      "bed_temp_type": "0",
      "cali_idx": -1,
      "cols": [
        "00000000"
      ],
      "ctype": 0,
      "drying_temp": "0",
      "drying_time": "0",
      "id": "254",
      "nozzle_temp_max": "0",
      "nozzle_temp_min": "0",
      "remain": 0,
      "tag_uid": "0000000000000000",
      "tray_color": "00000000",
      "tray_diameter": "0.00",
      "tray_id_name": "",
      "tray_info_idx": "",
      "tray_sub_brands": "",
      "tray_type": "PLA",
      "tray_uuid": "00000000000000000000000000000000",
      "tray_weight": "0",
      "xcam_info": "000000000000000000000000"
    },
    "wifi_signal": "-37dBm",
    "xcam": {
      "allow_skip_parts": false,
      "buildplate_marker_detector": true,
      "first_layer_inspector": true,
      "halt_print_sensitivity": "medium",
      "print_halt": true,
      "printing_monitor": true,
      "spaghetti_detector": true
    },
    "xcam_status": "0"
  }
}
```

