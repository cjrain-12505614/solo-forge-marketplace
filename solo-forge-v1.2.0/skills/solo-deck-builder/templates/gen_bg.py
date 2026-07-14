# 중립 다크 발표자료 배경 생성 (PIL+numpy) — solo-deck-builder
# 출력: /tmp/pptx_build/{bg_body.png, bg_cover.png, grad_h.png}
# 브랜드 색이 있으면 base / blue / purple 값만 바꾼다.
import os
import numpy as np
from PIL import Image, ImageFilter

OUT = "/tmp/pptx_build"
os.makedirs(OUT, exist_ok=True)
W, H = 1280, 720

base   = np.array([12, 14, 26.])   # 딥 네이비 배경
blue   = np.array([91, 124, 255.]) # 액센트 1
purple = np.array([167, 139, 250.])# 액센트 2

def make_bg(path, cover=False):
    img = np.tile(base, (H, W, 1))
    yy, xx = np.mgrid[0:H, 0:W].astype(float)
    ang = np.radians(122)
    d = xx*np.cos(ang) + yy*np.sin(ang)
    d = (d - d.min()) / (d.max() - d.min())
    bands = [(0.80, blue, 0.30), (0.87, purple, 0.18), (0.74, blue, 0.13), (0.92, purple, 0.08)]
    if cover:
        bands = [(0.78, blue, 0.42), (0.86, purple, 0.30), (0.70, blue, 0.20), (0.93, purple, 0.12)]
    for c, col, amp in bands:
        w = 0.045 if cover else 0.035
        img += (np.exp(-((d - c)**2) / (2*w**2)) * amp)[..., None] * col
    cx, cy = (0.18*W, 0.86*H)
    rr = np.sqrt((xx - cx)**2 + (yy - cy)**2)
    img += (np.exp(-(rr**2) / (2*(0.30*W)**2)) * 0.10)[..., None] * blue
    Image.fromarray(np.clip(img, 0, 255).astype('uint8')).filter(ImageFilter.GaussianBlur(2.5)).save(path)

make_bg(os.path.join(OUT, "bg_body.png"))
make_bg(os.path.join(OUT, "bg_cover.png"), cover=True)

# 가로 그라데이션 칩
gw, gh = 800, 80
g = np.zeros((gh, gw, 3))
for x in range(gw):
    t = x / (gw - 1)
    g[:, x] = blue * (1 - t) + purple * t
Image.fromarray(g.astype('uint8')).save(os.path.join(OUT, "grad_h.png"))
print("배경 3종 생성:", OUT)
