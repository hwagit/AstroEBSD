function [Peak_Centres,Peak_Quality,Peak_NBands,...
    outputs] = Map_Radon(AreaData,EBSPData,Settings_Cor,Settings_Rad,InputUser)
% Map_Radon Radon transform for a map of data stored in HDF5 format
%
% INPUTS
% EBSPData - HDF5 information
% Settings_Cor = BG correction settings to use
% Settings_Rad = Radon Transform settings
%
% OUTPUTS
% Peak_Centres = peak centres in [theta,rho,n] format
% Peak_Quality = peak quality in [n,IQ Slope] format
% Peak_NBands = number of bands found as [n x 1] format
% where n is the pattern number, as defined by the HDF5 format
% see bReadEBSP for information on that

% Prepare the data stores
Peak_Quality = zeros(AreaData.max_pats,2);
Peak_Centres = zeros(Settings_Rad.max_peaks,2,AreaData.max_pats);
Peak_NBands = zeros(AreaData.max_pats,1);

parfor n=1:AreaData.max_pats
    % Read pattern & correct
    pattern2 = bReadEBSP(EBSPData,n,InputUser,AreaData);
    EBSP_cor = EBSP_BGCor( pattern2,Settings_Cor );
    
    % radon convert
    [ Peak_Centre_ok,Peak_Quality(n,:) ] = EBSP_RadHunt( EBSP_cor,Settings_Rad);
    
    %count the number of bands
    n_bands=size(Peak_Centre_ok,1);
    Peak_NBands(n)=n_bands;
    %fill in the peak centre data
    Peak_Centre_full=zeros(Settings_Rad.max_peaks,2);
    Peak_Centre_full(1:n_bands,:)=Peak_Centre_ok;
    Peak_Centres(:,:,n)=Peak_Centre_full;
    
end

%need one pattern run through this to get the output size correct for th
%next step
pattern2 = bReadEBSP(EBSPData,1,InputUser,AreaData);
[~,outputs ] = EBSP_BGCor( pattern2,Settings_Cor );

end

