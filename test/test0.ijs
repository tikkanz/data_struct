AddonPath=: fpath_j_^:2 loc ''

before_each=: 3 : 0
  load AddonPath,'/struct.ijs'
  coinsert 'struct'
  load AddonPath,'/test/test_structs.ijs'
  ANIMAL_fn=: AddonPath,'/',LitEND_fn
  PWSUMRY_fn=: AddonPath,'/',BigEND_fn
  SOUTRECD_fn=: AddonPath,'/',SOUTRECD_fn
)

test_fieldfmts=: 3 :0
  assert 'iiiHHHHHHhhffff' -: expandFmt '3i6H2h4f'
  assert 'iHHddddccc10s2s' -: expandFmt 'i2H4d3c10s2s'
  assert 'iiiiBBBBBBBBhhii' -: expandFmt '4i8B2h2i'
)

test_fieldsizes=: 3 :0
  assert 4 4 4 2 2 2 2 2 2 2 2 4 4 4 4 -: calcSize '3i6H2h4f'
  assert 4 4 4 2 2 2 2 2 2 2 2 4 4 4 4 -: calcSize 'iiiHHHHHHhhffff'
  assert 4 2 2 8 8 8 8 1 1 1 10 2 -: calcSize 'i2H4d3c10s2s'
  assert 4 2 2 8 8 8 8 1 1 1 10 2 -: calcSize 'iHHddddccc10s2s'
  assert 4 4 4 4 1 1 1 1 1 1 1 1 2 2 4 4 -: calcSize_struct_ '4i8B2h2i'
)

NB. test_fieldtypes=: 3 :0
NB. )

NB. length of record?

test_structpacking=: 3 :0
  AnimalData=: unpackFile ANIMAL;ANIMAL_fn
  assert ($@,.&> AnimalData) -: 10 ,. (1 >. calcSize * -.@maskNumeric) ANIMAL_fmt    NB. shape of unpacked result is correct
  assert (fread ANIMAL_fn) -: , pack ANIMAL;<AnimalData                              NB. re-packed result matches file

  PWSumryData=: 1 unpackFile PWSUMRY;PWSUMRY_fn
  assert ($@,.&> PWSumryData) -: 10 ,. (1 >. calcSize * -.@maskNumeric) PWSUMRY_fmt  NB. shape of unpacked result is correct
  assert (fread PWSUMRY_fn) -: , 1 pack PWSUMRY;<PWSumryData                         NB. re-packed result matches file

  SOutRecdData=: 0 unpackFile SOUTRECD;SOUTRECD_fn
  assert ($@,.&> SOutRecdData) -: 20 ,. (1 >. calcSize * -.@maskNumeric) SOUTRECD_fmt NB. shape of unpacked result is correct
  assert (fread SOUTRECD_fn) -: , 0 pack SOUTRECD;<SOutRecdData                       NB. re-packed result matches file
)

Note 'Testing'
,.&.> unpack ANIMAL ; ANIMAL_fmt getStructRecs ANIMAL_LEND_bin
,.&.> 1 unpack PWSUMRY ; PWSUMRY_fmt getStructRecs PWSUMRY_BEND_bin

unpackFile ANIMAL ; 'test/ANIMAL_lend_sample.bin'
1 unpackFile PWSUMRY ;'test/PWSUMRY_bend_sample.bin'
1 unpackFile PWSUMRY ;'test/PWSUMRY_bend_sample.bin'; 3 4 * 55
)

Note 'Format strings'

ANIMAL_fmtstr2=. 'iiiHHHHHHhhffff'
PWSUMRY_fmtstr2=. 'iHHddddccc10s2s'

ANIMAL_fldtypes=. 'iiiHHHHHHhhffff'
PWSUMRY_fldtypes=. 'iHHddddcccss'
)
