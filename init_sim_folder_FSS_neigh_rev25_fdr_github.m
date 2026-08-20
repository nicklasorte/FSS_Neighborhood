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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%FSS Aggregate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Data Header
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cell_data_header=cell(1,42);
cell_data_header{1}='data_label1';
cell_data_header{2}='latitude';
cell_data_header{3}='longitude';
cell_data_header{4}='rx_bw_mhz';
cell_data_header{5}='rx_height';
cell_data_header{6}='ant_hor_beamwidth';
cell_data_header{7}='min_azimuth';
cell_data_header{8}='max_azimuth';
cell_data_header{9}='rx_ant_gain_mb';
cell_data_header{10}='rx_nf';
cell_data_header{11}='in_ratio';
cell_data_header{12}='min_ant_loss';
cell_data_header{13}='fdr_dB';
cell_data_header{14}='dpa_threshold';
cell_data_header{15}='required_pathloss';
cell_data_header{16}='base_protection_pts';
cell_data_header{17}='base_polygon';
cell_data_header{18}='gmf_num';
cell_data_header{19}='rx_lat';
cell_data_header{20}='rx_lon';
cell_data_header{21}='base_polyshape';
cell_data_header{22}='ant_diamter_m';
cell_data_header{23}='Sat_ID';
cell_data_header{24}='Noise_TempK';
cell_data_header{25}='Ground_Elevation_m';
cell_data_header{26}='Antenna_Pattern_Str';
cell_data_header{27}='rx_if_bw_mhz';
cell_data_header{28}='array_ant_pattern';  %%%Change this to tf_custom_ant_pattern
cell_data_header{29}='TF_Custom_Ant_Pattern';
cell_data_header{30}='X_POL_dB';
cell_data_header{31}='gs_azimuth';
cell_data_header{32}='gs_elevation';
cell_data_header{33}='tf_ant_square';     %tf_ant_square=0 %%%%%%%Instead of the trapezoid method used in CBRS
cell_data_header{34}='second_in_ratio';  
cell_data_header{35}='second_mc_percentile'; 
cell_data_header{36}='mc_percentile';  
cell_data_header{37}='dpa_second_threshold';
cell_data_header{38}='azimuth_step';
cell_data_header{39}='tf_keyhole_ant';  %%%%%%For part 0 to limit
cell_data_header{40}='tf_ue_grid'; %%%%%%%If 0, then base stations
cell_data_header{41}='ue_grid_km';  %%%%%Spacing of UEs, The sim_radius_km will set the radius
cell_data_header{42}='ue_height_m';  %%%%%UE height in meters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%Nats Park Example
tf_repull_nats=0%1%0%1%0%1%0%0%1
data_num=6%5%4%3%2
cell_data_filename=strcat('Nats_FSS_cell_sim_data',num2str(data_num),'.mat');
[var_exist]=persistent_var_exist_with_corruption(app,cell_data_filename);
if tf_repull_nats==1
    var_exist=0;
end
if var_exist==2
    load(cell_data_filename,'cell_sim_data')
