luapdasim
=========

lua pushdown automaton simulator

I made this on a whim one afternoon. No guarantee of it working correctly and no liability of the author in that regard.

Sample session:

```
$ lua pdatest.lua 
"" was accepted
"00" was accepted
"11" was accepted
"01" was not accepted
"010" was not accepted
"0110" was accepted
Now type in some of your own tests...

"" was accepted
10
"10" was not accepted
01
"01" was not accepted
000111
"000111" was not accepted
1001001
"1001001" was not accepted
01101001
"01101001" was accepted
```
