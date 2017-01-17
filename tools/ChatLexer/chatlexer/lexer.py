from pygments.lexer import RegexLexer
from pygments.token import *

class ChatLexer(RegexLexer):
    name = 'Chat'
    aliases = ['chat']
    filenames = ['*.chat', '*.chat_log']

    tokens = {
        'root': [
            (r'^[a-zA-Z0-9_-]+', Name.Entity),
            (r'([0-9])?[0-9]:[0-9][0-9]( )?(AM|am|PM|pm)', Literal.Date),
            (r'@[a-zA-Z0-9]+', Keyword.Declaration),
            (r'.(?!(@[a-zA-Z0-9]+))', Text),
        ]
    }
