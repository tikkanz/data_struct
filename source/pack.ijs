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
