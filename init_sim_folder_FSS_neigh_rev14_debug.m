clear;
clc;
close all force;
close all;
app=NaN(1);  %%%%%%%%%This is to allow for Matlab Application integration.
format shortG
%format longG
top_start_clock=clock;
folder1='C:\Users\nlasorte\OneDrive - National Telecommunications and Information Administration\MATLAB2024\7GHz FSS Neighborhoods';
cd(folder1)
addpath(folder1)
addpath('C:\Users\nlasorte\OneDrive - National Telecommunications and Information Administration\MATLAB2024\Basic_Functions')
addpath('C:\Users\nlasorte\OneDrive - National Telecommunications and Information Administration\MATLAB2024\General_Terrestrial_Pathloss')
addpath('C:\Users\nlasorte\OneDrive - National Telecommunications and Information Administration\MATLAB2024\General_Movelist')
addpath('C:\Users\nlasorte\OneDrive - National Telecommunications and Information Administration\MATLAB2024\3.1GHz Neighborhood') %%%%%%Rand Real Data
addpath('C:\Users\nlasorte\OneDrive - National Telecommunications and Information Administration\MATLAB2024\Generic_Bugsplat')
addpath('C:\Users\nlasorte\OneDrive - National Telecommunications and Information Administration\MATLAB2024\Census_Functions')
addpath('C:\Local Matlab Data\Local MAT Data') %%%%%%%One Drive Error with mat files
pause(0.1)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%FSS: Aggregate: Rand Real Excel Input
%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%This where you set the inputs for the simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_num=2  %%%%%%%25km
cell_data_filename=strcat('Nats_FSS_cell_sim_data',num2str(data_num),'.mat');
load(cell_data_filename,'cell_sim_data')
cell_sim_data{1,33}='tf_ant_square';     %tf_ant_square=0 %%%%%%%Instead of the trapezoid method used in CBRS
cell_sim_data{2,33}=0;     %tf_ant_square=0 %%%%%%%Instead of the trapezoid method used in CBRS
rev=163; %%%%%Navy Sites: 50th percentile with Azimuth and looking at Urban Area Impact: Nats Park 0dB Margin, 3 sector,
in_ratio=-10.5%-6;%%%%dB
margin=0;%%dB margin for aggregate interference
freq_separation=0; %%%%%%%Assuming co-channel
bs_eirp=50.5;%%%% %%%%%EIRP [dBm/10MHz] for Rural, Suburan, Urban: 62dBm/1MHz --> 36.25dBm/MHz at 50th (0,0), then - 1.25 for 80% TDD, 35dBm/Mhz --> 45dBm/10MHz
mitigation_dB=0;%:10:30;  %%%%%%%%% in dB%%%%% Beam Muting or PRB Blanking (or any other mitigation mechanism):  30 dB reduction %%%%%%%%%%%%Consider have this be an array, 3dB step size, to get a more granular insight into how each 3dB mitigation reduces the coordination zone.
mc_size=10000;%%%% Since we're at 50%
tf_full_binary_search=1;  %%%%%Search all DPA Points, not just the max distance point
min_binaray_spacing=1;%4%8; %%%%%%%minimum search distance (km)
reliability=[1,2,3,4,5,6,7,8,9,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,91,92,93,94,95,96,97,98,99]'; %%%A custom ITM range to interpolate from
confidence=50;
move_list_reliability=reliability;
agg_check_reliability=reliability;
FreqMHz=7250;
mc_percentile=80%100;%80%%%100;% since we're at 1 MC sim
sim_radius_km=128;%128%256%512; %%%%%%%%Placeholder distance         binary_dist_array=[2,4,8,16,32,64,128,256,512,1024,2048];
tf_clutter=0;%1%;  %%%%%%%????, Just do this in the EIRP reductions
sim_folder1='Z:\Matlab2025 Sims\7GHz FSS Neighborhood'  %%%%%%%%%%'C:\Local Matlab Data\7GHz FSS Neighborhood Test Sims'%
tf_opt=1; %%%%This is for the optimized move list, (not WinnForum)
tf_3sector=1%0;  %%%%%Else 1 Sector
tf_conus=1; %%%%%%Keep locations just within CONUS
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%'Run with 200MC at -10.5, 3 sectors and see if there is a difference.'


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Filter CONUS
size(cell_sim_data)
[keep_idx]=filter_conus_cell_sim_data(app,tf_conus,cell_sim_data);
cell_sim_data=cell_sim_data(keep_idx,:);
size(cell_sim_data)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Set the I/N ratio
col_header_in_ratio_idx=find(matches(cell_sim_data(1,:),'in_ratio'));
cell_sim_data([2:end],col_header_in_ratio_idx)=num2cell(in_ratio); %%%I/N dB

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Calculate the DPA Threshold
col_header_ant_gain_idx=find(matches(cell_sim_data(1,:),'rx_ant_gain_mb'));
col_header_rx_noise_temp_idx=find(matches(cell_sim_data(1,:),'Noise_TempK'));
col_header_rx_if_bw_idx=find(matches(cell_sim_data(1,:),'rx_if_bw_mhz'));
col_header_in_ratio_idx=find(matches(cell_sim_data(1,:),'in_ratio'));
col_header_x_pol_dB_idx=find(matches(cell_sim_data(1,:),'X_POL_dB'));
col_header_dpa_threshold_idx=find(matches(cell_sim_data(1,:),'dpa_threshold'));
col_header_fdr_dB_idx=find(matches(cell_sim_data(1,:),'fdr_dB'));
col_header_tf_cust_ant_idx=find(matches(cell_sim_data(1,:),'TF_Custom_Ant_Pattern'));

