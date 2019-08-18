"""
Quick'n Dirty coloration syntaxique en langage Pascal

Sources pour déterminer la manière dont la coloration est faite :
https://tohtml.com/pascal/ et des screenshots de l'IDE Pascal récupéré ici et là.

En plus de colorer-syntaxiquement, ça remplace également les caractères "<" et ">"
par leurs HTML entities équivalentes.

Certes, ça n'a rien à voir avec de la coloration syntaxique, mais j'ai besoin que
ça fasse ça.

TODO : Pour l'instant, ça ne gère pas les commentaires (à mettre en gris)
ni les parties de code en assembleur (à mettre en cyan clair).
"""

import re


FILEPATH_SOURCE_PASCAL = "../site_web/animation/plasma3.pas"
PASCAL_KEYWORDS = [
    "uses",
    "type",
    "Array",
    "Function",
    "Procedure",
    "Repeat",
    "Until",
    "and",
    "begin",
    "div",
    "do",
    "end",
    "for",
    "if",
    "of",
    "then",
    "to",
    "var",
]
SPAN_COLOR_WHITE = '<span class="code-keyword">'
SPAN_COLOR_WHITE_END = "</span>"


def main():

    pascal_keywords_lower = [keyword.lower() for keyword in PASCAL_KEYWORDS]

    # On lit tout le fichier d'un coup, parce qu'on est un gros bourrin,
    # et que de toutes façons, c'est jamais des gros fichiers.
    all_source = open(FILEPATH_SOURCE_PASCAL, "r", encoding="CP437").read()

    keywords_in_file = []

    all_source = all_source.replace("<", "&lt;")
    all_source = all_source.replace(">", "&gt;")

    source_result = ""

    source_splitted = re.split("([^a-zA-Z]*)", all_source)

    for token in source_splitted:

        if token.lower() in pascal_keywords_lower:
            source_result += SPAN_COLOR_WHITE + token + SPAN_COLOR_WHITE_END
        else:
            source_result += token

    print(source_result)


if __name__ == "__main__":
    main()
