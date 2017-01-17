from setuptools import setup, find_packages

setup (
    name='chatlexer',
    packages=find_packages(),
    entry_points =
    """
    [pygments.lexers]
    chatlexer = chatlexer.lexer:ChatLexer
    """,
)
