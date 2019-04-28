NB. util

NB.*eachunderv c Applies verb in gerund m to corresponding cell of y
NB. m is gerund, v is a verb.  [x] (k{u)`:6 &. v is applied to cell k of y
NB. NB. http://www.jsoftware.com/pipermail/programming/2009-August/015982.html
NB. Has spec equivalent to conjunction "respectively" in misc/miscutils
eachunderv=: conjunction define
   m v 1 :(':';'x `:6&.u y')"_1 y
:
   m v 1 :(':';'x `:6&.u&>/ y')"_1 x ,&<"_1 y
)

eachv=: eachunderv>

NB. see [JWiki Essay on Inverted Table](https://code.jsoftware.com/wiki/Essays/Inverted_Table) 
NB. for more info on working with inverted tables
ifa=: <@(>"1)@|:     NB. inverted table from atoms
afi=: |:@:(<"_1@>)    NB. atoms from inverted table
