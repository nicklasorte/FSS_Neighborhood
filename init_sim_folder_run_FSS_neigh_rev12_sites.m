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

tf_repull_fss=0%1
data_num=4%3%
cell_data_filename=strcat('cell_FSS_sim_data',num2str(data_num),'.mat');
[var_exist]=persistent_var_exist_with_corruption(app,cell_data_filename);
if tf_repull_fss==1
    var_exist=0;
end
if var_exist==2
    load(cell_data_filename,'cell_sim_data')
else

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    cell_data_header=cell(1,33);
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


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Load Loacations
    tf_pull_excel=1
    excel_filename_fss='CUI Priority FSS DON CIO_20260121.xlsx'
    data_fss_num=1
    mat_filename_fss=strcat('cell_fss_navy_',num2str(data_fss_num),'.mat');
    tic;
    [cell_fss_data_navy]=load_full_excel_rev1(app,mat_filename_fss,excel_filename_fss,tf_pull_excel);
    toc;
    data_header_navy=cell_fss_data_navy(1,:)';

    col_sat_lon_idx=find(matches(data_header_navy,'Satellite Longitude'));
    array_uni_lon=unique(cell2mat(cell_fss_data_navy([2:end],col_sat_lon_idx)))
    % -135
    % -52
    % -30
    % 150
    % 175

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%WGS F1 (USA 195): -42.53 (Longitude): NORAD ID: 32258
    %%%WGS F5 (USA 243): -52.51 (Longitude): NORAD ID: 39168
    %%%WGS F6 (USA 244): -135.19 (Longitude): NORAD ID: 39222
    tf_pull_tle_excel=1
    excel_filename_tle='WGS Sat Names 1-23-2026.xlsx'
    data_tle_num=1
    mat_filename_tle=strcat('cell_tle_',num2str(data_tle_num),'.mat');
    tic;
    [cell_tle_data]=load_full_excel_rev1(app,mat_filename_tle,excel_filename_tle,tf_pull_tle_excel);
    toc;
    data_header_tle=cell_tle_data(1,:)'
    col_tle_lon_idx=find(matches(data_header_tle,'Longitude'));
    array_tle_long=cell2mat(cell_tle_data([2:end],col_tle_lon_idx))
    col_sat_name_idx=find(matches(data_header_tle,'Satellite Name'));
    cell_tle_sat_name=cell_tle_data([2:end],col_sat_name_idx)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%Stitch the data together.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    col_header_label_idx=find(matches(cell_data_header,'data_label1'));
    col_header_lat_idx=find(matches(cell_data_header,'latitude'));
    col_header_lon_idx=find(matches(cell_data_header,'longitude'));
    col_header_rx_height_idx=find(matches(cell_data_header,'rx_height'));
    col_header_base_ppts_idx=find(matches(cell_data_header,'base_protection_pts'));
    col_header_base_poly_idx=find(matches(cell_data_header,'base_polygon'));
    col_header_ant_bm_idx=find(matches(cell_data_header,'ant_hor_beamwidth'));
    col_header_min_azi_idx=find(matches(cell_data_header,'min_azimuth'));
    col_header_max_azi_idx=find(matches(cell_data_header,'max_azimuth'));
    col_header_ant_gain_idx=find(matches(cell_data_header,'rx_ant_gain_mb'));
    col_header_ant_dia_idx=find(matches(cell_data_header,'ant_diamter_m'));
    col_header_rx_noise_temp_idx=find(matches(cell_data_header,'Noise_TempK'));
    col_header_rx_if_bw_idx=find(matches(cell_data_header,'rx_if_bw_mhz'));
    col_header_sat_id_idx=find(matches(cell_data_header,'Sat_ID'));
    col_header_ant_pat_str_idx=find(matches(cell_data_header,'Antenna_Pattern_Str'));
    col_header_tf_cust_ant_idx=find(matches(cell_data_header,'TF_Custom_Ant_Pattern'));
    col_header_x_pol_dB_idx=find(matches(cell_data_header,'X_POL_dB'));
    col_header_in_ratio_idx=find(matches(cell_data_header,'in_ratio'));
    col_header_fdr_dB_idx=find(matches(cell_data_header,'fdr_dB'));
    col_header_tf_ant_idx=find(matches(cell_data_header,'tf_ant_square'));
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    col_data_sat_lon_idx=find(matches(data_header_navy,'Satellite Longitude'));
    col_data_city_idx=find(matches(data_header_navy,'City'));
    col_data_lat_idx=find(matches(data_header_navy,'ES Antenna Latitude'));
    col_data_lon_idx=find(matches(data_header_navy,'ES Antenna Longitude'));
    col_data_ant_dia_idx=find(matches(data_header_navy,'Antenna Diameter(m)'));
    col_data_ant_gain_idx=find(matches(data_header_navy,'Maximum Antenna Gain (dBi)'));
    col_data_ant_height_idx=find(matches(data_header_navy,'Antenna Heigh Above Ground (m)'));
    col_data_ant_bm_idx=find(matches(data_header_navy,'Approx Antenna 3dB Beamwidth  (deg)'));
    col_data_noise_temp_idx=find(matches(data_header_navy,'Noise Temperature (K)'));
    col_data_if_bw_idx=find(matches(data_header_navy,'IF Bandwidth(MHz)'));
    col_data_agency_idx=find(matches(data_header_navy,'Operated by'));


    [num_locations,~]=size(cell_fss_data_navy);
    table([1:num_locations]',cell_fss_data_navy(:,1))
    tic;
    cell_compiled_data=cell(num_locations,33);

    cell_compiled_data(:,col_header_min_azi_idx)=num2cell(0); %%%Double Zero should keep it fixed (Non-rotating)
    cell_compiled_data(:,col_header_max_azi_idx)=num2cell(0); %%%Double Zero should keep it fixed (Non-rotating)
    cell_itu_ant8=cell(1,1);
    cell_itu_ant8{1,1}='itu_antenna_appendix8_annex3';
    cell_compiled_data(:,col_header_ant_pat_str_idx)=cell_itu_ant8;
    cell_compiled_data(:,col_header_tf_cust_ant_idx)=num2cell(1);
    cell_compiled_data(:,col_header_x_pol_dB_idx)=num2cell(3); %%%%x_pol_dB 3dB
    %%%cell_compiled_data(:,col_header_in_ratio_idx)=num2cell(-6); %%%I/N dB
    cell_compiled_data(:,col_header_fdr_dB_idx)=num2cell(0); %%%FDR dB
    cell_compiled_data(:,col_header_tf_ant_idx)=num2cell(0);    %tf_ant_square=0 %%%%%%%Instead of the trapezoid method used in CBRS
 
    for base_idx=2:1:num_locations
        temp_single_cell_sim_data=cell_fss_data_navy(base_idx,:);
        data_label1=strcat(temp_single_cell_sim_data{col_data_city_idx},'_',temp_single_cell_sim_data{col_data_agency_idx});
        %%%%%%%%Insert Agency Name
        data_label1=data_label1(find(~isspace(data_label1)));  %%%%%%%%%%Remove the White Spaces
        cell_compiled_data{base_idx,col_header_label_idx}=data_label1;

        %%%%%%%%%%Lat/Lon/Height
        temp_lat=temp_single_cell_sim_data{col_data_lat_idx};
        temp_lon=temp_single_cell_sim_data{col_data_lon_idx};
        cell_compiled_data{base_idx,col_header_lat_idx}=temp_lat;
        cell_compiled_data{base_idx,col_header_lon_idx}=temp_lon;
        temp_ant_height=temp_single_cell_sim_data{col_data_ant_height_idx};
        cell_compiled_data{base_idx,col_header_rx_height_idx}=temp_ant_height;
        cell_compiled_data{base_idx,col_header_base_ppts_idx}=horzcat(cell_compiled_data{base_idx,col_header_lat_idx},cell_compiled_data{base_idx,col_header_lon_idx},cell_compiled_data{base_idx,col_header_rx_height_idx});
        cell_compiled_data{base_idx,col_header_base_poly_idx}=horzcat(cell_compiled_data{base_idx,col_header_lat_idx},cell_compiled_data{base_idx,col_header_lon_idx});

        %%%%%%%Antenna Beamwidth
        temp_ant_beam=temp_single_cell_sim_data{col_data_ant_bm_idx};
        cell_compiled_data{base_idx,col_header_ant_bm_idx}=temp_ant_beam;

        %%%%%Antenna Gain
        temp_ant_gain=temp_single_cell_sim_data{col_data_ant_gain_idx};
        cell_compiled_data{base_idx,col_header_ant_gain_idx}=temp_ant_gain;

        %%%%%Antenna Diameter
        temp_ant_diameter=temp_single_cell_sim_data{col_data_ant_dia_idx};
        cell_compiled_data{base_idx,col_header_ant_dia_idx}=temp_ant_diameter;

        %%%%%%%Noise Temp K
        temp_noise_tempK=temp_single_cell_sim_data{col_data_noise_temp_idx};
        cell_compiled_data{base_idx,col_header_rx_noise_temp_idx}=temp_noise_tempK;

        %%%%%%%%%%%Receiver IF Bandwidth MHz
        temp_rx_if_bw=temp_single_cell_sim_data{col_data_if_bw_idx};
        if temp_rx_if_bw>50
            temp_rx_if_bw=50;
        end
         cell_compiled_data{base_idx,col_header_rx_if_bw_idx}=temp_rx_if_bw;

        %%%%%%%%%%%%%%%%Satellite Name
        %%%%%First get the longitude
        temp_sat_lon=temp_single_cell_sim_data{col_data_sat_lon_idx};

        %%%%%%%%%%Find the NN
        nn_idx=nearestpoint_app(app,temp_sat_lon,array_tle_long);

        %%%%%%Delta check
        delta_lon=abs(diff(horzcat(temp_sat_lon,array_tle_long(nn_idx))));
        if delta_lon>2
            'Might not be the right Satellite Longitude'
            %pause;
        end
        cell_compiled_data{base_idx,col_header_sat_id_idx}=cell_tle_sat_name{nn_idx};
    end
    cell_compiled_data=cell_compiled_data(~cellfun('isempty',cell_compiled_data(:,1)),:);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Calculate the Satellite Azimuth/Elevation
    str_tle_filename=strcat('full_geo.tle');
    str_website='http://www.celestrak.com/NORAD/elements/geo.txt'

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Pull the TLE Needed
    tic;
    outfilename=websave(str_tle_filename,str_website);
    toc;
    tleStruct=tleread(str_tle_filename);
    cell_tle=struct2cell(tleStruct);
    cell_tle_names=cellfun(@char, cell_tle(1,:), 'UniformOutput', false)';
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    col_header_ele_idx=find(matches(cell_data_header,'Ground_Elevation_m'));
    col_header_gs_azimuth_idx=find(matches(cell_data_header,'gs_azimuth'));
    col_header_gs_elevation_idx=find(matches(cell_data_header,'gs_elevation'));

    [num_rows2,~]=size(cell_compiled_data);
    tic;
    for base_idx=1:1:num_rows2
        str_sat_name=cell_compiled_data{base_idx,col_header_sat_id_idx};
        temp_base_pts=cell_compiled_data{base_idx,col_header_base_ppts_idx};

        %%%%%%%%%%%%TLE Pull
        % % sat_row_idx=find(contains(cell_tle_names,'USA 272'))
        % % cell_tle_names{sat_row_idx}
        sat_row_idx=find(contains(cell_tle_names,str_sat_name));
        if isempty(sat_row_idx)
            'Satellite TLE not found'
            pause;
        end
        single_tle=tleStruct(sat_row_idx);

        %%%%%%%%Pull in the RX (FSS) elevation
        [num_pp_pts,~]=size(temp_base_pts);
        if num_pp_pts>1
            'Need to generalize for more than 1 point'
            pause;
        end

        lat_pt=temp_base_pts(:,1);
        lon_pt=temp_base_pts(:,2);
        [elevation_m]=elevation_usgs_rev1(app,lat_pt,lon_pt);
        cell_compiled_data{base_idx,col_header_ele_idx}=elevation_m;

        %%%%%%%%%%%%%%%Set up the satellite Scenario
        sampleTime=60;
        startTime=datetime('now');
        stopTime=startTime+seconds(sampleTime);
        time=startTime:seconds(sampleTime):stopTime;
        satscene=satelliteScenario(startTime,stopTime,sampleTime);
        sat_position=propagateOrbit(datetime(time),single_tle);
        positionTT=timetable(time',sat_position');
        constellation=satellite(satscene,positionTT);
        %%%%%%%%%%%%%%%%%%Create the ground stations
        temp_altitude=elevation_m+temp_base_pts(:,3);
        earth_ground_stat=groundStation(satscene,lat_pt,lon_pt,'Altitude',temp_altitude);
        %%%%%%%%%%%%%%%Calculate the azimuth and elevation from the Earth to the Satellite
        [gs_azimuth,gs_elevation,gs_range]=aer(earth_ground_stat,constellation,stopTime);
        cell_compiled_data{base_idx,col_header_gs_azimuth_idx}=gs_azimuth;
        cell_compiled_data{base_idx,col_header_gs_elevation_idx}=gs_elevation;
        strcat(num2str(base_idx/num_locations*100),'%')
        toc;
    end
    toc;

    cell_sim_data=vertcat(cell_data_header,cell_compiled_data);
    tic;
    save(cell_data_filename,'cell_sim_data')
    toc;
end
cell_sim_data(1:2,:)'





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%This where you set the inputs for the simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rev=126; %%%%%Navy Sites: 50th percentile with Azimuth and looking at Urban Area Impact
% in_ratio=-6;%%%%dB
% freq_separation=0; %%%%%%%Assuming co-channel
% bs_eirp=50.5;%%%% %%%%%EIRP [dBm/10MHz] for Rural, Suburan, Urban: 62dBm/1MHz --> 36.25dBm/MHz at 50th (0,0), then - 1.25 for 80% TDD, 35dBm/Mhz --> 45dBm/10MHz
% mitigation_dB=0;%:10:30;  %%%%%%%%% in dB%%%%% Beam Muting or PRB Blanking (or any other mitigation mechanism):  30 dB reduction %%%%%%%%%%%%Consider have this be an array, 3dB step size, to get a more granular insight into how each 3dB mitigation reduces the coordination zone.
% mc_size=1;%%%% Since we're at 50%
% tf_full_binary_search=1;  %%%%%Search all DPA Points, not just the max distance point
% min_binaray_spacing=1;%4%8; %%%%%%%minimum search distance (km)
% reliability=50;%%%% [1,2,3,4,5,6,7,8,9,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,91,92,93,94,95,96,97,98,99]'; %%%A custom ITM range to interpolate from
% move_list_reliability=reliability;
% agg_check_reliability=reliability;
% FreqMHz=7250;
% confidence=50;
% mc_percentile=100;%80%%%100;% since we're at 1 MC sim
% sim_radius_km=128;%128%256%512; %%%%%%%%Placeholder distance         binary_dist_array=[2,4,8,16,32,64,128,256,512,1024,2048];
% tf_clutter=0;%1%;  %%%%%%%????, Just do this in the EIRP reductions
% sim_folder1='Z:\Matlab2025 Sims\7GHz FSS Neighborhood'  %%%%%%%%%%'C:\Local Matlab Data\7GHz FSS Neighborhood Test Sims'
% tf_opt=1; %%%%This is for the optimized move list, (not WinnForum)
% tf_3sector=0;  %%%%%Else 1 Sector
% tf_conus=1; %%%%%%Keep locations just within CONUS
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rev=127; %%%%%App Test
% cell_sim_data=cell_sim_data([1,2],:);
% in_ratio=-6;%%%%dB
% freq_separation=0; %%%%%%%Assuming co-channel
% bs_eirp=50.5;%%%% %%%%%EIRP [dBm/10MHz] for Rural, Suburan, Urban: 62dBm/1MHz --> 36.25dBm/MHz at 50th (0,0), then - 1.25 for 80% TDD, 35dBm/Mhz --> 45dBm/10MHz
% mitigation_dB=0;%:10:30;  %%%%%%%%% in dB%%%%% Beam Muting or PRB Blanking (or any other mitigation mechanism):  30 dB reduction %%%%%%%%%%%%Consider have this be an array, 3dB step size, to get a more granular insight into how each 3dB mitigation reduces the coordination zone.
% mc_size=1;%%%% Since we're at 50%
% tf_full_binary_search=1;  %%%%%Search all DPA Points, not just the max distance point
% min_binaray_spacing=1;%4%8; %%%%%%%minimum search distance (km)
% reliability=50;%%%% [1,2,3,4,5,6,7,8,9,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,91,92,93,94,95,96,97,98,99]'; %%%A custom ITM range to interpolate from
% move_list_reliability=reliability;
% agg_check_reliability=reliability;
% FreqMHz=7250;
% confidence=50;
% mc_percentile=100;%80%%%100;% since we're at 1 MC sim
% sim_radius_km=128;%128%256%512; %%%%%%%%Placeholder distance         binary_dist_array=[2,4,8,16,32,64,128,256,512,1024,2048];
% tf_clutter=0;%1%;  %%%%%%%????, Just do this in the EIRP reductions
% sim_folder1='C:\Local Matlab Data\7GHz FSS Neighborhood Test Sims' %%%%%%%'Z:\Matlab2025 Sims\7GHz FSS Neighborhood'  %%%%%%%%%%
% tf_opt=1; %%%%This is for the optimized move list, (not WinnForum)
% tf_3sector=0;  %%%%%Else 1 Sector
% tf_conus=1; %%%%%%Keep locations just within CONUS
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rev=128; %%%%%Navy Sites: 50th percentile with Azimuth and looking at Urban Area Impact, change the IF RX BW to max 50mhz
in_ratio=-6;%%%%dB
freq_separation=0; %%%%%%%Assuming co-channel
bs_eirp=50.5;%%%% %%%%%EIRP [dBm/10MHz] for Rural, Suburan, Urban: 62dBm/1MHz --> 36.25dBm/MHz at 50th (0,0), then - 1.25 for 80% TDD, 35dBm/Mhz --> 45dBm/10MHz
mitigation_dB=0;%:10:30;  %%%%%%%%% in dB%%%%% Beam Muting or PRB Blanking (or any other mitigation mechanism):  30 dB reduction %%%%%%%%%%%%Consider have this be an array, 3dB step size, to get a more granular insight into how each 3dB mitigation reduces the coordination zone.
mc_size=1;%%%% Since we're at 50%
tf_full_binary_search=1;  %%%%%Search all DPA Points, not just the max distance point
min_binaray_spacing=1;%4%8; %%%%%%%minimum search distance (km)
reliability=50;%%%% [1,2,3,4,5,6,7,8,9,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,91,92,93,94,95,96,97,98,99]'; %%%A custom ITM range to interpolate from
move_list_reliability=reliability;
agg_check_reliability=reliability;
FreqMHz=7250;
confidence=50;
mc_percentile=100;%80%%%100;% since we're at 1 MC sim
sim_radius_km=128;%128%256%512; %%%%%%%%Placeholder distance         binary_dist_array=[2,4,8,16,32,64,128,256,512,1024,2048];
tf_clutter=0;%1%;  %%%%%%%????, Just do this in the EIRP reductions
sim_folder1='Z:\Matlab2025 Sims\7GHz FSS Neighborhood'  %%%%%%%%%%'C:\Local Matlab Data\7GHz FSS Neighborhood Test Sims'
tf_opt=1; %%%%This is for the optimized move list, (not WinnForum)
tf_3sector=0;  %%%%%Else 1 Sector
tf_conus=1; %%%%%%Keep locations just within CONUS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




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
        dpa_threshold=-138.7+10*log10(rx_bw_mhz)+10*log10(rx_temp_k)+in_ratio+x_pol_dB+fdr_dB;
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
    aas_zero_elevation_data=zeros(361,4);
    aas_zero_elevation_data(:,1)=-180:1:180;
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maine_exception=1;  %%%%%%Just leave this to 1
Tpol=1; %%%polarization for ITM
deployment_percentage=100; %%%%%%%%%%%Let's not change this.
margin=1;%%dB margin for aggregate interference
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
%neighborhood_wrapper_rev11_bs_azi_idx_ua2023(app,rev_folder,parallel_flag,tf_server_status,workers,tf_recalculate,tf_rescrap_rev_data,tf_print_excel)
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
cd(folder1)
'Done'


