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