import sys
import os
from create_bmp_file import Bitmap
from lbm_img_tools import color_indexes_from_lbm_chunk, palette_from_lbm_data


def main():

    pong_directory = os.sep.join(("..", "code_source_brut", "Games", "PONG"))

    if len(sys.argv) > 1:
        pong_spr_filepath = sys.argv[1]
    else:
        pong_spr_filepath = pong_directory + os.sep + "PONG.SPR"

    if len(sys.argv) > 2:
        pong_pal_filepath = sys.argv[2]
    else:
        pong_pal_filepath = pong_directory + os.sep + "PONG.PAL"

    if len(sys.argv) > 3:
        pong_img_filepath = sys.argv[3]
    else:
        pong_img_filepath = pong_directory + os.sep + "PONG.IMG"

    color_indexes = open(pong_spr_filepath, "rb").read()

    lbm_chunk_pal = open(pong_pal_filepath, "rb").read()
    palette = palette_from_lbm_data(lbm_chunk_pal)

    # Cursor:Array[0..8,0..4] of Byte;
    # Sprite:Array[0..4,0..4] of Byte;
    # Rectangle:Array[0..57,0..159] of Byte;
    # Procedure DrawMenu;
    # var Left:Array[0..10,0..8] of Byte;Corner:Array[0..14,0..51] of Byte;
    #   Procedure TakeSprite;
    #   var H:Handle;i:Integer;Buf:Array[0..10228] of Byte;
    #   begin
    #     FOpen(H,'pong.spr');
    #     FRead(H,Buf[0],10229);
    #     FClose(H);
    #     Move(Buf[0],Left[0,0],99);
    #     Move(Buf[99],Corner[0,0],780);
    #     Move(Buf[879],Cursor[0,0],45);
    #     Move(Buf[924],Sprite[0,0],25);
    #     Move(Buf[949],Rectangle[0,0],9280);
    #   end;
    sprite_dimensions = (
        (9, 11),
        (52, 15),
        (5, 9),
        (5, 5),
        (160, 58),
    )

    xs = [ x for x, y in sprite_dimensions ]
    ys = [ y for x, y in sprite_dimensions ]
    x_img = max(xs)
    # Le prochain multiple de 4 supérieur à x_img.
    x_img += 4 - x_img % 4
    y_img = sum(ys) + 5 * (len(sprite_dimensions) - 1)

    bmp_img = Bitmap(x_img, y_img)
    y_cursor = 0
    col_index_cursor = 0

    for x_spr, y_spr in sprite_dimensions:

        for _ in range(y_spr):
            for x_cursor in range(x_spr):
                #rgb_value = [ (color_indexes[col_index_cursor] * 20) & 255 ] * 3
                rgb_value = palette[color_indexes[col_index_cursor]]
                bmp_img.set_pixel(x_cursor, y_cursor, rgb_value)
                col_index_cursor += 1
            y_cursor += 1

        y_cursor += 5

    bmp_img.write("pong_spr.bmp")

    pong_img_filepath
    color_indexes = open(pong_img_filepath, "rb").read()
    bmp_img = Bitmap(320, 200)
    col_index_cursor = 0

    for y in range(200):
        for x in range(320):
            rgb_value = palette[color_indexes[col_index_cursor]]
            bmp_img.set_pixel(x, y, rgb_value)
            col_index_cursor += 1

    bmp_img.write("pong_img.bmp")

    print("Fini.")


if __name__ == "__main__":
    main()
