function [Table] = DTDDMuSig(Rt,z)
%DTDDMUSIG This function takes in vectors for DT/DD ratios and depth and
%outputs a table that gives the mean value for the DT/DD ratio and the
%standard deviation for each meter in the water column
%   INPUTS
%       Rt - a vector of DT/DD ratios.  Each row is assumed to correspond
%       to a particular phytoplankter
%       z - a vector of depth location in the water column for each of the
%       phytoplankton in the simulation.
%   OUTPUTS
%       Table - a data table with two columns containing the mean and
%       standard deviation values for the sample population of
%       phytoplankton in each meter of the water column.
%
%   This function assumes that only the vectors for the particular time
%   period of interest are passed in.

    bZ=ceil(max(z)); % getting the deepest depth experienced by our 
                     % phytoplankton, rounded up to the nearest integer.
    rNames = cell(bZ,1);
    mu=zeros(bZ,1);
    sig=zeros(bZ,1);
    for i = 1:bZ
       rNames{i}=sprintf('%i m',i);
       if i == 1
           ind = find(z<i);
       else
           ind = find(z>=(i-1) & z<i);
       end
       mu(i)=mean(Rt(ind));
       sig(i)=std(Rt(ind));
    end
    Table = table(mu,sig,'VariableNames',{'Mu','Sig'},...
        'RowNames',rNames);

    Table.Properties.VariableDescriptions={'mean value of DT/DD ratios at 1m intervals',...
        'standard deviation of DT/DD ratios at 1m intervals'};
end

