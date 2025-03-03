function plot_2d(Phi_lines, Theta_lines, option, data_variance_data, sample_number)

%%%%%%%%%%%%%%% Default Parameters %%%%%%%%%%%%%%
  switch nargin         % creates a few default options
      case 2 
          option = 0;
          data_variance_data = [];
          sample_number = 0;
      case 3
          data_variance_data = [];
          sample_number = 0;
      case 4
          sample_number = 1;
      case 0         % else throw error
          error('Phi and Theta are required.')
  end

%% Creating the mesh grid in 2D %%
clear grid;
p=180;
t=90;
a = p*t; % number of vertices that will be used
b = a+p+t+1;
phi = linspace(0,2*pi,p+1); % partition as measured in the toroidal direction 
theta = linspace(0,2*pi,t+1);   % partition as measured in the poloidal direction
[Phi, Theta]=meshgrid(phi(1:p+1),theta(1:t+1)); % creates an array from phi and theta 
Phi = reshape(Phi,[b,1]);
Theta = reshape(Theta,[b,1]);
grid.vertices(:,1) = Phi;
grid.vertices(:,2) = Theta;

clear faces
faces.lower(:,1) = [1:b-(t+1)];
faces.lower(:,2) = [2:b-t];
faces.lower(:,3) = [t+2:b];
faces.lower(t+1:t+1:end,:) = [];

faces.upper(:,1) = [2:b-t];
faces.upper(:,2) = [t+3:b+1];
faces.upper(:,3) = [t+2:b];
faces.upper(t+1:t+1:end,:) = [];

grid.faces = reshape([faces.lower(:) faces.upper(:)]', [], 3); % combines upper and lower triangular face arrays using every other row

%% Plotting the Figure %%
figure;
% plotting the vessel on a 2D grid of Theta vs. Phi

% plotting only the vertices
    %plot(vessel_coords.vertices(:,1),vessel_coords.vertices(:,2),'.');
    
% plotting connected vertices in faces
if option == 0
    patch('Faces',grid.faces,'Vertices',grid.vertices, 'EdgeColor', [0.6 0.6 0.6], 'FaceColor', [1 1 1]);
    hold on
    plot(Phi_lines, Theta_lines, 'linestyle', 'none', 'marker', '.','color','red');
elseif option == 1
    faces_cdata = data_variance_data;
    patch('Faces',grid.faces,'Vertices',grid.vertices,'FaceVertexCData',faces_cdata,'FaceColor','flat','EdgeColor','None');
    colorbar
% color mapping of number of hit points per triangle
elseif option == 2
    faces_cdata = data_variance_data(:,sample_number);
    patch('Faces',grid.faces,'Vertices',grid.vertices,'FaceVertexCData',faces_cdata,'FaceColor','flat','EdgeColor','None');
    colorbar

xticks([0 pi/4 pi/2 3*pi/4 pi 5*pi/4 3*pi/2 7*pi/4 2*pi])
xticklabels({'0', '\pi/4', '\pi/2', '3\pi/4', '\pi', '5\pi/4', '3\pi/2', '7\pi/4', '2\pi'})
xlim([0,2*pi]);
yticks([0 pi/4 pi/2 3*pi/4 pi 5*pi/4 3*pi/2 7*pi/4 2*pi])
yticklabels({'0', '\pi/4', '\pi/2', '3\pi/4', '\pi', '5\pi/4', '3\pi/2', '7\pi/4', '2\pi'})
ylim([0,2*pi]);
daspect([1 1 1]);
xlabel('Phi');
ylabel('Theta');
end
