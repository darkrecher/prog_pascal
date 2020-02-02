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

    #lbm_chunk_pal = open(pong_pal_filepath, "rb").read()
    #palette = palette_from_lbm_data(lbm_chunk_pal)

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

    x_spr, y_spr = (80, 10)


    bmp_img = Bitmap(x_spr, y_spr)
    y_cursor = 0
    col_index_cursor = 0

    for _ in range(y_spr):
        for x_cursor in range(x_spr):
            rgb_value = [ (color_indexes[col_index_cursor] * 20) & 255 ] * 3
            #rgb_value = palette[color_indexes[col_index_cursor]]
            bmp_img.set_pixel(x_cursor, y_cursor, rgb_value)
            col_index_cursor += 1
        y_cursor += 1

    bmp_img.write("turn_spr.bmp")

    print("Fini.")


if __name__ == "__main__":
    main()
