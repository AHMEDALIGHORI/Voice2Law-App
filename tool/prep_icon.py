"""Prepare the Voice2Law launcher icon set from the generated emblem.

Outputs (all 1024x1024):
  assets/images/icon.png           - full-bleed legacy icon
  assets/images/icon_foreground.png - adaptive foreground, emblem scaled into
                                     the 66% safe zone over the same green
Prints the sampled background hex for pubspec adaptive_icon_background.
"""
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "vibe_images" / "voice2law-icon-main_1791544030187_8d46220e.png"
OUT_ICON = ROOT / "assets" / "images" / "icon.png"
OUT_FG = ROOT / "assets" / "images" / "icon_foreground.png"

img = Image.open(SRC).convert("RGB")
if img.size != (1024, 1024):
    img = img.resize((1024, 1024), Image.LANCZOS)

# Add a restrained gold ring so the emblem stays legible at launcher size.
draw = ImageDraw.Draw(img)
draw.ellipse((38, 38, 986, 986), outline=(197, 162, 83), width=10)

# Sample the background from the four corners (average).
corners = [img.getpixel((x, y)) for x, y in ((8, 8), (1015, 8), (8, 1015), (1015, 1015))]
avg = tuple(sum(c[i] for c in corners) // 4 for i in range(3))
hexcolor = "#{:02X}{:02X}{:02X}".format(*avg)
print("sampled background:", hexcolor)

# 1) Legacy / iOS full-bleed icon.
img.save(OUT_ICON, "PNG")

# 2) Adaptive foreground: emblem scaled to 74% centered on the same green so
#    circular masks never clip the scales.
fg = Image.new("RGB", (1024, 1024), avg)
inner = img.resize((768, 768), Image.LANCZOS)
fg.paste(inner, ((1024 - 768) // 2, (1024 - 768) // 2))
fg.save(OUT_FG, "PNG")
print("wrote", OUT_ICON.name, "and", OUT_FG.name)
