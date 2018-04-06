function [z] = DepthArray(n, dt, nt, Kz, maxZ)
%DepthArray This function is used to reduce the memory load on the
%Nicks_DTDD script.  It takes in the number of time steps and the n value
%(10^n) which determines how many cells we will be dealing with and returns
%a completed depth matrix.  It dstributes the 10^n cells over the top 100m
%and performs a random walk simulation for each cell over each time step
%   INPUTS
%       n - number of cells (10^n)
%       dt - change in time with each step (in seconds)
%       nt - number of time steps
%       Kz - vertical mixing coefficient
%   OUTPUTS
%       z - a 10^n x nt matrix of the depth experienced by each cell for each
%       step in time

    z = zeros(10^n, nt); % holding vector for our depth values. 

    z(:, 1) = linspace(0, maxZ, 10^n);
    walk = sqrt(2*dt*Kz); % this is the distance that will be walked,
                          % either up or down based on our timestep and
                          % vertical eddy diffusivity
% Now that we have our starting depths, we perform our random walk
    for i = 2:nt % time step loop
        pm = sign(0.50-rand(10^n,1)); % a matrix of randomly generated positive
                                   % or negative ones that will the random
                                   % part of our simulated walk.
        pm=pm.*walk;
        z(:,i)=z(:,i-1)+pm;
        % Calculate boundaries in vector form.  1.147 seconds for n=4 becomes
        % 0.16 seconds for the whole function.  
        ltz = find(z(:, i) < 0);
        z(ltz, i) = -z(ltz, i);
        gtmax = find(z(:, i) > maxZ);
        z(gtmax, i) = 2*maxZ - z(gtmax, i);
                   
      clear pm;
    end
clear i; clear j; clear walk, clear pm;

    

end

