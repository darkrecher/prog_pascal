from create_bmp_file import Bitmap


def color_indexes_from_lbm_chunk(bytes_lbm_chunks, cursor=0, verbose=True):
    """
    Un chunk est constitué d'un ou plusieurs blocs.
    Les blocs ensemble sont constitués de parts.
    """
    merged_block_data = []
    cursor = 0
    block_size = None
    block_index = 0
    while cursor < len(bytes_lbm_chunks) and (block_size is None or block_size == 3768):

        block_size = list(map(int, bytes_lbm_chunks[cursor:cursor+4]))
        cursor += 4

        block_size = sum([
            byte*(256**offset)
            for byte, offset
            in zip(block_size, range(4))
        ])

        if verbose:
            print("Block numéro %s. Taille : %s" % (block_index, block_size))

        merged_block_data += list(map(int, bytes_lbm_chunks[cursor:cursor+block_size]))
        cursor += block_size
        block_index += 1

    color_indexes = []
    while merged_block_data:
        part_header = merged_block_data.pop(0)
        if part_header > 128:
            part_body = merged_block_data.pop(0)
            color_indexes += [ part_body ] * (257-part_header)
        else:
            body_size = part_header + 1
            part_body = merged_block_data[:body_size]
            merged_block_data = merged_block_data[body_size:]
            color_indexes += part_body

    if verbose:
        print("Nombres de pixels : %s" % len(color_indexes))
        if len(color_indexes) != 64000:
            print("Warning. La taille de l'image devrait être de 64000 pixels (320x200).")

    return color_indexes


def palette_from_lbm_data(bytes_lbm_chunks, cursor=0, verbose=True):

    if len(bytes_lbm_chunks) != 768:
        raise ValueError("La taille du chunk de palette doit être de 768 octets")
    bytes_palette = list(map(int, bytes_lbm_chunks))
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

