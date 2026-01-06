import numpy as np

WIDTH = 768
HEIGHT = 480
STEPS = 100_000


def get_center(width, height):
    return (WIDTH // 2, HEIGHT // 2)


image = np.zeros((WIDTH, HEIGHT), dtype=np.uint8)
image[get_center(WIDTH, HEIGHT)] = 0xFF
print(image)
print(get_center(WIDTH, HEIGHT))
print(image[get_center(WIDTH, HEIGHT)])

np.random.seed(0x00000361)
for _ in range(STEPS):
    idx = np.random.randint(0, WIDTH * HEIGHT)
    x, y = np.ceil(idx / HEIGHT).astype(int) - 1, idx % HEIGHT
    # print(f"{idx}: ({x}, {y})")
    
    px = image[x, y]
    if px == 0:
        continue
    if px == 1:
        px = 0
    else:
        px -= 1
        
    if px > 0x17:
        for i in (-1, 0, 1):
            for j in (-1, 0, 1):
                if i == 0 and j == 0:
                    continue
                image[x+i, y+j] = 0xFF
