import numpy as np
from PIL import Image

# --- Configuration ---
# WIDTH = 768
# HEIGHT = 480
WIDTH = 320
HEIGHT = 200
TOTAL_PIXELS = WIDTH * HEIGHT
FPS = 20
STEPS_PER_FRAME = 4000
# STEPS_PER_FRAME = 64000

MAX_BRIGHTNESS = 0x1E  # 30 (The 'spore' brightness)
SPREAD_THRESHOLD = 0x17  # 23 (Minimum brightness to spread)
MAGIC_CONST = 0x5A6A6D6C  # The virus LCG constant

# 1D Linear Memory (mimics VGA Segment A000)
image_buffer = np.zeros(TOTAL_PIXELS, dtype=np.uint8)

# Initial Seed specified in the analysis
esi = 0x00000361

# Place the initial spore at center
center_idx = (HEIGHT // 2) * WIDTH + (WIDTH // 2)
image_buffer[center_idx] = MAX_BRIGHTNESS

frames = []
total_frames = FPS * 30  # 30 seconds at FPS

print("Generating frames...")
for frame_num in range(total_frames):
    print(f"frame {frame_num + 1}/{total_frames}")
    for _ in range(STEPS_PER_FRAME):
        # "esi += 0x5A6A6D6C"
        # "rotate the bits of esi right once"
        # "if si < 0xFA00, return... else call pRNG(esi)"

        # integer add with 32-bit wrap
        esi = (esi + MAGIC_CONST) & 0xFFFFFFFF

        # ROR 1 (Rotate Right 1 bit)
        esi = ((esi >> 1) | (esi << 31)) & 0xFFFFFFFF

        # Use full 32 bits for indexing to support larger resolutions
        idx = esi % TOTAL_PIXELS

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

    # bitmapData[i] = val ? (uint8_t)((val * 255) / kMaxBrightness) : 0;
    # scaled = (image_buffer * 255 / MAX_BRIGHTNESS).astype(np.uint8)
    print(image_buffer.min(), image_buffer.max())
    frame_array = np.where(image_buffer > 0, image_buffer * 255, 0).reshape(
        HEIGHT, WIDTH
    )
    frames.append(Image.fromarray(frame_array, mode="L"))

print(f"Saving GIF...")
frames[0].save(
    f"lichen_320x200_30sec_{FPS}fps.gif",
    save_all=True,
    append_images=frames[1:],
    duration=1000 // FPS,
    loop=0,
    optimize=False,
)
print("Saved to lichen_320x200_30sec_20fps.gif")
