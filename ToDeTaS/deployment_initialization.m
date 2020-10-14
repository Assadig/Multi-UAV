function UAV = deployment_initialization(d_min, N, lu)

% UAV: the deployment of UAVs
% d_min: the minimum distance between UAVs
% N: the nummber of UAVs
% lu: the upper and lower bounds of the variables

conflict_max = 200;   % the maximum number of conflicts
UAV_index = 1;   % the index of the UAV being deployed
conflict = 0;   % the number of conflicts

UAV = ones(N, 2);

% Initialize the deployment of UAVs
while UAV_index <= N
    
    UAV(UAV_index, :) = lu(1, :) + rand(1, 2) .* (lu(end, :) - lu(1, :));
    flag = 0;
    
    if any(sqrt(sum((UAV(UAV_index, :) - UAV(1 : UAV_index - 1, :)) .^ 2, 2)) < d_min)
        
        flag = 1;
        conflict = conflict + 1;
        
    end
    
    if flag == 0
        
        UAV_index = UAV_index + 1;
        conflict = 0;
        
    elseif conflict == conflict_max
        
        UAV_index = 1;
        conflict = 0;
        
    end
    
end

UAV = reshape(UAV, 1, 2 * N);