else

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%WGS F1 (USA 195): -42.53 (Longitude): NORAD ID: 32258
    %%%WGS F5 (USA 243): -52.51 (Longitude): NORAD ID: 39168
    %%%WGS F6 (USA 244): -135.19 (Longitude): NORAD ID: 39222

    %%%38.8730° N, 77.0074 %%%%Nats Stadium

    cell_compiled_data=cell(1,42);
    cell_compiled_data{1,1}='NatsStadiumFSS';
    cell_compiled_data{1,2}=38.8730; %%%%%Lat
    cell_compiled_data{1,3}=-77.0074; %%%%Lon
    cell_compiled_data{1,5}=10;  %%%%%Height
    cell_compiled_data{1,6}=0.24; %%%%BW
    cell_compiled_data{1,7}=0; %%%Double Zero should keep it fixed (Non-rotating)
    cell_compiled_data{1,8}=0; %%%Double Zero should keep it fixed (Non-rotating)
    cell_compiled_data{1,9}=58; %%%Ant Gain
    cell_compiled_data{1,11}=-10.5; %%%I/N dB
    cell_compiled_data{1,13}=0; %%%FDR dB
    cell_compiled_data{1,16}=horzcat(cell_compiled_data{1,2},cell_compiled_data{1,3},cell_compiled_data{1,5});
    cell_compiled_data{1,17}=horzcat(cell_compiled_data{1,2},cell_compiled_data{1,3});
    cell_compiled_data{1,22}=12.2; %%An Diameter meters
    cell_compiled_data{1,23}='WGS F6 (USA 244)';     %%%WGS F6 (USA 244): -135.19 (Longitude): NORAD ID: 39222
    cell_compiled_data{1,24}=176.20;%%%%%Noise Temperature K
    cell_compiled_data{1,26}='itu_antenna_appendix8_annex3';
    cell_compiled_data{1,27}=60;%%%%Rx IF bandwidth MHz
    cell_compiled_data{1,29}=1;%%%%tf_custom_ant_pattern (which means we will save it and pull it).
    cell_compiled_data{1,30}=3;%%%%x_pol_dB 3dB
    cell_compiled_data{1,33}=0;     %tf_ant_square=0 %%%%%%%Instead of the trapezoid method used in CBRS
    cell_compiled_data{1,34}=-6;
    cell_compiled_data{1,35}=99.97;
    cell_compiled_data{1,36}=80;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    col_header_tf_ue_grid_idx=find(matches(cell_data_header,'tf_ue_grid'));
    col_header_ue_grid_km_idx=find(matches(cell_data_header,'ue_grid_km'));
    col_header_ue_height_m_idx=find(matches(cell_data_header,'ue_height_m'));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cell_compiled_data(:,col_header_tf_ue_grid_idx)=num2cell(0);
    cell_compiled_data(:,col_header_ue_grid_km_idx)=num2cell(0);
    cell_compiled_data(:,col_header_ue_height_m_idx)=num2cell(0);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%Satellite function
    [cell_compiled_data]=geo_sat_calc_rev1(app,cell_compiled_data,cell_data_header);

    %%%%%%%%Combine
    cell_sim_data=vertcat(cell_data_header,cell_compiled_data);

    cell_sim_data(1:2,:)'
    tic;
    save(cell_data_filename,'cell_sim_data')
    toc;
end
cell_nats_data=cell_sim_data;
cell_nats_data'


% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%
rev=280 %%%%%Nats Stadium
cell_sim_data=cell_nats_data;
tf_test=0%1
in_ratio=-10.5%;%%%%dB
margin=0;%%dB margin for aggregate interference
move_list_margin=0%1;
tf_full_turnoff=0%1%0 %%%%%Need to do this in a later rev maybe to make it similar to Visualyze
tf_fdr=1%0%1
freq_separation=0; %%%%%%%Assuming co-channel
bs_eirp=50.5;%%%% %%%%%EIRP [dBm/10MHz] for Rural, Suburan, Urban: 62dBm/1MHz --> 36.25dBm/MHz at 50th (0,0), then - 1.25 for 80% TDD, 35dBm/Mhz --> 45dBm/10MHz
mitigation_dB=0%:10:30;  %%%%%%%%% in dB%%%%% Beam Muting or PRB Blanking (or any other mitigation mechanism):  30 dB reduction %%%%%%%%%%%%Consider have this be an array, 3dB step size, to get a more granular insight into how each 3dB mitigation reduces the coordination zone.
mc_size=1000;%%%% Since we're at 50%
tf_full_binary_search=1;  %%%%%Search all DPA Points, not just the max distance point
min_binaray_spacing=1%4%1;%4%8; %%%%%%%minimum search distance (km)
reliability=[0.001,0.01,0.1,0.2,0.3,0.5,1,2,3,4,5,6,7,8,9,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,91,92,93,94,95,96,97,98,99,99.5,99.7,99.8,99.9,99.99,99.999]'; %%%A custom ITM range to interpolate from
confidence=50;
move_list_reliability=reliability;
agg_check_reliability=reliability;
FreqMHz=7250;
mc_percentile=80%100;%80%%%100;% since we're at 1 MC sim
sim_radius_km=512%64; %%%%%%%%Placeholder distance         binary_dist_array=[2,4,8,16,32,64,128,256,512,1024,2048];
tf_clutter=3%0;%1%;  %%%%%%%????, Just do this in the EIRP reductions, 1 == 2108 into pathloss, 3 is Distribution and Just Urban and Suburban
sim_folder1='C:\Local Matlab Data\7GHz FSS Neighborhood Test Sims'%  'Z:\Matlab2025 Sims\7GHz FSS Neighborhood'  %%%%%%%%%% 
tf_opt=1; %%%%This is for the optimized move list, (not WinnForum)
tf_3sector=0;  %%%%%Else 1 Sector
tf_conus=0%1; %%%%%%Keep locations just within CONUS
%%%%%%% Rx IF Selectivity
rx_label='Example Rx'
rx_freq_mhz=7445 %%%%%%20MHz %%%%%%%MHz
array_rx_if=fliplr(horzcat(0,25,25.33,43.75,85.6)); %%%%Frequency MHz Half Bandwidth
array_rx_loss=fliplr(horzcat(0,0.1,3,20,60)); %%%%%%%dB Loss
rx_extrap_loss=-60; %%%%%%%%%RX Extrapolation Slope dB/Decade 60dB 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



