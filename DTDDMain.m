function [Rt,Mu,Sig] = DTDDMain(n,HH,MM,Kz,maxZ)
%DTDDMAIN This is the main function that is called through the use of the
%DTDDGui.  It calls all necessary functions to simulate the change in
%daitoxanthin/diadinoxanthin ratios for 10^n number of phytoplankton spaced
%evenly across the water column defined by z.  All values input into this
%function are provided by the user through the DTDDGui function.
%   INPUTS
%       n = number of phytoplankto cells in the simulation (10^n)
%       HH = The hour value for the end time of the simulation (simulation
%       begins at 06:00)
%       MM = The minute value for the end time of the simulation
%       z = The depth to which we will distribute our phytoplankton cells
%       and simulate their motion.
%       Kz = The vertical mixing rate provided by the user (cm^2/s).
%   OUTPUTS
%       Mu - the mean values of the DT/DD ratios for each meter of the
%       water column considered.
%       Sig - the standard deviation of the DT/DD ratios for each meter of
%       the water column considered.
tic
h1=msgbox('Simulation In Progress','Simulation Running','warn');
start = datenum('07-24-2014 06:00:00'); % the start time for our simulation
% JSR the next line had a mix of numbers and text which led to a negative
% simulation time!  Perhaps this is due to Matlab version changes.
stop = datenum([2014, 7, 24, HH, MM, 0]);  % user defined end time
simtime = datestr(stop-start,15);
start=datevec(start);stop=datevec(stop); % the etime function requires dates in vector format

% ERROR in original: the dt variable was provided, but the number of timesteps
% was hardcoded based on dt = 60.  This is now fixed.
dt = 60; % this is our delta t (60 = 1 minute in seconds)
nt=(etime(stop,start)/dt); % this is the number of iterations in our simulation;
                           % the number of minutes between start and end
                           % times.
                          
% Irr needs to be interpolated to match the step size, so call it here after
% dt is set.
irr = irrCall_noGUI(dt);

                           
clear start; clear stop;

fKz = Kz*10^(-4); % converting from cm^2/s to m^2/s

if length(irr) > nt
   irr = irr(1:nt); % We only want the matrix to be as long as is needed.
elseif length(irr) < nt
    error("Not enough irradiance values for the specified time span!");
end
% JSR irr values are received on a 1-minute interval, but 
t=zeros(1,2); % We need to determine how long this will take.

z = DepthArray(n,dt,nt,fKz,maxZ); % Generating our matrix of the depths experienced
                                 % by each phytoplankton over each time
                                 % step.  Each row corresponds to an
                                 % individual phytplankton cell while each
                                 % column represents a time step.  The
                                 % value in each cell is the depth of the
                                 % phytoplankton at that time step.
t(1)=toc;
Iz = NickEq3(irr,z); % This will use the depth vector we got from our
                       % random walk and our surface irradiance to
                       % calculate
                       %M the irradiance at the depth of our phytoplankton.
z(:,1:(nt-1))=[]; % Since Nick is only interested in the spread of DT/DD ratios
                % at the selected end time of the simulation, we can delete
                % all the earlier depth values of phytoplankton depth and
                % free up some memory.
Req = NickEq1(Iz); % this gives us the DT/DD equilibrium ratio our
                   % phytoplankton are desparately trying to achieve.
clear Iz; % We only need the Iz values to calculate Req, we can now free up
          % some memory by removing it.
r = 0.0232; % our reaction rate (1.39/h on per minute basis).  This is the 
            % reaction rate constant for Thalassiosiro weissflogii.
            
%The below code loops through each time step and records the DT/DD ratio
%for each individual phytoplankton cell at each time step.  This puts a
%very large strain on the memory and computing.  We will keep this code in 
%case Nick wants to get at this data but currently he is only interested in
%the final DT/DD ratios as a function of depth.  So we will comment this
%out and tweak our code to not keep records we don't need.
%{
Rt = zeros(10^n,nt); % instantiating our vector
Rt(:,1) = Req(:,1);
for i = 2:nt
    for j = 1:10^n
        Rt(j,i)=NickEq2(Req(j,i),Rt(j,i-1),r,(dt/60)); 
    end
    %animateDTDD(Rt(:,i),z(:,i),i,filename,Kz)
end
%}

Rt=zeros(10^n,2); % This vector will hold our DT/DD ratios for each phytoplankton
Rt(:,1)=Req(:,1);
for i = 2:nt
    % For 12 hours, 100 meters, and n=4, this takes 0.03 seconds in vector form
    % as shown, and 13.04 seconds with a "for" loop.  A 435x win.  Results are 
    % identical.
    Rt(:,2)=NickEq2(Req(:,i),Rt(:,1),r,(dt/60));
    Rt(:,1)=Rt(:,2); % by copying the results of the random walks in our 
                     % second column into our first column, this allows the
                     % simulation to step through every timestep and
                     % advance the phytoplankton without having to keep all
                     % the unecessary records of their Rt values for each
                     % timestep.
end
Rt(:,1)=[];


% Now we want to collect the variance in the Rt valcloues for each meter of
% depth in the water column.  We have built a function to provide this to
% us, we just need to input the column of both Rt and z that correspond to
% the time we are interested in. 

T1=DTDDMuSig(Rt,z); % this will output a data table which
                                  % will contain two columns (mean and st
                                  % dev) of data.  Each row will correspond
                                  % to a 1m interval in the water column
scrz=get(0,'ScreenSize');
figure('Position',scrz/2);
scatter(Rt,z)
hold on
plot(T1.Mu,1:ceil(max(z())),'--go','LineWidth',3)
set(gca,'YDir','reverse','XAxisLocation','Top')
hold on
plot(T1.Sig,1:ceil(max(z())),'--rd','LineWidth',3)
ylabel('Depth (m)')
legend('DT/DD Final','Mean DT/DD','St Dev DT/DD','location','SouthEast')

mytitle = sprintf(['Mean DT/DD ratios as a function of depth \n'...
    'Cells: 10^%i, Kz: %i cm^2/s, Time: %s hrs, dt: %d s'], n, Kz, simtime, dt);
title(mytitle,'FontSize',12)

% Temporary check by JSR - see if particles are biased up or down.  They start
% evenly distributed, so the final distribution should also be constant.
% Get the number of particles in each meter interval from 0 to maxZ (rounded
% down).
figure('Position',scrz/2 + [0, scrz(4)/2-60, 0, 0]);
histogram(z, maxZ)
xlabel('Depth (m)');
ylabel('Particles per meter');
title(sprintf('Particle distribution, 10^%d particles, dt = %d', n, dt))

Mu=T1.Mu;Sig = T1.Sig;
t(2)=toc;

delete(h1)
end

