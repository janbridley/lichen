import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation

# --- Configuration ---
WIDTH = 768
HEIGHT = 480
# WIDTH = 320
# HEIGHT = 200
TOTAL_PIXELS = WIDTH * HEIGHT
FPS = 60
STEPS_PER_FRAME = 4000
STEPS_PER_FRAME = 64000

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

fig, ax = plt.subplots(figsize=(10, 6), facecolor="black")

im = ax.imshow(
    image_buffer.reshape(HEIGHT, WIDTH),
    cmap="gray",
    vmin=0,
    vmax=MAX_BRIGHTNESS,
    interpolation=None,
)
ax.set_axis_off()


def update(frame):
    global esi
    for _ in range(STEPS_PER_FRAME):
        # "esi += 0x5A6A6D6C"
        # "rotate the bits of esi right once"
        # "if si < 0xFA00, return... else call pRNG(esi)"

        while True:
            # integer add with 32-bit wrap
            esi = (esi + MAGIC_CONST) & 0xFFFFFFFF

            # ROR 1 (Rotate Right 1 bit)
            esi = ((esi >> 1) | (esi << 31)) & 0xFFFFFFFF

            # "si" is the lower 16 bits
            idx = esi & 0xFFFF

            # If valid pixel index, break loop. If not (overflow), generate again.
            if idx < TOTAL_PIXELS:
                break

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

    # Update visual
    im.set_array(image_buffer.reshape(HEIGHT, WIDTH))
    
    return [im]


ani = FuncAnimation(
    fig,
    update,
    frames=None,
    interval=1000 / 60,
    blit=True,
    cache_frame_data=False
)

plt.show()
