dbr 1
NB. load '~Addons/data_struct/test/test1.ijs'
loc_z_=: 3 : 'jpath > (4!:4 <''y'') { 4!:3 $0'  NB. pathname of script calling it

AddonPath=. fpath_j_^:2 loc ''

NB. load AddonPath,'/test/test.ijs'
load AddonPath,'/test/test0.ijs'