[num_rows4,~]=size(cell_sim_data);
tic;
for base_idx=2:1:num_rows4
    rx_temp_k=cell_sim_data{base_idx,col_header_rx_noise_temp_idx};
    rx_bw_mhz=cell_sim_data{base_idx,col_header_rx_if_bw_idx};
    in_ratio=cell_sim_data{base_idx,col_header_in_ratio_idx};
    x_pol_dB=cell_sim_data{base_idx,col_header_x_pol_dB_idx};
    fdr_dB=cell_sim_data{base_idx,col_header_fdr_dB_idx};
    tf_cust_ant=cell_sim_data{base_idx,col_header_tf_cust_ant_idx};

    %%%%%%%Calcualte the DPA Threshold
    if tf_cust_ant==1
        dpa_threshold=-138.7+10*log10(rx_bw_mhz)+10*log10(rx_temp_k)+in_ratio+x_pol_dB+fdr_dB
        cell_sim_data{base_idx,col_header_dpa_threshold_idx}=dpa_threshold;
    else
        'Add the normal dpa threshold calculation'
        pause;
    end
end
toc;
cell_sim_data(1:2,:)'



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if tf_3sector==1
    %%%%Deployment Lat/Lon
    tf_repull_rand=0%1%0
    excel_filename_rand='Rand_Real_2025_3Sectors_Idx.xlsx' %%%%%(This is the 3 sector and nationwide idx)
    mat_filename_str_rand=strcat('rand_real_2025_three_sector_idx.mat')

    %%%%%%%%%%%%%%%%%%%%%Non-Zero AAS EIRP Mask
    tf_repull_eirp=0%1%0
    excel_filename_eirp='EIRP Distribution_7.5 _EIRPMap-0ele all Azi.csv'
    mat_filename_str_eirp=strcat('eirp_7ghz_0ele_allAzi.mat')
    tic;
    [cell_eirp]=load_full_excel_rev1(app,mat_filename_str_eirp,excel_filename_eirp,tf_repull_eirp);
    toc;
    cell_eirp_header=cell_eirp(1,:);
    idx_50=find(contains(cell_eirp_header,'50th%'));
    idx_azi=find(contains(cell_eirp_header,'Azimuth'));
    idx_ele=find(contains(cell_eirp_header,'Elevation'));

    idx_0=find(matches(cell_eirp_header,'0th%'));
    idx_100=find(contains(cell_eirp_header,'100th%'));
    full_aas_eirp_data=cell2mat(cell_eirp([2:end],:));

    %%%%%%'Need to pull all azimuths at Zero elevation and the 0-100%'
    zero_idx=find(full_aas_eirp_data(:,idx_ele)==0);
    array_percentile_idx=idx_0(1):idx_100(1)
    zero_ele_eirp_data=full_aas_eirp_data(zero_idx,[idx_azi,idx_ele,array_percentile_idx]);
    new_cell_eirp_header=cell_eirp_header([idx_azi,idx_ele,array_percentile_idx]);
    [array_percentile]=extractNumbersFromCell(app,cell_eirp_header(array_percentile_idx));
    new_cell_eirp_header(array_percentile_idx)=num2cell(array_percentile);
  
    %%%%%Normalize the data to the zero azimuth which is 50.5
    max_50_zero_eirp=max(full_aas_eirp_data(:,idx_50));
    norm_aas_zero_ele_dist_data=zero_ele_eirp_data;
    norm_aas_zero_ele_dist_data(:,array_percentile_idx)=zero_ele_eirp_data(:,array_percentile_idx)-max_50_zero_eirp;
    cell_aas_zero_ele_dist_data=vertcat(new_cell_eirp_header,num2cell(norm_aas_zero_ele_dist_data)); %%%%%%%%This is what we will use.

    aas_elevation_data=cell2mat(cell_eirp([2:end],[idx_azi,idx_50]));
    bs_down_tilt_reduction=abs(max(aas_elevation_data(:,[2:end])));
    norm_aas_zero_elevation_data=horzcat(aas_elevation_data(:,1),aas_elevation_data(:,[2:end])-bs_down_tilt_reduction);
    max(norm_aas_zero_elevation_data(:,[2:end])) %%%%%This should be [0 0 0]
    norm_aas_zero_elevation_data(:,3)=norm_aas_zero_elevation_data(:,2);
    norm_aas_zero_elevation_data(:,4)=norm_aas_zero_elevation_data(:,2);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else%%%%%%%%%%%%%1 Sector
    %%%%Deployment Lat/Lon
    tf_repull_rand=0%1%0
    excel_filename_rand='Rand_Real_2025_1Sector_idx.xlsx' %%%%%(This is the 1 sector and nationwide idx)
    mat_filename_str_rand=strcat('rand_real_2025_one_sector_idx.mat')

    %%%%EIRP
    %%%%1) Azimuth -180~~180
    %%%2) Rural
    %%%3) Suburban
    %%%4) Urban
    % % aas_zero_elevation_data=zeros(361,4);
    % % aas_zero_elevation_data(:,1)=-180:1:180;
    aas_zero_elevation_data=zeros(181,4);
    aas_zero_elevation_data(:,1)=-180:2:180;
    norm_aas_zero_elevation_data=aas_zero_elevation_data;
    max(norm_aas_zero_elevation_data(:,[2:4])) %%%%%This should be [0 0 0]
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Base Station Deployment
tic;
[cell_rand_real]=load_full_excel_rev1(app,mat_filename_str_rand,excel_filename_rand,tf_repull_rand);
toc;
rand_real_2025=cell2mat(cell_rand_real([2:end],:)); %%%%%%%%1)Lat, 2)Lon, 3)Antenna Height 4)Azimuth 5)IDX
rand_real_2025(1:10,:)
rand_real_2025(:,6)=1; %%%%%We use this to indicate which norm_aas_zero_elevation_data to use.
base_station_latlonheight=rand_real_2025;  %%1)Lat, 2)Lon, 3)Height meters, 4)Azimuth 5)Idx 6)EIRP IDX
size(base_station_latlonheight)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hor_beamwidth=80
min_ant_loss=40
[ant_array]=horizontal_antenna_loss_mod2_app(app,hor_beamwidth,min_ant_loss);
pos_ant_array=ant_array;
neg_ant_array=ant_array;
neg_ant_array(:,1)=-1*ant_array(:,1);
custom_antenna_pattern=table2array(unique(array2table(vertcat(neg_ant_array,pos_ant_array))));
%%%Make it zero in the middle
figure;
hold on;
plot(norm_aas_zero_elevation_data(:,1),norm_aas_zero_elevation_data(:,2),'-sr')
plot(custom_antenna_pattern(:,1),custom_antenna_pattern(:,2),'-xg')
grid on;
% 'give more side lobe?'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tf_repull=0
excel_filename='7Ghz 0azi 0ele EIRP.xlsx'
mat_filename_str=strcat('eirp_dist_0_0.mat')
[cell_eirp_data]=load_full_excel_rev1(app,mat_filename_str,excel_filename,tf_repull);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cell_cut_eirp_data=cell_eirp_data(3:end,:);
cell_cut_eirp_data(:,1)=num2cell(0:10:100);
array_cut_eirp_data=cell2mat(cell_cut_eirp_data) %%%%%%%1)CDF, 2)EIRP
interp_x=0:1:100;
interp_y=interp1(array_cut_eirp_data(:,1),array_cut_eirp_data(:,2),interp_x,'spline');
interp_eirp_data=horzcat(interp_x',interp_y');

