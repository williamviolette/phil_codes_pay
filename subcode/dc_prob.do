


cap drop dcg

g dcg = l6==1 & pcd==1

egen md = mean(dcg), by(date_c)

bys date_c: g dn=_n

scatter md date_c if dn==1 & md<.002 & date_c>541