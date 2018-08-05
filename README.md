# data_struct
Interprets bytes as packed binary data. 
This addon performs conversions between J values and C structs 
represented as bytes (J literals).

It uses Format Strings as compact descriptions of the layout of the C structs and the intended conversion to J values.

It borrows from the ideas used in the [Python Standard Library struct](https://docs.python.org/3/library/struct.html).

Currently the addon only reads data from structs. Structs are unpacked into an inverted table format.

Usage:
```j
ANIMAL_fmt=: '3i6H2h4f'
ANIMAL_flds=: ;:'anml_id sire_id dam_id breed dvalue yob origin sirecode sex inbreed hol prop_hf prop_jer prop_ayr prop_other'
ANIMAL=: ANIMAL_fmt; <ANIMAL_flds    NB. Struct definition

unpackfile ANIMAL;'path/myANIMALstruct.bin'
unpack ANIMAL; ANIMAL_fmt readStructRecs 'path/myANIMALstruct.bin'
```