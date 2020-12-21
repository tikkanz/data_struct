require 'general/unittest'

loc_z_=: 3 : 'jpath > (4!:4 <''y'') { 4!:3 $0'  NB. pathname of script calling it
AddonPath=. fpath_j_^:2 loc ''

echo AddonPath,'/test/test_0.ijs'
NB. unittest jpath '~Addons/bio_pedigree/test/test_0.ijs'
echo unittest jpath AddonPath,'/test/test_0.ijs'
NB. load AddonPath,'/test/test0.ijs'
