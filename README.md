# Tokenizer

A simple library for building a tokenizer object, suitable for many compiler construction tasks.

Rather than taking the 'code generation' approach, as in ANTLR or lex, Tokenizer treats the class
initializer as a simple domain specific language. You can look at the units tests in 
TokenizerTests.swift for some examples, but the gist of this is that you create an instance
of Tokenizer with an array of (regex, action) pairs and an input stream (literally an instance of
some class that derives from NSInputStream, or an instance of NSInputStream itself).

Tokenizing the input stream is a matter of repeatedly finding the regex that consumes the most of
the input stream from the current offset, and using the paired action procedure to generate from
the matched text the next token, optionally associating with that token the appropriate 'value', 
such as the integer 42 when the current token is the string '42'.

One feature among many that this class is missing, compared to lex (or flex) that you might expect to find
is the ability to switch to a different inputStream in mid-parse. This sort of thing is
nice if you're building something like the C preprocessor, but I found I liked its simplicity when
that feature was refactored out, and I don't currently have a use case similar to the C
preprocess, and I rather hope I never will.
