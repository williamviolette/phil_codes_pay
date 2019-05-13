function v1tatot=grid_int_v(v1t,nA,nB,int_size)

v1t_0 = v1t( 1:size(v1t,1)/2);
v1t_1 = v1t( (size(v1t,1)/2) +1:end);

v1ta_0 = reshape(v1t_0,nA,nB);
v1taA_0  = l_int(v1ta_0,int_size);
v1taB_0 = l_int(v1taA_0',int_size);
v1tatot_0 = reshape(v1taB_0',size(v1taB_0,1)*size(v1taB_0,2),1);
     
v1ta_1 = reshape(v1t_1,nA,nB);
v1taA_1  = l_int(v1ta_1,int_size);
v1taB_1 = l_int(v1taA_1',int_size);
v1tatot_1 = reshape(v1taB_1',size(v1taB_1,1)*size(v1taB_1,2),1);

v1tatot = [v1tatot_0;v1tatot_1] ; 