
filename = 'Figures/hfd_variance_nhp.gif'; % Specify the output file name

samples = [dv_tenthp,dv_fifthp,dv_halfp,dv_1p,dv_2p,dv_5p,dv_10p];
titles = [0.1,0.2,0.5,1,2,5,10];

for i = 1:size(samples,2)
    % temporary ordered array where maximum number will be deleted through each itteration
    ordered = sortrows([linspace(1,size(samples(i).nhp_trig,1),size(samples(i).nhp_trig,1))',samples(i).nhp_trig],2);
    % bin array to keep track of number of hit points and variance
    samples(i).bin_array = linspace(0,max(ordered(:,2)),max(ordered(:,2))+1)';
    for j = 1:size(unique(ordered(:,2)),1);
        % find the index for every existing max
        [r,c] = find(ordered(:,2) == max(ordered(:,2)));
        temp_sum = 0;
        for k = 1:size(r,1)
            % sum the square of the difference between the sample hfd and the total hfd
            temp_sum = temp_sum + sum((samples(i).sample_hf_density(ordered(r(k),1),:)-samples(i).hf_density(ordered(r(k),1))).^2);
        end
        % remove maximum nhp and corresponding index
        ordered(r,:) = [];
        % divide by n-1 to find variance
        samples(i).bin_array(max(ordered(:,2))+1,2) = temp_sum/(size(r,1)*size(samples(i).sample_nhp_trig,2)-1);
    end
    var_nonzero = samples(i).bin_array(:,2);
    var_nonzero(var_nonzero==0) = nan;
    
    fig = figure;
    hold on
    plot(samples(i).bin_array(:,1),var_nonzero,'.','Color','red');
    xlabel('Number of Hitpoints in a Triangle');
    ylabel('Variance of Heat Flux Density');
    title(sprintf('Variance for %2.1f Percent of Data v. Number of Hit Points',titles(i)));
    frame = getframe(fig);
    im{i} = frame2im(frame);
end

clear fig;
clear frame;

figure;
for idx = 1:size(samples,2)
    subplot(3,3,idx)
    imshow(im{idx});
end

for idx = 1:size(samples,2)
    [A,map] = rgb2ind(im{idx},256);
    if idx == 1
        imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',1);
    else
        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',1);
    end
end