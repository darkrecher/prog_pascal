"""
Origine :
https://stackoverflow.com/questions/8729459/how-do-i-create-a-bmp-file-with-pure-python
"""

from struct import pack


class Bitmap:
    def __init__(self, width, height):
        # Réchèr : ajout du check, car les tests ont montré
        # que des largeurs non multiples de 4 avaient pour résultat des fichiers bmp
        # illisibles par la plupart des viewer d'imageself.
        if width % 4:
            raise Exception(
                "La création de bitmap ne marche qu'avec des width multiples de 4. "
                "Désolé pour ce code récupéré à l'arrache de stack-overflow."
            )
        self._bfType = 19778  # Bitmap signature
        self._bfReserved1 = 0
        self._bfReserved2 = 0
        self._bcPlanes = 1
        self._bcSize = 12
        self._bcBitCount = 24
        self._bfOffBits = 26
        self._bcWidth = width
        self._bcHeight = height
        self._bfSize = 26 + self._bcWidth * 3 * self._bcHeight
        self.clear()

    def clear(self):
        self._graphics = [(0, 0, 0)] * self._bcWidth * self._bcHeight

    def set_pixel(self, x, y, color):
        if x < 0 or y < 0 or x > self._bcWidth - 1 or y > self._bcHeight - 1:
            raise ValueError("Coords out of range")
        if len(color) != 3:
            raise ValueError("Color must have 3 elems")

        # Modif Réchèr : le y est compté à partir du coin supérieur gauche.
        # Sinon c'est casse-burette.
        y = self._bcHeight - 1 - y
        self._graphics[y * self._bcWidth + x] = (color[2], color[1], color[0])

    def write(self, file):
        with open(file, "wb") as f:
            # Writing BITMAPFILEHEADER
            f.write(
                pack(
                    "<HLHHL",
                    self._bfType,
                    self._bfSize,
                    self._bfReserved1,
                    self._bfReserved2,
                    self._bfOffBits,
                )
            )
            # Writing BITMAPINFO
            f.write(
                pack(
                    "<LHHHH",
                    self._bcSize,
                    self._bcWidth,
                    self._bcHeight,
                    self._bcPlanes,
                    self._bcBitCount,
                )
            )
            for px in self._graphics:
                f.write(pack("<BBB", *px))
            for i in range(0, (self._bcWidth * 3) % 4):
                f.write(pack("B", 0))


def main():

    side = 520
    b = Bitmap(side, side)

    for j in range(0, side):
        b.set_pixel(j, j, (255, 0, 0))
        b.set_pixel(j, side - j - 1, (255, 0, 0))
        b.set_pixel(j, 0, (255, 0, 0))
        b.set_pixel(j, side - 1, (255, 0, 0))
        b.set_pixel(0, j, (255, 0, 0))
        b.set_pixel(side - 1, j, (255, 0, 0))

    b.write("file.bmp")


if __name__ == "__main__":
    main()
