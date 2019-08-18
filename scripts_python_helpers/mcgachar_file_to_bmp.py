import sys
import os
from create_bmp_file import Bitmap

CHARACTER_HEIGHT_PIXEL = 8
CHARACTER_WIDTH_PIXEL = 7
MCGACHAR_FILE_SIZE_BYTE = 2688
BMP_WIDTH_CHARACTER = 8


def paint_character(char_pixels, bmp_img, corner_x, corner_y):

    for index, pixel_value in enumerate(char_pixels):

        x = corner_x + index % CHARACTER_WIDTH_PIXEL
        y = corner_y + index // CHARACTER_WIDTH_PIXEL

        # Cas particulier pour mieux représenter les caractères dans l'image.
        # En fait dans le fichier MCGACHAR, il n'y a que des valeurs 0, 8 et 255.
        # Quand c'est 8, on met une couleur un peu plus claire, sinon on ne la voit pas bien.
        pix = int(pixel_value)
        if pix == 8:
            pix = 50

        bmp_img.set_pixel(x, y, [pix] * 3)


def main():

    if len(sys.argv) > 1:
        mcgachar_filepath = sys.argv[1]
    else:
        mcgachar_filepath = os.sep.join(("..", "code_source_brut", "Anim", "MCGACHAR"))

    data = open(mcgachar_filepath, "rb").read()

    if len(data) != MCGACHAR_FILE_SIZE_BYTE:
        warn_msg = "Warning: la taille du fichier %s devrait être de %s octets."
        print(warn_msg % (mcgachar_filepath, MCGACHAR_FILE_SIZE_BYTE))
        print("On va faire au mieux avec ce qu'on a.")
        data = data + b"\x00" * MCGACHAR_FILE_SIZE_BYTE
        data = data[:MCGACHAR_FILE_SIZE_BYTE]

    bmp_width_pixel = 1 + BMP_WIDTH_CHARACTER * (CHARACTER_WIDTH_PIXEL + 1)
    nb_pixels_one_char = CHARACTER_HEIGHT_PIXEL * CHARACTER_WIDTH_PIXEL
    nb_characters = MCGACHAR_FILE_SIZE_BYTE // nb_pixels_one_char
    bmp_height_character = nb_characters // BMP_WIDTH_CHARACTER
    if nb_characters % BMP_WIDTH_CHARACTER:
        bmp_height_character += 1
    bmp_height_pixel = 1 + bmp_height_character * (CHARACTER_HEIGHT_PIXEL + 1)

    # La largeur de l'image doit être un multiple de 4, sinon la création de bmp plante.
    # (Y'a moyen de faire mieux, mais osef).
    bmp_width_pixel_real = bmp_width_pixel + (4 - bmp_width_pixel % 4) % 4
    print(
        "largeur: %s. largeur multiple de 4: %s. hauteur: %s."
        % (bmp_width_pixel, bmp_width_pixel_real, bmp_height_pixel)
    )
    bmp_img = Bitmap(bmp_width_pixel_real, bmp_height_pixel)

    for y_line in range(0, bmp_height_pixel, CHARACTER_HEIGHT_PIXEL + 1):
        for x in range(0, bmp_width_pixel):
            bmp_img.set_pixel(x, y_line, (100, 100, 100))
    for x_column in range(0, bmp_width_pixel, CHARACTER_WIDTH_PIXEL + 1):
        for y in range(0, bmp_height_pixel):
            bmp_img.set_pixel(x_column, y, (100, 100, 100))

    for idx_char in range(nb_characters):
        corner_x = 1 + (idx_char % BMP_WIDTH_CHARACTER) * (CHARACTER_WIDTH_PIXEL + 1)
        corner_y = 1 + (idx_char // BMP_WIDTH_CHARACTER) * (CHARACTER_HEIGHT_PIXEL + 1)
        index_data_start = idx_char * nb_pixels_one_char
        index_data_end = (idx_char + 1) * nb_pixels_one_char
        paint_character(
            data[index_data_start:index_data_end], bmp_img, corner_x, corner_y
        )

    bmp_img.write("mcgachar.bmp")


if __name__ == "__main__":
    main()
