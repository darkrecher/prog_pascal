from create_bmp_file import Bitmap



def color_indexes_from_lbm_chunk(bytes_lbm_block, cursor=0, verbose=True, must_check=False):
    """
        Blabla.
    Les 4 premiers octets indiquent la taille du bloc.
    Et ensuite on a tout le bloc.
    """
    block_data = []
    cursor = 0
    block_size = list(map(int, bytes_lbm_block[cursor:cursor+4]))
    cursor += 4

    block_size = sum([
        byte*(256**offset)
        for byte, offset
        in zip(block_size, range(4))
    ])

    if verbose:
        print("Taille du bloc : %s." % block_size)

    block_data += list(map(int, bytes_lbm_block[cursor:cursor+block_size]))
    cursor += block_size

    if must_check:
        if cursor != len(bytes_lbm_block):
            msg = "Taille de bloc indiqué (%s) différente de la taille de bloc réelle (%s)."
            raise Exception(msg % (cursor, len(bytes_lbm_block)))

    color_indexes = []
    while block_data:
        part_header = block_data.pop(0)
        if part_header > 128:
            part_body = block_data.pop(0)
            color_indexes += [ part_body ] * (257-part_header)
        else:
            body_size = part_header + 1
            part_body = block_data[:body_size]
            block_data = block_data[body_size:]
            color_indexes += part_body

    if verbose:
        print("Nombres de pixels : %s" % len(color_indexes))
        if len(color_indexes) != 64000:
            print("Warning. La taille de l'image devrait être de 64000 pixels (320x200).")

    return color_indexes


def palette_from_lbm_data(bytes_lbm_block, cursor=0, verbose=True):

    if len(bytes_lbm_block) != 768:
        raise ValueError("La taille du chunk de palette doit être de 768 octets")
    bytes_palette = list(map(int, bytes_lbm_block))
    if verbose:
        print("Valeur max des RVB de la palette : %s" % max(bytes_palette))

    if max(bytes_palette) <= 63:
        color_factor = 4
    else:
        color_factor = 1

    palette = tuple([
        # C'est étrange, je ne me souviens pas qu'il fallait multiplier par 4
        # toutes les valeurs RVB de la palette. Mais manifestement, c'est ce qu'il
        # faut faire pour re-obtenir les images des jeux. Donc multiplions.
        (red*color_factor, blue*color_factor, green*color_factor)
        for (red, blue, green)
        in zip(
            bytes_palette[::3],
            bytes_palette[1::3],
            bytes_palette[2::3],
        )
    ])
    return palette


def cmap_body_from_lbm_file(filepath_lbm):

    # Gros bourrin. Osef.
    all_data = open(filepath_lbm, "rb").read()
    print(all_data[:100])
    # FORM\x00\x00jvPBM BMHD\x00\x00\x00\x14\x01@\x00\xc8\x00\x00\x00\x00\x08\x00\x01\x00\x00\x00\x05\x06\x01@\x00\xc8CMAP\

    cursor = 0
    initial_name = str(all_data[cursor:cursor + 4], encoding="ascii", errors="replace")
    print(initial_name)
    cursor += 4

    # TODO : duplicate code.
    block_size = list(map(int, all_data[cursor:cursor + 4]))
    cursor += 4

    # TODO : Pourquoi là c'est à l'envers [::-1] et pas dans la fonction d'avant ?
    block_size = sum([
        byte*(256**offset)
        for byte, offset
        in zip(block_size[::-1], range(4))
    ])
    print("size : ", block_size) # taille du fichier -8
    total_size = block_size

    other_name = str(all_data[cursor:cursor + 4], encoding="ascii", errors="replace")
    print(other_name)
    cursor += 4

    # Ensuite, à priori, on rentre dans une bouboucle.

    while cursor < total_size:

        current_name = str(all_data[cursor:cursor + 4], encoding="ascii", errors="replace")
        print(current_name)
        cursor += 4

        block_size = list(map(int, all_data[cursor:cursor + 4]))
        cursor += 4

        # TODO : Pourquoi là c'est à l'envers [::-1] et pas dans la fonction d'avant ?
        block_size = sum([
            byte*(256**offset)
            for byte, offset
            in zip(block_size[::-1], range(4))
        ])
        print("size : ", block_size)

        if current_name == "BODY":
            body_data = all_data[cursor-4:cursor + block_size + block_size % 2]
        elif current_name == "CMAP":
            cmap_data = all_data[cursor:cursor + block_size + block_size % 2]


        cursor += block_size + block_size % 2

    ## TODO : crap
    """
    current_name = str(all_data[cursor:cursor + 4], encoding="ascii", errors="replace")
    print(current_name)
    cursor += 4

    block_size = list(map(int, all_data[cursor:cursor + 4]))
    cursor += 4

    # TODO : Pourquoi là c'est à l'envers [::-1] et pas dans la fonction d'avant ?
    block_size = sum([
        byte*(256**offset)
        for byte, offset
        in zip(block_size[::-1], range(4))
    ])
    print("size : ", block_size)

    cursor += block_size
    """

    palette = palette_from_lbm_data(cmap_data)
    color_indexes = color_indexes_from_lbm_chunk(body_data)
    #print(col_indexes)
    #print(palette)

    bmp_img = Bitmap(320, 200)
    x_cursor = 0
    y_cursor = 0
    for color_index in color_indexes:
        #rgb_value = [ (color_index*20) & 255 ] * 3
        rgb_value = palette[color_index]
        #rgb_value = [ (color_index*4) & 255 ] * 3
        bmp_img.set_pixel(x_cursor, y_cursor, rgb_value)
        x_cursor += 1
        if x_cursor >= 320:
            x_cursor = 0
            y_cursor += 1

    bmp_img.write("alpha4.bmp")
    print("Fini.")



# TODO crap
def main():
    cmap_body_from_lbm_file("..\\code_source_brut\\Games\\pong\\ALPHA4.LBM")


if __name__ == "__main__":
    main()