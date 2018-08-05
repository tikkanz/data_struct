NB. unpack

NB. Table mapping C types to J types
NB. Adapted from: https://docs.python.org/3/library/struct.html

'Types_hdr Types_dat'=: split TAB&splitstring;._2 noun define
Format	C_Type	J_Type	Size	Numeric
x	pad byte	no value		0
c	char	literal	1	0
h	short	integer	2	1
H	unsigned short	integer	2	1
i	int	integer	4	1
I	unsigned int	integer	4	1
l	long	integer	4	1
L	unsigned long	integer	4	1
q	long long	integer	8	1
Q	unsigned long long	integer	8	1
f	float	float	4	1
d	double	float	8	1
s	char[]	literal		0
)

Note 'Types not currently handled'
b	signed char	integer	1	1
B	unsigned char	integer	1	1
?	_Bool	boolean	1	1
)

NB. Field_Decrypt_Verbs n Verbs for converting string representation of each C-type in same order as Field_Types
Field_Decrypt_Verbs=: ]`]`(_1 ic ,)`(_1 ic ,)`(_2 ic ,)`(_2 ic ,)`(_2 ic ,)`(_2 ic ,)`(_3 ic ,)`(_3 ic ,)`(_1 fc ,)`(_2 fc ,)`]

NB.*Field_Types n List of single letter codes for each supported C-type
Field_Types=: ; Types_dat {"1~ Types_hdr i. <'Format'
NB. Field_Sizes n List of field length in bytes for each C-type in Field_Types
Field_Sizes=: 0 ". > Types_dat {"1~ Types_hdr i. <'Size'
NB. Field_Types_Numeric n Boolean list of which supported C-types are numeric (not string/char)
Field_Types_Numeric=: Field_Types #~ 1 = 0 ". > Types_dat {"1~ Types_hdr i. <'Numeric'

NB. getTypes v Return list of field types for Struct format string
getTypes=: '0123456789' -.~ expandFmt
NB. getLen v Return vector of field lengths for Struct format string
getLen=: Field_Sizes {~ Field_Types i. ]

NB. expandFmt v Returns expanded struct format string given a struct format string
expandFmt=: 3 :0
  types=. (-.&'0123456789') y
  'Unhandled C-type in format string' assert types e. Field_Types
  nums=. }. 1 ". (,'9') , (e.&Field_Types -.&Field_Types;.2 ]) y
  typemsk=. nums +. ('s' = types)
  ; ":&.> (<"0 typemsk # types) ,.~ ('s' = typemsk # types) <@#"0 (typemsk # nums)
)

NB.*calcSize v Returns list of field lengths in bytes given a struct format string
NB. calcSize needs to handle '3s' as a 3-byte string, whereas '3c' or '3i' are 3 1-byte character fields or 3 4-byte integers
calcSize=: 3 :0
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
unpack=: 3 :0
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
unpackFile=: 3 :0
  0 unpackFile y
:
  st_def=. 0 {:: y
  st_file=. }.y  NB. handle reading part of a file
  x unpack st_def ([ ; 0&{::@[ readStructRecs ,/@])  st_file
)

NB.*eachunderv c Applies verb in gerund m to corresponding cell of y
NB. m is gerund, v is a verb.  [x] (k{u)`:6 &. v is applied to cell k of y
NB. NB. http://www.jsoftware.com/pipermail/programming/2009-August/015982.html
NB. Has spec equivalent to conjunction "respectively" in misc/miscutils
eachunderv=: 2 : 0
   m v 1 :(':';'x `:6&.u y')"_1 y
:
   m v 1 :(':';'x `:6&.u&>/ y')"_1 x ,&<"_1 y
)

eachv=: eachunderv>

Note 'Testing'

ANIMAL_fmt=: '3i6H2h4f'
ANIMAL_flds=: ;:'anml_key sire_anml_key dam_anml_key breed dvalue yob origin sirecode sex inbreed holstein prop_hf prop_jer prop_ayr prop_other'
PWSUMRY_fmt=: 'i2H4d3c10s2s' 
PWSUMRY_flds=: ;:'anml_key breed ssn_of_brth b p ba pa r1 r2 r3 mapref herdnum'

ANIMAL_LEND_bin=: fread 'test/ANIMAL_lend_sample.bin'
PWSUMRY_BEND_bin=: fread 'test/PWSUMRY_bend_sample.bin'

ANIMAL_strecs=: ANIMAL_fmt getStructRecs ANIMAL_LEND_bin
PWSUMRY_strecs=: PWSUMRY_fmt getStructRecs PWSUMRY_BEND_bin

,.&.> unpack (ANIMAL_fmt;<ANIMAL_flds); ANIMAL_strecs
,.&.> 1 unpack (PWSUMRY_fmt;<PWSUMRY_flds); PWSUMRY_strecs

unpackFile (ANIMAL_fmt;<ANIMAL_flds);'test/ANIMAL_lend_sample.bin'
1 unpackFile (PWSUMRY_fmt;<PWSUMRY_flds);'test/PWSUMRY_bend_sample.bin'
1 unpackFile (PWSUMRY_fmt;<PWSUMRY_flds);'test/PWSUMRY_bend_sample.bin'; 3 4 * 55
)

Note 'Format strings'

ANIMAL_fmtstr1=. '3i6H2h4f'
ANIMAL_fmtstr2=. 'iiiHHHHHHhhffff'
PWSUMRY_fmtstr1=. 'i2H4d3c10s2s'
PWSUMRY_fmtstr2=. 'iHHddddccc10s2s'

ANIMAL_fldlens=. 4 4 4 2 2 2 2 2 2 2 2 4 4 4 4 NB. in bytes
ANIMAL_fldtypes=. 'iiiHHHHHHhhffff'
PWSUMRY_fldlens=. 4 4 4 8 8 8 8 1 1 1 10 2
PWSUMRY_fldtypes=. 'iHHddddcccss'
)
