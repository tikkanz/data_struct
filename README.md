# data_struct
Interprets bytes as packed binary data.
This addon performs conversions between J values and C structs represented as bytes (J literals).
Structs are unpacked into an inverted table format with the appropriate type conversion applied.

`data/struct` uses [Format Strings](https://docs.python.org/3/library/struct.html#format-characters) as compact descriptions of the layout of the C structs and the intended conversion to J values. The definition of these format strings and other ideas are borrowed from the Python Standard Library [struct](https://docs.python.org/3/library/struct.html).

Currently the addon only reads data from structs.

Example usage:
```j
   require 'struct.ijs'
   coinsert 'struct'

   ANIMAL_fmt=: '3i6H2h4f'
   ANIMAL_flds=: ;:'anml_id sire_id dam_id breed dvalue yob origin sirecode sex inbreed hol prop_hf prop_jer prop_ayr prop_other'
   ANIMAL=: ANIMAL_fmt; <ANIMAL_flds    NB. Struct definition

   ,.&.> unpackFile ANIMAL;'test/ANIMAL_lend_sample.bin'
+--------+--------+--------+-+-----+---+-+-+-+---+----+-------+-------+-+-+
|27894738|       0|25262378|1|13496|110|0|0|2|  0|3852|0.96875|0.03125|0|0|
|27894739|       0|25042174|1|13363|110|0|0|2|  0|2509|      1|      0|0|0|
|27894740|23951759|24752752|9|20340|110|0|0|2|108|3085| 0.6875| 0.3125|0|0|
|27894741|25330663|25169873|9|20557|110|0|0|2|  1|2753| 0.4375| 0.5625|0|0|
|27894742|24271748|25302049|9|20373|110|0|0|2| 34|2648|    0.5|    0.5|0|0|
|27894744|21081485|22629000|9|20200|110|0|0|2| 54|4492| 0.6875| 0.3125|0|0|
|27894746|21199238|18282448|1|20766|110|0|0|2|155|5781|      1|      0|0|0|
|27894747|24119815|25054316|9|20069|110|0|0|2|  0| 458| 0.4375| 0.5625|0|0|
|27894748|18392104|23470741|1|20134|110|0|0|2| 86|5742|  0.875|  0.125|0|0|
|27894749|20995004|25090535|9|20282|110|0|0|2|125|2207|  0.375|  0.625|0|0|
+--------+--------+--------+-+-----+---+-+-+-+---+----+-------+-------+-+-+
```