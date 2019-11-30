"""
Quick'n Dirty coloration syntaxique en langage Pascal

Sources pour déterminer la manière dont la coloration est faite :
https://tohtml.com/pascal/ et des screenshots de l'IDE Pascal récupéré ici et là.

En plus de colorer-syntaxiquement, ça remplace également les caractères "<" et ">"
par leurs HTML entities équivalentes.

Certes, ça n'a rien à voir avec de la coloration syntaxique, mais j'ai besoin que
ça fasse ça.

TODO : Pour l'instant, ça ne gère pas les parties de code en assembleur (à mettre en cyan clair).
"""

import re
import sys


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
    "While",
    "else",
    "With",
    "mod",
    "case",
    "not",
    "shr",
    "shl",
    "Asm",
]
SPAN_COLOR_WHITE = '<span class="code-keyword">'
SPAN_COLOR_WHITE_END = "</span>"

SPAN_COMMENT = '<span class="code-comment">'
SPAN_COMMENT_END = "</span>"


def main():

    if len(sys.argv) < 2:
        raise Exception("Il faut indiquer le nom de fichier en paramètre.")
    filepath_source_pascal = sys.argv[1]

    pascal_keywords_lower = [keyword.lower() for keyword in PASCAL_KEYWORDS]

    # On lit tout le fichier d'un coup, parce qu'on est un gros bourrin,
    # et que de toutes façons, c'est jamais des gros fichiers.
    all_source = open(filepath_source_pascal, "r", encoding="CP437").read()

    keywords_in_file = []

    all_source = all_source.replace("<", "&lt;")
    all_source = all_source.replace(">", "&gt;")

    source_result = ""

    split_by_comments = re.split("([{}])", all_source)
    inside_code = True

    for token_comment in split_by_comments:

        if inside_code and token_comment == "{":
            inside_code = False
            source_result += SPAN_COMMENT + token_comment

        elif not inside_code and token_comment == "}":
            inside_code = True
            source_result += token_comment + SPAN_COMMENT_END

        elif not inside_code:
            source_result += token_comment

        else:
            source_splitted = re.split("([^a-zA-Z]*)", token_comment)
            for token in source_splitted:
                if token.lower() in pascal_keywords_lower:
                    source_result += SPAN_COLOR_WHITE + token + SPAN_COLOR_WHITE_END
                else:
                    source_result += token

    print(source_result)


if __name__ == "__main__":
    main()
