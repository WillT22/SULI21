%% Importing hitpoint data from fieldlines %%
fldlns_Cbar1_f_10 = read_fieldlines('../../p/stellopt/ANALYSIS/wteague/flux_surface/simulations/fieldlines/Cbar/fieldlines_Cbar1_f_10.h5');
fldlns_Cbar2_f_10 = read_fieldlines('../../p/stellopt/ANALYSIS/wteague/flux_surface/simulations/fieldlines/Cbar/fieldlines_Cbar2_f_10.h5');
fldlns_Cbar3_f_10 = read_fieldlines('../../p/stellopt/ANALYSIS/wteague/flux_surface/simulations/fieldlines/Cbar/fieldlines_Cbar3_f_10.h5');
fldlns_Cbar4_f_10 = read_fieldlines('../../p/stellopt/ANALYSIS/wteague/flux_surface/simulations/fieldlines/Cbar/fieldlines_Cbar4_f_10.h5');
fldlns_Cbar5_f_10 = read_fieldlines('../../p/stellopt/ANALYSIS/wteague/flux_surface/simulations/fieldlines/Cbar/fieldlines_Cbar5_f_10.h5');

fldlns_Cbar1_r_10 = read_fieldlines('../../p/stellopt/ANALYSIS/wteague/flux_surface/simulations/fieldlines/Cbar/fieldlines_Cbar1_r_10.h5');
fldlns_Cbar2_r_10 = read_fieldlines('../../p/stellopt/ANALYSIS/wteague/flux_surface/simulations/fieldlines/Cbar/fieldlines_Cbar2_r_10.h5');
fldlns_Cbar3_r_10 = read_fieldlines('../../p/stellopt/ANALYSIS/wteague/flux_surface/simulations/fieldlines/Cbar/fieldlines_Cbar3_r_10.h5');
fldlns_Cbar4_r_10 = read_fieldlines('../../p/stellopt/ANALYSIS/wteague/flux_surface/simulations/fieldlines/Cbar/fieldlines_Cbar4_r_10.h5');
fldlns_Cbar5_r_10 = read_fieldlines('../../p/stellopt/ANALYSIS/wteague/flux_surface/simulations/fieldlines/Cbar/fieldlines_Cbar5_r_10.h5');

fieldline_file = [fldlns_Cbar1_f_10, fldlns_Cbar1_r_10, fldlns_Cbar2_f_10,...
    fldlns_Cbar2_r_10, fldlns_Cbar3_f_10, fldlns_Cbar3_r_10,...
    fldlns_Cbar4_f_10, fldlns_Cbar4_r_10, fldlns_Cbar5_f_10,...
    fldlns_Cbar5_r_10];

% R_lines
R_lines_10 = [];
for i = 1:length(fieldline_file)
    R_lines_10 = [R_lines_10, fieldline_file(i).R_lines(:,2)];
end
R_lines_10 = reshape(R_lines_10, 40000,5);
% PHI_lines
PHI_lines_10 = [];
for i = 1:length(fieldline_file)
    PHI_lines_10 = [PHI_lines_10, fieldline_file(i).PHI_lines(:,2)];
end
PHI_lines_10 = reshape(PHI_lines_10, 40000,5);
% verifying all Phi data is in the bounds [0,2pi]
for f = 1:size(PHI_lines_10,2)
    for i = 1:size(PHI_lines_10,1)
        if PHI_lines_10(i,f) < 0
			PHI_lines_10(i,f) = PHI_lines_10(i,f) + 2*pi;
        end
    end
end
% Z_lines
Z_lines_10 = [];
for i = 1:length(fieldline_file)
    Z_lines_10 = [Z_lines_10, fieldline_file(i).Z_lines(:,2)];
end
Z_lines_10 = reshape(Z_lines_10, 40000,5);

%% Importing Approximate Theta from least_squares function %%
THETA_lines_10 = importdata('./EOSDD/Python/Theta_Cbar_10.dat');

%% Calculating R and Z based on fourier coeffecients and PHI and THETA %%
fileID = fopen('../../p/stellopt/ANALYSIS/wteague/flux_surface/nvac_fldlns/fb_bnorm/nescin.fb_10');
fourier_cell = textscan(fileID, '%f%f%f%f%f%f', 'Headerlines', 172, 'CollectOutput', true);
fclose(fileID);
fourier_coeff.m = fourier_cell{1}(:,1);
fourier_coeff.n = fourier_cell{1}(:,2);
fourier_coeff.crc2 = fourier_cell{1}(:,3);
fourier_coeff.czs2 = fourier_cell{1}(:,4);
fourier_coeff.crs2 = fourier_cell{1}(:,5);
fourier_coeff.czc2 = fourier_cell{1}(:,6);
clear fourier_cell;

