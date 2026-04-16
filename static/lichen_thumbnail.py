import tqdm
import numpy as np
from PIL import Image, ImageOps

WIDTH = 640
HEIGHT = 400
TOTAL_PIXELS = WIDTH * HEIGHT
SCALE = 2
FPS = 20
STEPS_PER_FRAME = 32000

MAX_BRIGHTNESS = 0x1E
SPREAD_THRESHOLD = 0x17
MAGIC_CONST = 0x5A6A6D6C

THUMBNAIL_FRAME = 1092 # Which frame to save as the thumbnail
OUTPUT_PATH = "../Lichen/thumbnail.bmp"

image_buffer = np.zeros(TOTAL_PIXELS, dtype=np.uint8)

esi = 0x00000361

center_idx = (HEIGHT // 2) * WIDTH + (WIDTH // 2)
image_buffer[center_idx] = MAX_BRIGHTNESS

for frame_num in tqdm.tqdm(range(THUMBNAIL_FRAME + 1)):
    for _ in range(STEPS_PER_FRAME):
        idx = 999999999
        while idx >= TOTAL_PIXELS:
            esi = (esi + MAGIC_CONST) & 0xFFFFFFFF
            esi = ((esi >> 1) | (esi << 31)) & 0xFFFFFFFF
            idx = esi & 0x000FFFFF

        px = image_buffer[idx]
        if px == 0:
            continue

        px -= 1
        image_buffer[idx] = px

        if px >= SPREAD_THRESHOLD:
            neighbors = [idx + 1, idx - 1, idx + WIDTH, idx - WIDTH]
            for n_idx in neighbors:
                if 0 <= n_idx < TOTAL_PIXELS:
                    image_buffer[n_idx] = image_buffer[n_idx] or MAX_BRIGHTNESS

frame_array = np.where(image_buffer > 0, image_buffer * 8, 0).reshape(HEIGHT, WIDTH)
im = np.kron(frame_array, np.ones((SCALE, SCALE), dtype=np.uint8))
img = ImageOps.invert(Image.fromarray(im, mode="L"))
img.save(OUTPUT_PATH)
print(f"Saved thumbnail from frame {THUMBNAIL_FRAME} to {OUTPUT_PATH}")
