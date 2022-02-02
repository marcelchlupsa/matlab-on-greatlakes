function [NN, time] = nrst_nbrs_timed(numElement, adj, mis_area)
% compute the ratio of exposed area to total grain surface area
% ========================================================================
% FILENAME:         nrst_nbrs.m
% CREATED:          5 Dec, 2021
% LAST UPDATED:     19 Jan, 2022
% PURPOSE:          count primary (NN1), secondary (NN2), and tertiary
%                   (NN3) nearest neighbors
% ========================================================================
% IN:
% numElement:       n*2 array with gid (:,1) and voxel count(:,2)
% adj:              m*2 array shows grain adjacency in ascending order
%
% OUT:
% NN:               n*5 array with gid(:,1), voxel count(:,2), NN1(:,3), NN2(:,4), and NN3(:,5)            
% ========================================================================
% EXAMPLE:
% [NN] = nrst_nbrs(numElement, adj)
% ========================================================================

%% start counting
tic
%% remove zero-area boundaries
    adj_copy = adj;
    
    rm = zeros(length(adj_copy),1);
    j = 1;
    % learn where the zero-area boundaries are: rm
    for i = 1:length(mis_area)
        if mis_area(i,4) == 0
            rm(j,1) = i;
            j = j + 1;
        else
            % do nothing
        end
    end
    % reduce length(rm)
    for i = length(adj):-1:j
        rm(i,:) = [];
    end
    % cut the zero-area boundaries out: adj_copy
    for i = length(rm):-1:1
        j = rm(i,1);
        adj_copy(j,:) = [];
    end
    
%% create n x n array(s) for logical adj based on numE indexing
    % 0 == NO adj btw goi & goj
    % 1 == YES adj btw goi & goj
    
    % NN1
    adj_sq1 = zeros(length(numElement),length(numElement));
    for i = 1:length(numElement)
        for j = 1:length(adj_copy)
            if adj_copy(j,1) == numElement(i,1)
                k = adj_copy(j,2);
                for h = 1:length(numElement)
                    if numElement(h,1) == k
                        adj_sq1(h,i) = 1;
                    else
                        % do nothing
                    end
                end
            else
                % do nothing
            end
            if adj_copy(j,2) == numElement(i,1)
                k = adj_copy(j,1);
                for h = 1:length(numElement)
                    if numElement(h,1) == k
                        adj_sq1(h,i) = 1;
                    else
                        % do nothing
                    end
                end
            else
                % do nothing
            end
        end
    end
    
    % NN2
    adj_sq2 = zeros(length(numElement),length(numElement));
    for i = 1:length(numElement)
        for j = 1:length(numElement)
            if adj_sq1(j,i) == 0
                % do nothing
            else
                adj_sq2(:,i) = adj_sq2(:,i) + adj_sq1(:,j);
            end
        end
    end
    
    % NN3
    adj_sq3 = zeros(length(numElement),length(numElement));
    for i = 1:length(numElement)
        for j = 1:length(numElement)
            if adj_sq2(j,i) == 0
                % do nothing
            else
                adj_sq3(:,i) = adj_sq3(:,i) + adj_sq1(:,j);
            end
        end
    end

%% count & compile NN1, NN2, and NN3 results into NN output
    NN = cat(2,numElement,zeros(length(numElement),3));
%     % overcounting
%     for i = 1:length(numElement)
%         % NN1
%         NN(i,6) = sum(adj_sq1(:,i));
%         % NN2
%         NN(i,7) = sum(adj_sq2(:,i));
%         % NN3
%         NN(i,8) = sum(adj_sq3(:,i)); 
%     end
    % avoid overcounting
    adj_sq2 = adj_sq2~=0;
    adj_sq2 = adj_sq2 - adj_sq1;
    adj_sq3 = adj_sq3~=0;
    adj_sq3_rm = adj_sq1 + adj_sq2;
    adj_sq3_rm = adj_sq3_rm~=0;
    adj_sq3 = adj_sq3 - adj_sq3_rm;
    for i = 1:length(numElement)
        NN(i,3) = nnz(adj_sq1(:,i));
        NN(i,4) = nnz(adj_sq2(:,i));
        NN(i,5) = nnz(adj_sq3(:,i));
    end
%%
time = toc;
%% delete intermediate vars
    clear adj_sq1 adj_sq2 adj_sq3 adj_sq3_rm i j k h