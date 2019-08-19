import sys
import os
from create_bmp_file import Bitmap
from lbm_img_tools import (
    color_indexes_from_lbm_chunk,
    palette_from_lbm_data
)


def main():

    if len(sys.argv) > 1:
        bombman_spr_filepath = sys.argv[1]
    else:
        bombman_spr_filepath = os.sep.join(("..", "code_source_brut", "Bomb", "BOMBMAN.SPR"))

    if len(sys.argv) > 2:
        bombman_pal_filepath = sys.argv[2]
    else:
        bombman_pal_filepath = os.sep.join(("..", "code_source_brut", "Bomb", "BOMBMAN.PAL"))

    lbm_chunk = open(bombman_spr_filepath, "rb").read()
    color_indexes = color_indexes_from_lbm_chunk(lbm_chunk)

    lbm_chunk_pal = open(bombman_pal_filepath, "rb").read()
    palette = palette_from_lbm_data(lbm_chunk_pal)

    # TODO : ceci devrait aller dans une fonction du fichier lbm_img_tools.

    bmp_img = Bitmap(320, 200)
    x_cursor = 0
    y_cursor = 0
    for color_index in color_indexes:
        #rgb_value = [ (color_index*20) & 255 ] * 3
        rgb_value = palette[color_index]
        bmp_img.set_pixel(x_cursor, y_cursor, rgb_value)
        x_cursor += 1
        if x_cursor >= 320:
            x_cursor = 0
            y_cursor += 1

    bmp_img.write("bombman.bmp")
    print("Fini.")


if __name__ == "__main__":
    main()
