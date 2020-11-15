load '~addons/data/struct/struct.ijs'
coinsert 'struct'

ANIMAL_fmt=: '3i6H2h4f'
ANIMAL_flds=: ;:'anml_key sire_anml_key dam_anml_key breed dvalue yob origin sirecode sex inbreed holstein prop_hf prop_jer prop_ayr prop_other'
ANIMAL=: ANIMAL_fmt ;< ANIMAL_flds
PWSUMRY_fmt=: 'i2H4d3c10s2s' 
PWSUMRY_flds=: ;:'anml_key breed ssn_of_brth b p ba pa r1 r2 r3 mapref herdnum'
PWSUMRY=: PWSUMRY_fmt ;< PWSUMRY_flds

ANIMAL_LEND_bin=: fread 'test/ANIMAL_lend_sample.bin'    NB. example little endian binary
PWSUMRY_BEND_bin=: fread 'test/PWSUMRY_bend_sample.bin'  NB. example big endian binary

BoxedFields=: unpackFile ANIMAL;'test/ANIMAL_lend_sample.bin'
(fread 'test/ANIMAL_lend_sample.bin') -: , pack ANIMAL;<BoxedFields
BoxedFields=: 1 unpackFile PWSUMRY;'test/PWSUMRY_bend_sample.bin'
(fread 'test/PWSUMRY_bend_sample.bin') -: , 1 pack PWSUMRY;<BoxedFields

echo 'Passed data_struct tests'

Note 'Testing'
ANIMAL_strecs=: ANIMAL_fmt getStructRecs ANIMAL_LEND_bin
PWSUMRY_strecs=: PWSUMRY_fmt getStructRecs PWSUMRY_BEND_bin

,.&.> unpack ANIMAL ; ANIMAL_strecs
,.&.> 1 unpack PWSUMRY ; PWSUMRY_strecs

unpackFile ANIMAL ; 'test/ANIMAL_lend_sample.bin'
1 unpackFile PWSUMRY ;'test/PWSUMRY_bend_sample.bin'
1 unpackFile PWSUMRY ;'test/PWSUMRY_bend_sample.bin'; 3 4 * 55
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
