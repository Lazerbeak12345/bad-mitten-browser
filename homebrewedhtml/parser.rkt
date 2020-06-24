#lang brag
html-document        : html-docstring? (html-comment | html-node)*
html-docstring       : "<!" ("document" | "DOCUMENT") " html>"
html-comment         : "<!--" ANY_CHAR* "-->"

html-node            : html-node-single
                     | html-node-open (html-comment | html-node)* html-node-close
                     | "<script" html-node-attrs ">" js-document "</script>"
                     | "<style" html-node-attrs ">" css-document "</style>"

html-node-single     : "<" HTML_NODE_NAME_SPECIAL_SINGLE html-node-attrs ">"
                     | "<" HTML_NODE_NAME html-node-attrs "/>"

html-node-open       : "<" HTML_NODE_NAME html-node-attrs ">"
html-node-close      : "</" HTML_NODE_NAME " "* ">"

html-node-attrs      : (" "* html-node-attr)*
html-node-attr       : " " HTML_NODE_ATTR_NAME html-node-attr-value?
html-node-attr-value : "=" HTML_NODE_ATTR_NAME
                     | '="' HTML_NODE_ATTR_CONTENT '"'
                     | "='" HTML_NODE_ATTR_CONTENT "'"

