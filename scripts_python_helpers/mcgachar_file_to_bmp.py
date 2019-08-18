import sys
import os
from create_bmp_file import Bitmap

CHARACTER_HEIGHT_PIXEL = 8
CHARACTER_WIDTH_PIXEL = 7
MCGACHAR_FILE_SIZE_BYTE = 2688
BMP_WIDTH_CHARACTER = 8


def main():
    #side = 520
    #b = Bitmap(side, side)
    #for j in range(0, side):
    #  b.set_pixel(j, j, (255, 0, 0))
    #  b.set_pixel(j, side-j-1, (255, 0, 0))
    #  b.set_pixel(j, 0, (255, 0, 0))
    #  b.set_pixel(j, side-1, (255, 0, 0))
    #  b.set_pixel(0, j, (255, 0, 0))
    #  b.set_pixel(side-1, j, (255, 0, 0))
    #b.write('file.bmp')

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

    #print(data)
    bmp_width_pixel = BMP_WIDTH_CHARACTER*(CHARACTER_WIDTH_PIXEL+1) + 1
    nb_characters = MCGACHAR_FILE_SIZE_BYTE // (CHARACTER_HEIGHT_PIXEL*CHARACTER_WIDTH_PIXEL)
    bmp_height_character = nb_characters // BMP_WIDTH_CHARACTER + int((nb_characters%BMP_WIDTH_CHARACTER) > 0)
    bmp_height_pixel = bmp_height_character*(CHARACTER_HEIGHT_PIXEL+1) + 1

    print(bmp_width_pixel, bmp_height_pixel)

    #bmp_img = Bitmap(bmp_width_pixel, bmp_height_pixel)
    # TODO : expliquer que le script de génération des bmp plante et faut utiliser des astuces à la con.
    # TODO 2 : ou alors, faut juste que ce soit un multiple de 4 ou de 8.
    # Pas forcément une puissance de 2. À tester.
    bmp_width_pixel_real = 2**(len(bin(bmp_width_pixel))-2)
    bmp_img = Bitmap(bmp_width_pixel_real, bmp_height_pixel)
    for y_line in range(0, bmp_height_pixel, CHARACTER_HEIGHT_PIXEL+1):
        for x in range(0, bmp_width_pixel):
            bmp_img.set_pixel(x, y_line, (100, 100, 100))
    for x_column in range(0, bmp_width_pixel, CHARACTER_WIDTH_PIXEL+1):
        for y in range(0, bmp_height_pixel):
            bmp_img.set_pixel(x_column, y, (100, 100, 100))

    bmp_img.write('mcgachar.bmp')


if __name__ == '__main__':
    main()


