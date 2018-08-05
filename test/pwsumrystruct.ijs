NB. reading pwsumry.bin
require 'format/printf general/misc/validate'
coinsert 'pwsumrystruct'
cocurrent 'pwsumrystruct'
NB. require 'data/struct'
require jpath '~Addons/data_struct/struct.ijs'
coinsert 'struct'

DEFAULT_PWSUMRYBIN=: 'test/PWSUMRY_bend_sample.bin'
PWSUMRY_flds=: ;:'anml_key breed ssn_of_brth b p ba pa r1 r2 r3 mapref herdnum'
PWSUMRY_fmt=: 'i2H4d3c10s2s'  NB. 'iHHddddccc10s2s'
NB. PWSUMRY_fldlens=: 4 2 2 8 8 8 8 1 1 1 10 2 NB. in bytes
NB. PWSUMRY_fldtypes=: 'iHHddddcccss'
PWSUMRY=: PWSUMRY_fmt;<PWSUMRY_flds

readPWSumryStruct=: 0&$: : (unpackFile PWSUMRY ; ])
getPWSumryStruct=: 0&$: : (unpack PWSUMRY ; ])

Note 'Format for PWSUMRY'
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

Note 'Testing'
,.&.> 1 readPWSumryStruct DEFAULT_PWSUMRYBIN
,.&.> 1 getPWSumryStruct PWSUMRY_fmt readStructRecs DEFAULT_PWSUMRYBIN
)