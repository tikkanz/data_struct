NB. Package to interpret bytes as packed binary data

Note 'What is a Struct?'
A Struct Definition is a 2-item list of boxed:
    0 {:: format string describing the types and lengths of the fields it contains
    1 {:: list of boxed field names
The name of the noun is the name of the struct

In it's simplest form only the format string is required to read the struct. But to
do anything more complicated, for example read only some fields, then other info is
needed too. Potentially could represent different structs as classes, but for now will 
just use an optionally boxed structure to define one.
Inputs to verbs will need: 
   * Struct definition,
   * data (binary string or filename),
   * optional flags (change Endianness, subset of Fields to read, statement to 
filter records)
In addition a mapping of C types to J types is required.
)

cocurrent 'struct'
NB.===================
NB. util

NB.*eachunderv c Applies verb in gerund m to corresponding cell of y
NB. m is gerund, v is a verb.  [x] (k{u)`:6 &. v is applied to cell k of y
NB. NB. http://www.jsoftware.com/pipermail/programming/2009-August/015982.html
NB. Has spec equivalent to conjunction "respectively" in misc/miscutils/utils
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

NB.*getFields v Retrieve specified fields in x from table structure y
NB. y is: 2-item boxed list
NB.      0 { list of boxed field headers
NB.      1 { table of data (records by fields)
NB. x is: field header(s) to retrieve
NB. EG: 'Name' getFields Staff
NB. EG: ('Name';'Age') getFields Staff
getFields=: dyad define
  flds=. boxopen x
  'hdr dat'=. y
  dat {"1~ hdr (#@[ -.~ i.) flds
)
NB.===================
NB. typemap

NB. Table mapping C types to J types
NB. Adapted from: https://docs.python.org/3/library/struct.html

NB. 'Types_hdr Types_dat'=: split TAB&splitstring;._2 noun define
Types=: split cut;._2 noun define
Format C_Type             J_Type   Size Numeric
x      pad_byte           no_value  0    0
B      unsigned_char      integer 	1    1
c      char               literal   1    0
h      short              integer   2    1
H      unsigned_short     integer   2    1
i      int                integer   4    1
I      unsigned_int       integer   4    1
l      long               integer   4    1
L      unsigned_long      integer   4    1
q      long_long          integer   8    1
Q      unsigned_long_long integer   8    1
f      float              float     4    1
d      double             float     8    1
s      char[]             literal   1    0
)

Note 'Types not currently handled'
b	signed char	integer	1	1
?	_Bool	boolean	1	1
)

NB. Field_Decrypt_Verbs n Verbs for converting string representation of each C-type in same order as Field_Types
Field_Decrypt_Verbs=: ]`(a. i. ,)`]`(_1 ic ,)`(_1 ic ,)`(_2 ic ,)`(_2 ic ,)`(_2 ic ,)`(_2 ic ,)`(_3 ic ,)`(_3 ic ,)`(_1 fc ,)`(_2 fc ,)`]

NB. Field_Encrypt_Verbs n Verbs for converting string representation of each C-type in same order as Field_Types
Field_Encrypt_Verbs=: ]`({&a.)`]`(_2 ]\ 1 ic ])`(_2 ]\ 1 ic ])`(_4 ]\ 2 ic ])`(_4 ]\ 2 ic ])`(_4 ]\ 2 ic ])`(_4 ]\ 2 ic ])`(_8 ]\ 3 ic ])`(_8 ]\ 3 ic ])`(_4 ]\ 1 fc ])`(_8 ]\ 2 fc ])`]

NB.*Field_Types n List of single letter codes for each supported C-type
Field_Types=: ; 'Format' getFields Types
NB. Field_Sizes n List of field length in bytes for each C-type in Field_Types
Field_Sizes=: 0 ". > , 'Size' getFields Types
NB. Field_Types_Numeric n Boolean list of which supported C-types are numeric (not string/char)
Field_Types_Numeric=: Field_Types #~ 1 = 0 ". > , 'Numeric' getFields Types

NB. getTypes v Return list of field types for Struct format string
getTypes=: '0123456789' -.~ expandFmt
NB. getLen v Return vector of field lengths for Struct format string
getLen=: Field_Sizes {~ Field_Types i. ]

NB. expandFmt v Returns expanded struct format string given a struct format string
expandFmt=: verb define
  types=. (-.&'0123456789') y
  'Unhandled C-type in format string' assert types e. Field_Types
  nums=. }. 1 ". (,'9') , (e.&Field_Types -.&Field_Types;.2 ]) y
  typemsk=. nums +. ('s' = types)
  ; ":&.> (<"0 typemsk # types) ,.~ ('s' = typemsk # types) <@#"0 (typemsk # nums)
)

NB.*calcSize v Returns list of field lengths in bytes given a struct format string
NB. calcSize needs to handle '3s' as a 3-byte string, whereas '3c' or '3i' are 3 1-byte character fields or 3 4-byte integers
calcSize=: verb define
  fmtstr=. expandFmt y
  types=. (-.&'0123456789') fmtstr
  nums=. }. 1 ". (,'9') , (e.&Field_Types -.&Field_Types;.2 ]) fmtstr
  nums >. getLen types
)

NB. maskNumeric v Return mask of numeric fields of Struct format string
maskNumeric=: Field_Types_Numeric e.~ getTypes

NB.*reverseNumericFields v Reverse bytes of numeric fields (handle changes in Endianness)
NB. form: formatstr reverseNumericFields ParsedStruct
reverseNumericFields=: ([: (|."1)&.> maskNumeric@[ # ])`(maskNumeric@[ # i.@#@])`] }

NB. buildConversionGerund v Returns gerund of decryption/encryption verbs for Struct format string
NB. by default left arg is 0 (decryption), 1 is encryption
NB. buildConversionGerund=: Field_Decrypt_Verbs {~ Field_Types i. getTypes
buildConversionGerund=: (0&$:) : (((Field_Decrypt_Verbs;<Field_Encrypt_Verbs) {::~ ])@[ {~ (Field_Types i. getTypes)@])
NB.===================
NB. unpack

NB.*getStructRecs v Folds struct string into records of length specified by struct format string
getStructRecs=: -@(+/)@calcSize@[ ]\ ]

NB.*readStructRecs v Reads struct string from file and then getStructRecs
readStructRecs=: getStructRecs fread

NB. makeFrets v Determines frets (field boundaries) from a struct format string
makeFrets=: (i.@(+/) e. [: <: +/\)@calcSize

NB.*parseStructFields v Boxes the fields from a folded struct string
NB. y is: Folded Struct string (i.e. table of recs)
NB. x is: Format String describing the fields in the Struct
NB. eg: fmtstr parseStructFields my_folded_struct
parseStructFields=: ('' ; makeFrets)@[ <;.2 ]

NB.*readStructFields v Read and box each field of a C-type struct from a binary file
NB. y is: literal list of file name or 2-item list of boxed literal list and integer list
NB.    0 {:: Filename of binary Struct file
NB.    1 {:: optional 2-item list of integers (starting byte and number of bytes to read from file)
NB. x is: Format String describing the fields in the Struct
NB. eg: fmtstr readStructFields 'mystruct.bin'
NB. eg: fmtstr readStructFields 'mystruct.bin';10000 200
readStructFields=: [ parseStructFields readStructRecs

NB.*unpack v Unpack and convert the fields in a binary Struct string folded into a table of records
NB. y is: 2-item list of boxed strings
NB.    0 {:: Struct Definition
NB.    1 {:: Struct Data - Folded Struct string (i.e. table of recs)
NB. x is: optional flag to reverse bytes in numeric fields (to handle change in endianness). Default is 0.
NB. result: inverted table
NB. eg: unpack FormatString; folded_struct_string
NB. eg: 1 unpack FormatString; folded_struct_string
NB. eg: ,.&.> unpack FormatString; folded_struct_string   NB. better format for displaying struct in session
unpack=: verb define
  0 unpack y
:
  chgEndian=. x
  'st_def st_dat'=. y
  'st_fmt st_flds'=. st_def
  st_dat=. st_fmt parseStructFields st_dat
  if. chgEndian do.
    st_dat=. st_fmt reverseNumericFields st_dat
  end.
  Decrypt=. buildConversionGerund st_fmt
  Decrypt eachv st_dat
)

NB.*unpackFile v Unpack and convert the fields in a binary Struct file
NB. y is: 2 or 3-item list of boxed inputs
NB.    0 {:: Struct Definition
NB.    1 {:: Filename of binary Struct file
NB.    2 {:: optional 2-item list of integers (starting byte and number of bytes to read from file)
NB. x is: optional flag to reverse bytes in numeric fields (to handle change in endianness). Default is 0.
NB. result: inverted table
NB. eg: unpackFile Struct_Defn ; struct_filename
NB. eg: 1 unpackFile Struct_Defn ; struct_filename ; startbyte,bytelength
unpackFile=: verb define
  0 unpackFile y
:
  st_def=. 0 {:: y
  st_file=. }.y  NB. handle reading part of a file
  x unpack st_def ([ ; 0&{::@[ readStructRecs ,/@])  st_file
)

NB.*toDataframe a Converts inverted table to a J Dataframe
NB. y is: see unpack or unpackFile
NB. x is: see unpack or unpackFile
NB. u is: unpack or unpackFile
NB. result: J Dataframe
NB. eg: unpackFile toDataframe Struct_Defn ; struct_filename
toDataFrame=: {{ ((0;1)&{::@] ,: u) }}
NB.===================
NB. pack

NB.*unBox2StructRecs v Unboxes fields to a folded struct string with record length specified by struct format string
unBox2StructRecs=: [: ; ,.&.>/

NB.*pack v Pack and convert boxed fields to a binary Struct string folded into a table of records
NB. y is: 2-item list of boxed data
NB.    0 {:: Struct Definition
NB.    1 {:: Struct Data - List of boxed fields in J format
NB. x is: optional flag to reverse bytes in numeric fields (to handle change in endianness). Default is 0.
NB. eg: pack FormatString; boxed_fields
NB. eg: 1 pack FormatString; boxed_fields
pack=: verb define
  0 pack y
:
  chgEndian=. x
  'st_def st_dat'=. y
  'st_fmt st_flds'=. st_def
  Encrypt=. 1 buildConversionGerund st_fmt
  st_dat=. Encrypt eachv st_dat
  if. chgEndian do.
    st_dat=. st_fmt reverseNumericFields st_dat
  end.
  unBox2StructRecs st_dat
)

NB.*packFile v Pack and convert boxed list of fields to a binary Struct file
NB. y is: 2-item list of boxed inputs
NB.    0 {:: Struct Definition
NB.    1 {:: Struct Data - List of boxed fields in J format
NB. x is: 1- or 2-item list of boxed output parameters
NB.    0 {:: Name of binary Struct file to write
NB.    1 {:: optional flag to reverse bytes in numeric fields (to handle change in endianness). Default is 0.
NB. eg: struct_filename packFile Struct_Defn ;< Struct_data
NB. eg: (struct_filename ; 1) packFile Struct_Defn ;< Struct_data
packFile=: verb define
  0 packFile y
:
  st_def=. 0 {:: y
  st_dat=. 1 {:: y
  'st_file chgEndian'=. 2{. (boxopen x) , <0
  st_file fwrite~ , chgEndian pack st_def ;< st_dat
)
