%% TITLE: spectra_kmeans_clustering.m
% 
% PURPOSE: An example code that performs k means clustering on spectra, 2
% dimensional data (e.g. size distributions).
% 
% INPUTS: --
% 
% OUTPUTS: Optional: .mat file of cluster centroids and indices of 
% clustering.
% 
% AUTHOR: Jeramy Dedrick
%         Scripps Institution of Oceanography, La Jolla, CA
%         09 September 2024
 

format long
clear all; close all; clc

% directory
WD = cd;

% output folder
out_dir = WD;



%% Data Load

% input data
datafile = strcat(WD, '/example_COMBLE_PNSDs.mat');
load(datafile)

% renaming data variables
diam = COMBLE_diameter_merged;
PNSD = COMBLE_PNSD_merged_hr;

% length of available data
N_data_avail = length(find(all(~isnan(PNSD))));


%% K means clustering alogrithm

clusters   = 1:20;   % number of k clusters to test
max_iter   = 10000;  % maximum number of iterations (the higher, the more robust, but requires more computing time)
replicates = 5;      % number of replicates

% normalized spectra [0 to 1]: normalization done to remove dependence on
% maximum value of signal and highlight change in shape
PNSD_norm_hr = PNSD ./ nanmax(PNSD);



for i = 1:length(clusters)
    
    disp(strcat('Performing k-means clustering of PNSD: k = ', num2str(i)))
    
    [PNSD_clust_idx(:,i), ...
     PNSD_clust_centroid{i}] = kmeans(PNSD_norm_hr', ...         % input matrix
                                      clusters(i), ...           % number of clusters
                                      'Distance', 'cosine', ...  % distance metric
                                      'MaxIter', max_iter, ...   % max iterations
                                      'Replicates', replicates); % replicates
                                        
                                    
 
end



%% Plot Cluster Centroids for Given K
close all; clc

k_clusters = 7; % which k do you want to see?



cluster_freq   = [];
k_clust_legend = [];

figure(1)
loglog(diam, PNSD_clust_centroid{k_clusters}', 'LineWidth', 3)
grid on
xlim([1e-2 1e1])
ylim([1e-3 1e0])
ylabel('Normalized Size Distribution')
xlabel('Diameter (\mum)')

for i = 1:k_clusters

    
    % frequency of cluster
    cluster_freq = (length(find(PNSD_clust_idx(:,k_clusters)==i)) ./ ...
                   N_data_avail) .* 100;

    k_clust_legend{i} = strcat('cluster =', num2str(i), ...
                               ' (', num2str(round(cluster_freq, 1)), '%)');
end
legend(k_clust_legend)
title(strcat('k =', num2str(k_clusters)))
set(gca, 'FontSize', 11)


set(gcf, 'Position', [200 150 400 300])



%% Saving Data

% save(strcat(out_dir, 'COMBLE_PNSD_kmeans_hr.mat'), ...
%     'PNSD_norm_hr',...
%     'PNSD_clust_idx_hr',...
%     'PNSD_clust_centroid_hr')