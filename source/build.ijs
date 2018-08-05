NB. build
require 'project'
writesource_jp_ '~Addons/data_struct/source';'~Addons/data_struct/struct.ijs'

NB. (jpath '~addons/data/struct/struct.ijs') (fcopynew ::0:) jpath '~Addons/data/struct/struct.ijs'

f=. 3 : 0
NB. (jpath '~Addons/data/struct/',y) fcopynew jpath '~Addons/data/struct/source/',y
(jpath '~addons/data/struct/',y) (fcopynew ::0:) jpath '~Addons/data/struct/source/',y
)

NB. mkdir_j_ jpath '~addons/data/struct'
NB. f 'manifest.ijs'
NB. f 'history.txt'
NB. f 'test/test0.ijs'
NB. f 'test/animalstruct.ijs'
NB. f 'test/ANIMAL_lend_sample.bin'
NB. f 'test/pwsumrystruct.ijs'
NB. f 'test/PWSUMRY_bend_sample.bin'
