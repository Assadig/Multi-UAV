function C = DE_operations(lu, Q)

% C: the population after DE operations  
% lu: the upper and lower bounds of the variables
% Q: the population before DE operations

F = 0.9;   % F: the scaling factor of DE缩放因子
CR = 0.9;   % CR: the crossover control parameter of DE

[mu, n] = size(Q);

C = ones(mu, n);

for index = 1 : mu
    
    % "rand/1" strategy
    
    % Choose the indices for mutation
    index_set = 1 : mu;
    index_set(index) = [];
    
    % Choose the first index
    temp = ceil(rand * (mu - 1));
    index1 = index_set(temp);
    index_set(temp) = [];
    
    % Choose the second index
    temp = ceil(rand * (mu - 2));
    index2 = index_set(temp);
    index_set(temp) = [];
    
    % Choose the third index
    temp = ceil(rand * (mu - 3));
    index3 = index_set(temp);
    
    % Mutate  突变操作
    v = Q(index1, :) + F * (Q(index2, :) - Q(index3, :));
    
    % Handle the elements of the mutant vector which violate the boundary处理突变体向量中违反边界的元素
    vio_lower = find(v < lu(1, :));
    v(vio_lower) = 2 * lu(1, vio_lower) - v(1, vio_lower);
    vio_lower_upper = find(v(vio_lower) > lu(end, vio_lower));
    v(vio_lower(vio_lower_upper)) = lu(end, vio_lower(vio_lower_upper));
    
    vio_upper = find(v > lu(end, :));
    v(vio_upper) = 2 * lu(end, vio_upper) - v(vio_upper);
    vio_upper_lower = find(v(vio_upper) < lu(1, vio_upper));
    v(vio_upper(vio_upper_lower)) = lu(1, vio_upper(vio_upper_lower));
    
    % Implement the binomial crossover交叉
    j_rand = ceil(rand * n);
    t = rand(1, n) <= CR;
    t(j_rand) = 1;
    t_ = 1 - t;
    u = t .* v + t_ .* Q(index, :);
    
    C(index, :) = u;
    
end
