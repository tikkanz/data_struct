NB. build
require 'project'
writesource_jp_ '~Addons/data_struct/source';'~Addons/data_struct/struct.ijs'

NB. (jpath '~addons/data/struct/struct.ijs') (fcopynew ::0:) jpath '~Addons/data_struct/struct.ijs'

f=. 3 : 0
(jpath '~Addons/data_struct/',y) fcopynew jpath '~Addons/data/struct/source/',y
(jpath '~addons/data/struct/',y) (fcopynew ::0:) jpath '~Addons/data_struct/',y
)

NB. mkdir_j_ jpath '~addons/data/struct'
mkdir_j_ jpath '~addons/data/struct/test'
f 'struct.ijs'
f 'manifest.ijs'
f 'history.txt'
f 'test/test0.ijs'
f 'test/animalstruct.ijs'
f 'test/ANIMAL_lend_sample.bin'
f 'test/pwsumrystruct.ijs'
f 'test/PWSUMRY_bend_sample.bin'
