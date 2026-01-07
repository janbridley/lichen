import numpy as np
from PIL import Image, ImageOps
from tqdm import tqdm

# Twice the default resolution -- changes the appearence, but is nice to have
WIDTH = 640
HEIGHT = 400
TOTAL_PIXELS = WIDTH * HEIGHT
SCALE = 2
FPS = 20
# STEPS_PER_FRAME = 8000
STEPS_PER_FRAME = 32000

MAX_BRIGHTNESS = 0x1E  # 30 (The 'spore' brightness)
SPREAD_THRESHOLD = 0x17  # 23 (Minimum brightness to spread)
MAGIC_CONST = 0x5A6A6D6C  # LCG constant

image_buffer = np.zeros(TOTAL_PIXELS, dtype=np.uint8)

esi = 0x00000361

# Place the initial spore at center
center_idx = (HEIGHT // 2) * WIDTH + (WIDTH // 2)
image_buffer[center_idx] = MAX_BRIGHTNESS

frames = []
total_frames = FPS * 60  # 60 seconds at FPS

for frame_num in tqdm(range(total_frames)):
    for _ in range(STEPS_PER_FRAME):
        idx = 999999999
        while idx >= TOTAL_PIXELS:
            esi = (esi + MAGIC_CONST) & 0xFFFFFFFF

            esi = ((esi >> 1) | (esi << 31)) & 0xFFFFFFFF

            idx = esi & 0x000FFFFF

        px = image_buffer[idx]
        if px == 0:
            continue

        # Dim the pixel by one value
        px -= 1
        image_buffer[idx] = px  # px--

        if px >= SPREAD_THRESHOLD:
            # Update the pixel's Von Neumann neighborhood
            neighbors = [idx + 1, idx - 1, idx + WIDTH, idx - WIDTH]

            for n_idx in neighbors:
                # Horizontal, but no vertical periodicity
                if 0 <= n_idx < TOTAL_PIXELS:
                    image_buffer[n_idx] = image_buffer[n_idx] or MAX_BRIGHTNESS
                # Horizontal and vertical periodicity
                # image_buffer[n_idx % TOTAL_PIXELS] = (
                #     image_buffer[n_idx % TOTAL_PIXELS] or MAX_BRIGHTNESS
                # )

    frame_array = np.where(image_buffer > 0, image_buffer * 8, 0).reshape(HEIGHT, WIDTH)
    im = np.kron(frame_array, np.ones((SCALE, SCALE), dtype=np.uint8))
    frames.append(ImageOps.invert(Image.fromarray(im, mode="L")))

frames[0].save(
    f"lichen_2x_{SCALE}x_{FPS}fps_opt.gif",
    save_all=True,
    append_images=frames[1:],
    duration=1000 // FPS,
    loop=0,
    optimize=True,
)
