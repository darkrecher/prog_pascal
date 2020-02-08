import sys
import os
from create_bmp_file import Bitmap
from lbm_img_tools import color_indexes_from_lbm_chunk, palette_from_lbm_data


def main():

    turn_spr_filepath_default = os.sep.join(("..", "code_source_brut", "Anim", "turn.spr"))

    if len(sys.argv) > 1:
        turn_spr_filepath = sys.argv[1]
    else:
        turn_spr_filepath = turn_spr_filepath_default

    color_indexes = open(turn_spr_filepath, "rb").read()

    # Copié-collé des valeurs de la palette, récupérée à partir du code source.
    # (C'était écrit en dur à l'arrache dans l'animation).
    palette = [
        (0, 0, 0),
        (0, 0, 0),
        (63, 63, 63),
        (63, 58, 0),
        (60, 47, 26),
    ]
    # Même problème que ce que j'ai décrit dans le fichier lbm_img_tools.py
    # Je multiplie bêtement par 4, mais il est possible que ce ne soit pas du tout
    # comme ça qu'il faille faire.
    palette = [
        (r*4, g*4, b*4)
        for (r, g, b)
        in palette
    ]
    palette += [(0, 0, 0)] * 251

    x_spr, y_spr = (80, 10)

    bmp_img = Bitmap(x_spr, y_spr)
    y_cursor = 0
    col_index_cursor = 0

    for _ in range(y_spr):
        for x_cursor in range(x_spr):
            rgb_value = palette[color_indexes[col_index_cursor]]
            bmp_img.set_pixel(x_cursor, y_cursor, rgb_value)
            col_index_cursor += 1
        y_cursor += 1

    bmp_img.write("turn_spr.bmp")

    print("Fini.")


if __name__ == "__main__":
    main()
