NB. reading pwsumry.bin
require 'format/printf general/misc/validate'

cocurrent 'pwsumrystruct'
require 'data/struct'
coinsert 'struct'

DEFAULT_BINARYFILE=: 'testing/pwsumry_bend.bin'
Field_Names=: ;:'anml_key breed ssn_of_brth b p ba pa r1 r2 r3 mapref herdnum'
PWSUMRY_fmt=: 'i2H4d3c10s2s'  NB. 'iHHddddccc10s2s'
NB. PWSUMRY_fldlens=: 4 2 2 8 8 8 8 1 1 1 10 2 NB. in bytes
NB. PWSUMRY_fldtypes=: 'iHHFFFFccccc'

NB. convertPWSUMRY2Num=: [: ,.&.> ([: (_2 ic ,)@:(|."1)&.> 1&{.) , ([: (_1 ic ,)@:(|."1)&.> 2 {. 1&}.) , ([: (_2 fc ,)@:(|."1)&.> 4 {. 3&}.) , ([: ]&.> 3 {. 7&}.) , ([: ]&.> 1 {. 10&}.) , ([: ]&.> 1 {. 11&}.)
NB. readPWSumryStruct=: PWSUMRY_fldlens&([ convertPWSUMRY2Num@parseFields readStructRecs)
NB. getPWSumryStruct=: PWSUMRY_fldlens convertPWSUMRY2Num@parseFields ]

getPWSumryStruct=: 1&$: : (unpack PWSUMRY_fmt ; ])
readPWSumryStruct=: 1&$: : (unpackFile PWSUMRY_fmt ; ])

Note 'format of binary file'
Saved Big Endian (When reading on Intel, need to reverse bytes in numeric fields prior to type conversion)
    01  dbll-recd.
        03  dbll-anml-key           pic s9(09) comp.  4 byte integer
        03  dbll-ae-brd             pic s9(04) comp.  2 byte integer
        03  dbll-ssn-of-brth        pic s9(04) comp.  2 byte integer
        03  dbll-b                  comp-2.  8        8 byte float
        03  dbll-p                  comp-2. 8         8 byte float
        03  dbll-ba                 comp-2. 8         8 byte float
        03  dbll-pa                 comp-2.  8        8 byte float
        03  dbbl-r1-ok              pic x(01).         1 byte char
        03  dbbl-r2-ok              pic x(01).         1 byte char
        03  dbbl-r3-ok              pic x(01).         1 byte char
        03  dbll-loch.
            05  dbll-map-ref        pic x(10).  10    10 byte char
            05  dbll-herd-num       pic 9(02).  2      2 byte char
)

Note 'read the anml_key, rules1-3, map-ref, herd-num from file'
'~temp/pwsumry_test.txt' fwrites~ }:"1 ;,.&.>/ ({.~ 0 1 + $)@":&.>  0 7 8 9 10 11 { readPWSumryStruct 'testing/pwsumry_bend.bin';(3*55) , 4 *55
'~temp/pwsumry_info.txt' fwrites~ }:"1 ;,.&.>/ ({.~ 0 1 + $)@":&.>  0 7 8 9 10 11 { readPWSumryStruct 'testing/pwsumry_bend.bin'
)
