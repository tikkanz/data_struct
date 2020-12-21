NB.========================================================================================
NB. Test data


ANIMAL_fmt=: '3i6H2h4f'
ANIMAL_flds=: ;:'anml_key sire_anml_key dam_anml_key breed dvalue yob origin sirecode sex inbreed holstein prop_hf prop_jer prop_ayr prop_other'
ANIMAL=: ANIMAL_fmt ;< ANIMAL_flds

PWSUMRY_fmt=: 'i2H4d3c10s2s'
PWSUMRY_flds=: ;:'anml_key breed ssn_of_brth b p ba pa r1 r2 r3 mapref herdnum'
PWSUMRY=: PWSUMRY_fmt ;< PWSUMRY_flds

LitEND_fn=: 'test/ANIMAL_lend_sample.bin'    NB. name of little-endian binary file name
BigEND_fn=: 'test/PWSUMRY_bend_sample.bin'   NB. name of big-endian binary file name