cell_sim_data'
sort(cell_sim_data(:,1))
if length(cell_sim_data(:,1))~=length(unique(cell_sim_data(:,1)))
    'Unique Name Error'
    pause;
end


if tf_fdr==1
    %%%%%%%%%%%%%%%%Example Code with OOBE and FDR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Inputs
    band_mhz=100; %%%%%%%% carrier bandwidth [MHz] [B]
    center_freq=7350; %%%%%%%MHz % carrier center [MHz]
    edge1=center_freq+band_mhz/2;
    oobeSeg = [edge1  edge1+20   -13  ;     % band edge to 7420
        edge1+20  edge1+40   -30;    % 7420-7430 MHz
        edge1+30  Inf   -40  ];    % above 7430 MHz
    cond_pwr_dBm=37.5;  % conducted power per transceiver [dBm], which is different than the 38.6dBm/1MHz or 58.6dBm/100MHz
    tx_extrap_loss=-60; %%%%%%%%%TX Extrapolation Slope dB/Decade -60dB (Past the last point 7600Mhz)   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Calculate the OOBE
    [table_oobe]=calc_oobe_7ghz_rev1(app,rev,oobeSeg,band_mhz,center_freq,cond_pwr_dBm)
    data_header_oobe=table_oobe.Properties.VariableNames;
    cell_oobe_data=table2cell(table_oobe);
    col_freq_offset_idx=find(matches(data_header_oobe,'offset_from_center_MHz'));
    col_eirp_idx=find(matches(data_header_oobe,'EIRP_PSD_dBm_per_MHz'));
    array_mask=cell2mat(cell_oobe_data(:,[col_freq_offset_idx,col_eirp_idx]));

    %%%%%%%Normalize mask for FDR
    norm_array_mask=array_mask;
    norm_array_mask(:,2)=abs(array_mask(:,2)-max(array_mask(:,2)));
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%FDR Curves
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%FDR Inputs
    array_tx_rf=fliplr(norm_array_mask(:,1)'); %%%%Frequency MHz (Base Station) [Half Bandwidth]
    array_tx_mask=fliplr(norm_array_mask(:,2)'); %%%%%%%dB Loss
    tx_freq_mhz=center_freq;
    fdr_freq_separation=abs(tx_freq_mhz-rx_freq_mhz)
    guard_band=fdr_freq_separation-band_mhz/2-array_rx_if(end-1)
    fdr_calc_mhz=ceil(fdr_freq_separation*1.25)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Calculate FDR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Delta_Freq_Step=1
    tic;
    [FDR_dB,ED,VD,OTR,DeltaFreq,single_fdr_loss,trans_mask] = FDR_ModelII_vector_rev2(app,fdr_calc_mhz,array_tx_rf,array_rx_if,array_tx_mask,array_rx_loss,tx_extrap_loss,rx_extrap_loss,Delta_Freq_Step);
    toc;
   
    zero_idx=nearestpoint_app(app,0,DeltaFreq);
    array_fdr=horzcat(DeltaFreq(zero_idx:end)',FDR_dB(zero_idx:end));
    fdr_idx=nearestpoint_app(app,fdr_freq_separation,array_fdr(:,1));
    fdr_dB=array_fdr(fdr_idx,:);  %%%%%%Frequency, FDR Loss
    temp_fdr=fdr_dB(2)

    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%FDR Plot
    figure;
    plot(array_fdr(:,1),array_fdr(:,2),'-ob')
    grid on;


    col_header_fdr_dB_idx=find(matches(cell_data_header,'fdr_dB'));
    cell_sim_data([2:end],col_header_fdr_dB_idx)=num2cell(temp_fdr);
    cell_sim_data([2:end],col_header_fdr_dB_idx)
else
    temp_fdr=0;
    col_header_fdr_dB_idx=find(matches(cell_data_header,'fdr_dB'));
    cell_sim_data([2:end],col_header_fdr_dB_idx)=num2cell(temp_fdr);
    cell_sim_data([2:end],col_header_fdr_dB_idx)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Filter CONUS
size(cell_sim_data)
[keep_idx]=filter_conus_cell_sim_data(app,tf_conus,cell_sim_data);
cell_sim_data=cell_sim_data(keep_idx,:);
size(cell_sim_data)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Set the I/N ratio
col_header_in_ratio_idx=find(matches(cell_sim_data(1,:),'in_ratio'));
cell_sim_data([2:end],col_header_in_ratio_idx)=num2cell(in_ratio); %%%I/N dB

col_header_mc_per_idx=find(matches(cell_sim_data(1,:),'mc_percentile'));
cell_sim_data([2:end],col_header_mc_per_idx)=num2cell(mc_percentile); %%%I/N dB

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Calculate the DPA Threshold
col_header_ant_gain_idx=find(matches(cell_sim_data(1,:),'rx_ant_gain_mb'));
col_header_rx_noise_temp_idx=find(matches(cell_sim_data(1,:),'Noise_TempK'));
col_header_rx_if_bw_idx=find(matches(cell_sim_data(1,:),'rx_if_bw_mhz'));
col_header_in_ratio_idx=find(matches(cell_sim_data(1,:),'in_ratio'));
col_header_x_pol_dB_idx=find(matches(cell_sim_data(1,:),'X_POL_dB'));
col_header_dpa_threshold_idx=find(matches(cell_sim_data(1,:),'dpa_threshold'));
col_header_fdr_dB_idx=find(matches(cell_sim_data(1,:),'fdr_dB'));
col_header_tf_cust_ant_idx=find(matches(cell_sim_data(1,:),'TF_Custom_Ant_Pattern'));
col_header_second_dpa_thres_idx=find(matches(cell_sim_data(1,:),'dpa_second_threshold'));
col_header_second_in_ratio_idx=find(matches(cell_sim_data(1,:),'second_in_ratio'));

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
        dpa_threshold=-138.7+10*log10(rx_bw_mhz)+10*log10(rx_temp_k)+in_ratio+x_pol_dB+fdr_dB;
        if isnan(dpa_threshold)
            'NaN Error: dpa_threshold'
            pause;
        end
        cell_sim_data{base_idx,col_header_dpa_threshold_idx}=dpa_threshold;
    else
        'Add the normal dpa threshold calculation'
        pause;
    end

        %%%%%%%Calcualte the DPA Threshold
        second_in_ratio=cell_sim_data{base_idx,col_header_second_in_ratio_idx};
        if ~isempty(second_in_ratio)
            if tf_cust_ant==1
                dpa_threshold=-138.7+10*log10(rx_bw_mhz)+10*log10(rx_temp_k)+second_in_ratio+x_pol_dB+fdr_dB;
                if isnan(dpa_threshold)
                    'NaN Error: dpa_threshold'
                    pause;
                end
                cell_sim_data{base_idx,col_header_second_dpa_thres_idx}=dpa_threshold;
            else
                'Add the normal dpa threshold calculation'
                pause;
            end
        else
            'No second DPA threshold'
            %pause;
            cell_sim_data{base_idx,col_header_second_dpa_thres_idx}=NaN(1,1);
        end
end
toc;
cell_sim_data(1:2,:)'
size(cell_sim_data)
cell_sim_data(:,1)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if tf_3sector==1
    'Need to update with Hawaii'
    pause;
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
    tf_repull_rand=0%1%0%1%0
    excel_filename_rand='Rand_Table_RSU_HIAK.xlsx'
    mat_filename_str_rand=strcat('rand_real_2025_one_sector_idx_HIAK.mat')
    
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
rand_real_2025(:,6)=1; %%%%%We use this to indicate which norm_aas_zero_elevation_data to use.
base_station_latlonheight=rand_real_2025;  %%1)Lat, 2)Lon, 3)Height meters, 4)Azimuth 5)Idx 6)EIRP IDX 7)Clutter IDX, 1==Urban, 2==Suburban, 3==Rural
size(base_station_latlonheight)
urban_idx=find(base_station_latlonheight(:,3)==20);
suburban_idx=find(base_station_latlonheight(:,3)==25);
rural_idx=find(base_station_latlonheight(:,3)==35);
base_station_latlonheight(urban_idx,7)=1;
base_station_latlonheight(suburban_idx,7)=2;
base_station_latlonheight(rural_idx,7)=3;
unique(base_station_latlonheight(:,7))
base_station_latlonheight(1:10,:)
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
maine_exception=0%1;  %%%%%%Just leave this to 1--> Going crazy with setting this to 0
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
save('move_list_margin.mat','move_list_margin')
save('tf_full_turnoff.mat','tf_full_turnoff')
save('tf_test.mat','tf_test')
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
tf_print_excel=0%1%0%1


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
neighborhood_wrapper_rev23_ue_grid(app,rev_folder,parallel_flag,tf_server_status,workers,tf_recalculate,tf_rescrap_rev_data,tf_print_excel)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cell_sim_data'


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


