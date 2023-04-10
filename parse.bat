@echo off
haxe parse.hxml -D tile_parsing %* && cls && hl build/tileparser.hl