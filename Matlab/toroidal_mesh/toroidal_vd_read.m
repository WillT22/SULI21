fileID = fopen('../../p/stellopt/ANALYSIS/wteague/flux_surface/tv_test05n.dat');
toroidal_cell = textscan(fileID, '%f%f%f%f%f%f', 'Headerlines', 3, 'CollectOutput', true);
fclose(fileID);
toroidal_vd.x = toroidal_cell{1}(1:25,1);
toroidal_vd.y = toroidal_cell{1}(1:25,2);
toroidal_vd.z = toroidal_cell{1}(1:25,3);
toroidal_vd.vertices(:,1) = toroidal_vd.x;
toroidal_vd.vertices(:,2) = toroidal_vd.y;
toroidal_vd.vertices(:,3) = toroidal_vd.z;
toroidal_vd.faces(:,1) = toroidal_cell{1}(26:end,1);
toroidal_vd.faces(:,2) = toroidal_cell{1}(26:end,2);
toroidal_vd.faces(:,3) = toroidal_cell{1}(26:end,3);
clear toroidal_cell;