% % figure;
% % hold on;
% % plot(interp_x,interp_y,':b')
% % plot(array_cut_eirp_data(:,1),array_cut_eirp_data(:,2),'or')
% % grid on;

%%%'Normalize the 50th percentile to 0 since we have the 50th bs_eirp at 50.5dBm'
nn_50_idx=nearestpoint_app(app,50,interp_eirp_data(:,1));
interp_eirp_data(nn_50_idx,:)
norm_interp_eirp=interp_eirp_data;
norm_interp_eirp(:,2)=interp_eirp_data(:,2)-interp_eirp_data(nn_50_idx,2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%'We need to resample the base station eirp distribution to the same distribution as the pathloss'
cut_norm_y=interp1(norm_interp_eirp(:,1),norm_interp_eirp(:,2),reliability,'spline');
bs_eirp_dist=horzcat(reliability,cut_norm_y)


figure;
hold on;
plot(norm_interp_eirp(:,1),norm_interp_eirp(:,2),':r')
plot(array_cut_eirp_data(:,1),array_cut_eirp_data(:,2)-interp_eirp_data(nn_50_idx,2),'sg','LineWidth',3)
plot(bs_eirp_dist(:,1),bs_eirp_dist(:,2),':ob')
grid on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%Need to resample the cell_aas_zero_ele_dist_data to the samedistribution as the pathloss
if tf_3sector==1
    temp_cell_header=cell_aas_zero_ele_dist_data(1,:);
    [array_per,per_idx]=extractNumbersAndIndices(app,temp_cell_header);
    array_per_data=cell2mat(cell_aas_zero_ele_dist_data([2:end],per_idx));
    [inter_per_data]=interpRows(array_per_data,array_per,reliability,'spline');

    col_azi_idx=findTextInCell(temp_cell_header, 'Azimuth');
    array_azi_data=cell2mat(cell_aas_zero_ele_dist_data([2:end],col_azi_idx));
    cell_aas_dist_data=cell(2,1);
    cell_aas_dist_data{1}=array_azi_data;
    cell_aas_dist_data{2}=inter_per_data;

    size(array_per_data)
    size(inter_per_data)

    figure;
    hold on;
    plot(reliability,inter_per_data(1,:),':r')
    plot(array_per,array_per_data(1,:),'ob')
    grid on;
else
    cell_aas_dist_data=cell(2,1);
    array_azi_data=[-180:2:180]';
    cell_aas_dist_data{1}=array_azi_data;
    num_azi=length(array_azi_data)
    [num_rows,~]=size(bs_eirp_dist)
    inter_per_data=NaN(num_azi,num_rows);
    for m=1:1:num_azi
        inter_per_data(m,:)=bs_eirp_dist(:,2);
    end
    cell_aas_dist_data{2}=inter_per_data;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%Create a Rev Folder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd(sim_folder1);
pause(0.1)
tempfolder=strcat('Rev',num2str(rev));
[status,msg,msgID]=mkdir(tempfolder);
rev_folder=fullfile(sim_folder1,tempfolder);
cd(rev_folder)
pause(0.1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bs_down_tilt_reduction=0;
bs_eirp_reductions=(bs_eirp-bs_down_tilt_reduction)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maine_exception=1;  %%%%%%Just leave this to 1
Tpol=1; %%%polarization for ITM
deployment_percentage=100; %%%%%%%%%%%Let's not change this.

building_loss=15;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Saving the simulation files in a folder for the option to run from a server
'First save . . .' %%%%%24 seconds on Z drive
tic;
cd(rev_folder)
pause(0.1)
save('reliability.mat','reliability')
save('move_list_reliability.mat','move_list_reliability')
save('confidence.mat','confidence')
save('FreqMHz.mat','FreqMHz')
save('Tpol.mat','Tpol')
save('building_loss.mat','building_loss')
save('maine_exception.mat','maine_exception')
save('tf_opt.mat','tf_opt')
save('mc_percentile.mat','mc_percentile')
save('mc_size.mat','mc_size')
save('margin.mat','margin')
save('deployment_percentage.mat','deployment_percentage')
save('tf_full_binary_search.mat','tf_full_binary_search')
save('min_binaray_spacing.mat','min_binaray_spacing')
save('sim_radius_km.mat','sim_radius_km')
save('bs_eirp_reductions.mat','bs_eirp_reductions')
save('norm_aas_zero_elevation_data.mat','norm_aas_zero_elevation_data')
save('agg_check_reliability.mat','agg_check_reliability')
save('tf_clutter.mat','tf_clutter')
save('base_station_latlonheight.mat','base_station_latlonheight')
save('mitigation_dB.mat','mitigation_dB')
save('bs_eirp_dist.mat','bs_eirp_dist')
save('cell_aas_dist_data.mat','cell_aas_dist_data')
toc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd(rev_folder)
pause(0.1)
cell_sim_data(1:2,:)'
'Last save . . .'
tic;
save('cell_sim_data.mat','cell_sim_data')
toc;

col_header_base_ppts_idx=find(matches(cell_sim_data(1,:),'base_protection_pts'));
cell_ppt_size=cellfun(@size,cell_sim_data(:,col_header_base_ppts_idx),'UniformOutput',false);
temp_ppt_size=cell2mat(cellfun(@size,cell_sim_data(:,col_header_base_ppts_idx),'UniformOutput',false));


horzcat(cell_sim_data(:,1),cell_ppt_size)
max(temp_ppt_size(:,1))
cell_sim_data(:,[1,5,6,7,8,14,16,17,21])
size(cell_sim_data)
rev_folder

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Now running the simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tf_server_status=0;
parallel_flag=0%1%0;
[workers,parallel_flag]=check_parallel_toolbox(app,parallel_flag)
workers=2
tf_recalculate=0%1%0%1
tf_rescrap_rev_data=1%0%1
tf_print_excel=1%0%1%0%1


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
neighborhood_wrapper_rev12_super_bs_azi_idx_ua2023(app,rev_folder,parallel_flag,tf_server_status,workers,tf_recalculate,tf_rescrap_rev_data,tf_print_excel)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



end_clock=clock;
total_clock=end_clock-top_start_clock;
total_seconds=total_clock(6)+total_clock(5)*60+total_clock(4)*3600+total_clock(3)*86400;
total_mins=total_seconds/60;
total_hours=total_mins/60;
if total_hours>1
    strcat('Total Hours:',num2str(total_hours))
elseif total_mins>1
    strcat('Total Minutes:',num2str(total_mins))
else
    strcat('Total Seconds:',num2str(total_seconds))
end
close all force;
cd(folder1)
'Done'


