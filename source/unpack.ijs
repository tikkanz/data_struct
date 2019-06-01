NB. unpack

NB. Table mapping C types to J types
NB. Adapted from: https://docs.python.org/3/library/struct.html

NB. 'Types_hdr Types_dat'=: split TAB&splitstring;._2 noun define
Types=: split cut;._2 noun define
Format C_Type             J_Type   Size Numeric
x      pad_byte           no_value  0    0
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
B	unsigned char	integer	1	1
?	_Bool	boolean	1	1
)

NB. Field_Decrypt_Verbs n Verbs for converting string representation of each C-type in same order as Field_Types
Field_Decrypt_Verbs=: ]`]`(_1 ic ,)`(_1 ic ,)`(_2 ic ,)`(_2 ic ,)`(_2 ic ,)`(_2 ic ,)`(_3 ic ,)`(_3 ic ,)`(_1 fc ,)`(_2 fc ,)`]

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

NB. buildConversionGerund v Returns gerund of decryption verbs for Struct format string
buildConversionGerund=: Field_Decrypt_Verbs {~ Field_Types i. getTypes

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

NB.*reverseNumericFields v Reverse bytes of numeric fields (handle changes in Endianness)
NB. form: formatstr reverseNumericFields ParsedStruct
reverseNumericFields=: ([: (|."1)&.> maskNumeric@[ # ])`(maskNumeric@[ # i.@#@])`] }

NB.*unpack v Unpack and convert the fields in a binary Struct string folded into a table of records
NB. y is: 2-item list of boxed strings
NB.    0 {:: Struct Definition
NB.    1 {:: Struct Data - folded Struct string (i.e. table of recs)
NB. x is: optional flag to reverse bytes in numeric fields (to handle change in endianness). Default is 0.
NB. eg: unpack FormatString; folded struct string
NB. eg: 1 unpack FormatString; folded struct string
NB. eg: ,.&.> unpack FormatString; folded struct string   NB. better format for displaying struct in session
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
NB. eg: unpackFile Struct_Defn ; struct_filename
NB. eg: 1 unpackFile Struct_Defn ; struct_filename ; startbyte,bytelength
unpackFile=: verb define
  0 unpackFile y
:
  st_def=. 0 {:: y
  st_file=. }.y  NB. handle reading part of a file
  x unpack st_def ([ ; 0&{::@[ readStructRecs ,/@])  st_file
)
