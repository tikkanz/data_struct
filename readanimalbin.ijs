NB. reading ANIMAL struct e.g. pedigree.bin
require 'format/printf general/misc/validate'

cocurrent 'animstruct'
require 'data/struct'
coinsert 'struct'

DEFAULT_BINARYFILE=: 'testing/pedigree.bin'
Field_Names=: ;:'anml_key sire_anml_key dam_anml_key breed dvalue yob origin sirecode sex inbreed holstein prop_hf prop_jer prop_ayr prop_other'
ANIMAL_fmt=: '3i6H2h4f'   NB. 'iiiHHHHHHhhffff'
NB. ANIMAL_fldlens=: 4 4 4 2 2 2 2 2 2 2 2 4 4 4 4 NB. in bytes
NB. ANIMAL_fldtypes=: 'iiiHHHHHHhhffff'

readAnimStruct=: 0&$: : (unpackFile ANIMAL_fmt ; ])
getAnimStruct=: 0&$: : (unpack ANIMAL_fmt ; ])

getStructPed=: _2 (ic"1) 12&{."1
readStructPed=: ANIMAL_fmt getStructPed@readStructRecs ]   NB. read numeric id,sire,dam fields from ANIMAL struct.

NB.*readFromAnimStruct v Read processed records for animalids in filename y from ANIMAL struct in filename x
NB. y is: integer list of animalids to retrieve records from struct for.
NB. x is: filename for binary file containing structs.
NB. eg: readFromAnimStruct 26718718 20966331
NB. eg: '/myfolder/myanimstructfile.bin' readFromAnimStruct _99 ". ];._2 freads 'myanims.ids'
readFromAnimStruct=: 4 :0
  select. 3!:0 y 
  case. 2 do.  NB. y is a filename
    'ids input file not found' assert fexist y
    ids=. _99 ". ];._2 freads y                     NB. read required ids from LF-delimited file
  case. 4 do.  NB. y is integers
    ids=. y
  case. do.
    echo 'Unknown type for y argument.'
    i.0 0
    return.
  end.
  ped=. ANIMAL_fmt readStructRecs x           NB. read pedigree.bin as table (recs by fields)
  ped getFromAnimStruct ids
)

NB.*getFromAnimStruct v Get processed records for animalids in y from ANIMAL struct in x
getFromAnimStruct=: 4 :0
  ped=. x getRecsFromAnimStruct y
  res=. getAnimStruct ped
  res=. (1900&+&.> 5 { res) 5} res                  NB. add 1900 to birthyr
  res=. (%&10000&.> 9 10 { res) 9 10} res           NB. divide inbreed and hol by 10000
)

NB.*getRecsFromAnimStruct v Get records for animalids in y from ANIMAL struct in x
NB. If y is empty then returns all of struct in x
NB. eg: (ANIMAL_fmt readStructRecs DEFAULT_BINARYFILE) getRecsFromAnimStruct y
getRecsFromAnimStruct=: 4 :0
  ids=. y      NB. integer list of ids
  ped=. x    NB. records from pedigree.bin
  'Right arg not integer' assert isinteger ids
  'Left arg not table of bytes' assert 2 = (3!:0 , #@$)  ped
  ped_ids=. _2 ic , 4{."1 ped                   NB. read ids from pedigree.bin
  if. 0 < #ids do.
    ped=. ped #~ ped_ids e. ids               NB. msk of pedigree.bin ids in required ids
  else.
    ids=. ped_ids
  end.
  '%d of %d animal keys found.' printf (#ped);(#ids)
  ped
)

NB.*makeStructTable v Formats processed records as boxed table with header
NB.eg: makeStructTable readFromAnimStruct 36543491 25372877
makeStructTable=: Field_Names , afi

NB.*getPedFromAnimStruct v Get pedigree fields for animalids in y from ANIMAL struct in x
getPedFromAnimStruct=: 4 :0
  ped=. x getRecsFromAnimStruct y
  getStructPed ped
)

readFromAnimStruct_z_=: readFromAnimStruct_animstruct_

Note 'C struct for ANIMAL'                  
struct ANIMAL  {             bytes_to_read  J_conversion
    int animalkey;                 4 bytes  (_2&ic"1)
    int sirekey;                   4 bytes  (_2&ic"1)
    int damkey;                    4 bytes  (_2&ic"1)
    unsigned short breed;          2 bytes  (_1&ic"1)
    unsigned short dvalue;         2 bytes  (_1&ic"1)
    unsigned short birthyear;      2 bytes  (_1&ic"1)
    unsigned short origin;         2 bytes  (_1&ic"1)
    unsigned short sirecode;       2 bytes  (_1&ic"1)
    unsigned short type;           2 bytes  (_1&ic"1)
    short inbreed;                 2 bytes  (_1&ic"1)
    short hol;                     2 bytes  (_1&ic"1)
    float brd[4];              4 * 4 bytes  (_1&fc"1)
};                                44 bytes
)

Note 'Example usage'
ped=: (_44 ]\ ]) fread 'testing/pedigree.bin'
msk=: 0 0 0 1 0 0 0 1 0 0 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 0 0 1 0 0 0 1 0 0 0 1 0 0 0 1
pednums=: (([: (_2 ic ,)&.> 3&{.) ,([: (_1 ic ,)&.> 8 {. 3&}.),([: (_1 fc ,)&.> 4 {. 11&}.)) ('';msk) <;.2 ped

ped=: ANIMAL_fldlens_animstruct_ readStructRecs_animstruct_ 'testing/pedigree.bin'
testped=: (20000000 + i. 25){ped
msk=: makeFrets_animstruct_ ANIMAL_fldlens_animstruct_
pednums=: ANIMAL_fldlens_animstruct_ convertANIMAL2Num_animstruct_@parseFields_animstruct_ testped
pednums=: readAnimStruct_animstruct_ '/data/gs/tdm_data/pedigree/pedigree.bin'
(Field_Names_animstruct_)=:  readFromAnimStruct '/data/gs/rishe0/johnes/breedpred/test.ids'
pedtable=: makeStructTable 'mypedigree.bin' readFromAnimStruct 36543491 25372877 28889530
('myfile.tsv';TAB;'') makedsv~ pedtable
)
