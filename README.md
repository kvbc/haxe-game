![](github/preview.gif)

TODO
- potentially split chunk saving into multiple files
- color split assets at compile time
- use hxbit as serializer

Defines
- release

HXMLs
- default.hxml - compiler arguments shared between multiple HXMls
- build.hxml - compile the game
- parse.hxml - compile the tile parser (TileParser/Main.hx)
- test.hxml - compile tests (Tests/Main.hx)

Scripts
- b       - Compile and run the game in debug mode
- br      - Compile and run the game in release mode
- parse   - Compile and run the tile parser
- test    - Compile and run the tests
- profile - Compile and run the game in release mode, with a profiler attached. Opens chrome devtools.
