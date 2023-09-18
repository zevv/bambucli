import tables

let colors = {
  # https://eu.store.bambulab.com/products/pla-basic-filament 
  "PLA Basic": {
    "FFFFFFFF": "Jade White",
    "F7E6DEFF": "Beige",
    "E4BD68FF": "Glod",
    "A6A9AAFF": "Silver",
    "8E9089FF": "Gray",
    "847D48FF": "Bronze",
    "9D432CFF": "Brown",
    "C12E1FFF": "Red",
    "EC008CFF": "Magenta",
    "F55A74FF": "Pink",
    "FF6A13FF": "Orange",
    "F4EE2AFF": "Yellow",
    "16C344FF": "Bambu Green",
    "0086D6FF": "Cyan",
    "164B35FF": "Green",
    "0A2989FF": "Blue",
    "5E43B7FF": "Purple",
    "5B6579FF": "Blue Gray",
    "000000FF": "Black",
  }.toTable(),

  # https://eu.store.bambulab.com/products/pla-matte-filament
  "PLA Matte": {
    "FFFFFFFF": "Ivory White",
    "D3B7A7FF": "Latte Brown",
    "9B9EA0FF": "Ash Gray",
    "AE96D4FF": "Lilac Purple",
    "E8AFCFFF": "Sakura Pink",
    "F99963FF": "Mandarin Orange",
    "F7D959FF": "Lemon Yellow",
    "DE4343FF": "Scarlet Red",
    "BB3D43FF": "Dark Red",
    "7D6556FF": "Dark Brown",
    "68724DFF": "Dark Green",
    "61C680FF": "Grass Green",
    "A3D8E1FF": "Ice Blue",
    "0078BFFF": "Marine Blue",
    "042F56FF": "Dark Blue",
    "000000FF": "Charcoal",
  }.toTable(),

}.toTable()


proc filament_color_name*(typ: string, color: string): string =
  result = color
  if typ in colors:
    if color in colors[typ]:
      result = colors[typ][color]