for i = 1:size(PHI_lines_10,2)
    [M, Theta] = meshgrid(fourier_coeff.m, THETA_lines_10(:,i));
    [N, Phi] = meshgrid(fourier_coeff.n, PHI_lines_10(:,i));

    % radial component
    r_mnc = repmat(fourier_coeff.crc2',size(Phi,1),1);
    r_elementarr = r_mnc .* cos(M .* Theta + 3 * N .* Phi);
    calculated_coordinates.R(:,i) = sum(r_elementarr,2);

    % z component
    z_mns = repmat(fourier_coeff.czs2',size(Phi,1),1);
    z_elementarr = z_mns .* sin(M .* Theta + 3 * N .* Phi);
    calculated_coordinates.Z(:,i) = sum(z_elementarr,2);
end

%% Error Analysis %%
% Error for R
error_R.total = R_lines_10 - calculated_coordinates.R;
absolute_error_R = abs(error_R.total);
max_error_R.true = max(max(error_R.total));
min_error_R.true = min(min(error_R.total));
[max_error_R.absolute_indicies(1), max_error_R.absolute_indicies(2)] = ...
    find(error_R.total == max_error_R.true);
R_true_error.mean_error = sum(error_R.total,'all')/numel(error_R.total);
R_true_error.std_dev = sqrt(sum((error_R.total-R_true_error.mean_error).^2,'all')/numel(error_R.total));

%{
% separating theta into upper and lower sections
R_lines_10_upper = [];
PHI_lines_10_upper = [];
calculated_coordinates.R_upper = [];
R_lines_10_lower = [];
calculated_coordinates.R_lower = [];
PHI_lines_10_lower = [];
for j = 1:size(THETA_lines_10,2)
    for i = 1:size(THETA_lines_10,1)
        if THETA_lines_10(i,j) <= pi    % points on the upper portion
            R_lines_10_upper = [R_lines_10_upper, R_lines_10(i,j)];
            calculated_coordinates.R_upper = [calculated_coordinates.R_upper, calculated_coordinates.R(i,j)];
            PHI_lines_10_upper = [PHI_lines_10_upper, PHI_lines_10(i,j)];
        elseif THETA_lines_10(i,j) > pi % points on the lower portion
            R_lines_10_lower = [R_lines_10_lower, R_lines_10(i,j)];
            calculated_coordinates.R_lower = [calculated_coordinates.R_lower, calculated_coordinates.R(i,j)];
            PHI_lines_10_lower = [PHI_lines_10_lower, PHI_lines_10(i,j)];
        end
    end
end
error_R.upper = (R_lines_10_upper - calculated_coordinates.R_upper);
error_R.lower = (R_lines_10_lower - calculated_coordinates.R_lower);


% separating vessel into three symmetric parts
angle_a = 3*pi/12;
angle_b = 5*pi/12;
angle_c = 2*pi;
error_R.a = [];
error_R.b = [];
error_R.c = [];
PHI_data = PHI_lines_10;
error_R_data = error_R.total;
for j = 1:size(PHI_data,2)
    for i = 1:size(PHI_data,1)
        if PHI_data(i,j) <= angle_a
            error_R.a = [error_R.a, error_R_data(i,j)];
        elseif PHI_data(i,j) > angle_a && PHI_data(i,j) <= angle_b
            error_R.b = [error_R.b, error_R_data(i,j)];
        elseif PHI_data(i,j) > angle_b && PHI_data(i,j) <= angle_c
            error_R.c = [error_R.c, error_R_data(i,j)];
        end
    end
end
%}
%{
figure
histogram(error_R.b,10000,'Normalization','probability')
hold on
xline(R_true_error.mean_error, '--', 'Mean','Color','r')
xline(R_true_error.mean_error + R_true_error.std_dev, '-', '+1 Standard Deviation','Color','b')
xline(R_true_error.mean_error - R_true_error.std_dev, '-', '-1 Standard Deviation','Color','b')
xline(R_true_error.mean_error + 2*R_true_error.std_dev, '--', '+2 Standard Deviation','Color','b')
xline(R_true_error.mean_error - 2*R_true_error.std_dev, '--', '-2 Standard Deviation','Color','b')
xline(R_true_error.mean_error + 3*R_true_error.std_dev, '-.', '+3 Standard Deviation','Color','b')
xline(R_true_error.mean_error - 3*R_true_error.std_dev, '-.', '-3 Standard Deviation','Color','b')
xlim([min_error_R.true,max_error_R.true])
xlabel('Error for R')
ylim([0,7*10^-3])
%}

%{
% plotting absolute error of R
figure
hold on
plot(THETA_lines_10,absolute_error_R,'.','Color','red')
xlabel('Theta');
ylabel('Absolute Error');
title('Absolute Error for R v Theta')
xlim([0,2*pi]);
%}
figure
hold on
plot(PHI_lines_10,error_R.total,'.','Color','red')
xlabel('Phi');
ylabel('Error');
title('Error for R v Phi')
xlim([0,2*pi]);
xticks([0 pi/4 pi/2 3*pi/4 pi 5*pi/4 3*pi/2 7*pi/4 2*pi])
xticklabels({'0', '\pi/4', '\pi/2', '3\pi/4', '\pi', '5\pi/4', '3\pi/2', '7\pi/4', '2\pi'})
xline(11*pi/24);
xline(21*pi/24);

% relative error for R
%{
relative_error_R = abs((R_lines_10 - calculated_coordinates.R)./R_lines_10);
max_error_R.relative = max(max(relative_error_R));
[max_error_R.relative_indicies(1), max_error_R.relative_indicies(2)] = ...
    find(relative_error_R == max_error_R.relative);
rel_error_arr_R = [linspace(0,2*pi,size(R_lines_10,1))', relative_error_R];
rel_error_arr_R = sortrows(rel_error_arr_R,1);

figure
hold on
plot(THETA_lines_10,relative_error_R,'.','Color','red')
xlabel('Theta');
ylabel('Relative Error');
title('Relative Error for R v Theta')
xlim([0,2*pi]);
%}

% Error for Z
error_Z.total = Z_lines_10 - calculated_coordinates.Z;
absolute_error_Z = abs(error_Z.total);
max_error_Z.true = max(max(error_Z.total));
min_error_Z.true = min(min(error_Z.total));
[max_error_Z.absolute_indicies(1), max_error_Z.absolute_indicies(2)] = ...
    find(error_Z.total == max_error_Z.true);
Z_true_error.mean_error = sum(error_Z.total,'all')/numel(error_Z.total);
Z_true_error.std_dev = sqrt(sum((error_Z.total-Z_true_error.mean_error).^2,'all')/numel(error_Z.total));

%{
figure
histogram(error_Z.total,10000)
hold on
xline(Z_true_error.mean_error, '--', 'Mean','Color','r')
xline(Z_true_error.mean_error + Z_true_error.std_dev, '-', '+1 Standard Deviation','Color','b')
xline(Z_true_error.mean_error - Z_true_error.std_dev, '-', '-1 Standard Deviation','Color','b')
xline(Z_true_error.mean_error + 2*Z_true_error.std_dev, '--', '+2 Standard Deviation','Color','b')
xline(Z_true_error.mean_error - 2*Z_true_error.std_dev, '--', '-2 Standard Deviation','Color','b')
xline(Z_true_error.mean_error + 3*Z_true_error.std_dev, '-.', '+3 Standard Deviation','Color','b')
xline(Z_true_error.mean_error - 3*Z_true_error.std_dev, '-.', '-3 Standard Deviation','Color','b')
xlim([-max_error_Z.true,max_error_Z.true])
xlabel('Error for Z')
ylabels = linspace(0,100,11);
set(gca,'YTickLabel',ylabels);
%}

%{
figure
hold on
plot(THETA_lines_10,absolute_error_Z,'.','Color','red')
xlabel('Theta');
ylabel('Absolute Error');
title('Absolute Error for Z v Theta')
xlim([0,2*pi]);
%}

figure
hold on
plot(PHI_lines_10,error_Z.total,'.','Color','red')
xlabel('Phi');
ylabel('Error');
title('Error for Z v Phi')
xlim([0,2*pi]);
xticks([0 pi/4 pi/2 3*pi/4 pi 5*pi/4 3*pi/2 7*pi/4 2*pi])
xticklabels({'0', '\pi/4', '\pi/2', '3\pi/4', '\pi', '5\pi/4', '3\pi/2', '7\pi/4', '2\pi'})
xline(11*pi/24);
xline(21*pi/24);


% relative error for Z
%{
relative_error_Z = abs((Z_lines_10 - calculated_coordinates.Z)./Z_lines_10);
max_error_Z.relative = max(max(abs(relative_error_Z)));
[max_error_Z.relative_indicies(1), max_error_Z.relative_indicies(2)] = ...
    find(relative_error_Z == max_error_Z.relative);

figure
hold on
plot(THETA_lines_10,relative_error_Z,'.','Color','red')
xlabel('Theta');
ylabel('Relative Error');
title('Relative Error for Z v Theta')
xlim([0,2*pi]);
%}
