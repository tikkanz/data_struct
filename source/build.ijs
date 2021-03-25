NB. build
require 'project'
loc_z_=: 3 : 'jpath > (4!:4 <''y'') { 4!:3 $0'  NB. pathname of script calling it
AddonPath=: fpath_j_^:2 loc ''

Proj_Src=: AddonPath,'/source'
Proj_Tgt=: AddonPath,'/struct.ijs'
writesource_jp_ Proj_Src;Proj_Tgt

echo 'Built file: ',Proj_Tgt
echo 'From: ',Proj_Src

NB. (jpath '~addons/data/struct/struct.ijs') (fcopynew ::0:) jpath '~Addons/data_struct/struct.ijs'

NB. f=. 3 : 0
NB. (jpath '~Addons/data_struct/',y) fcopynew jpath '~Addons/data/struct/source/',y
NB. (jpath '~addons/data/struct/',y) (fcopynew ::0:) jpath '~Addons/data_struct/',y
NB. )

NB. mkdir_j_ jpath '~addons/data/struct'
NB. mkdir_j_ jpath '~addons/data/struct/test'
NB. f 'struct.ijs'
NB. f 'manifest.ijs'
NB. f 'history.txt'
NB. f 'test/test0.ijs'
NB. f 'test/animalstruct.ijs'
NB. f 'test/ANIMAL_lend_sample.bin'
NB. f 'test/pwsumrystruct.ijs'
NB. f 'test/PWSUMRY_bend_sample.bin'
