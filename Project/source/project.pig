register /home/bpotinen/pig-0.14.0/lib/piggybank.jar
physician = LOAD '/user/bpotinen/data/OPPR_ALL_DTL_GNRL_12192014.csv' USING org.apache.pig.piggybank.storage.CSVExcelStorage();
physician = foreach physician generate $12 as line1,$13 as line2,$14 as city,$15 as state,$48 as amount;
phy_rank = rank physician;
physician = filter phy_rank by (rank_physician >1);
physician_check_1 = foreach physician generate UPPER(line1) as line1,UPPER(line2) as line2 ,city,state,amount;
physician_check_2 = foreach physician_check_1 generate REPLACE(line1,'(\\s+ST$)','STREET') as line1,REPLACE(line2,'(\\s+ST$)','STREET') as line2,city,state,amount;
physician_check_3 = foreach physician_check_2 generate REPLACE(line1,'(\\s+ST\\.)','STREET') as line1,REPLACE(line2,'(\\s+ST\\.)','STREET') as line2,city,state,amount;
physician_check_4 = foreach physician_check_3 generate REPLACE(line1,'(\\s+ST\\s)','STREET') as line1,REPLACE(line2,'(\\s+ST\\s)','STREET') as line2,city,state,amount;
physician_check_5 = foreach physician_check_4 generate REPLACE(line1,'(\\s+BLVD\\.)','BOULEVARD') as line1,REPLACE(line2,'(\\s+BLVD\\.)','BOULEVARD') as line2,city,state,amount; 
physician_check_6 = foreach physician_check_5 generate REPLACE(line1,'(\\s+BLVD\\s)','BOULEVARD') as line1,REPLACE(line2,'(\\s+BLVD\\s)','BOULEVARD') as line2,city,state,amount; 
physician_check_7 = foreach physician_check_6 generate REPLACE(line1,'(\\s+BLVD$)','BOULEVARD') as line1,REPLACE(line2,'(\\s+BLVD$)','BOULEVARD') as line2,city,state,amount;
physician_check_8 = foreach physician_check_7 generate REPLACE(line1,'(\\s+STE\\s)','SUITE') as line1,REPLACE(line2,'(\\s+STE\\s)','SUITE') as line2,city,state,amount;
physician_check_9 = foreach physician_check_8 generate REPLACE(line1,'(\\s+STE$)','SUITE') as line1,REPLACE(line2,'(\\s+STE$)','SUITE') as line2,city,state,amount;
physician_check_10 = foreach physician_check_9 generate REPLACE(line1,'(\\s#\\s)','') as line1,REPLACE(line2,'(\\s#\\s)','') as line2,city,state,amount;
physician_check_11 = foreach physician_check_10 generate REPLACE(line1,'(\\sRD\\.)','ROAD') as line1,REPLACE(line2,'(\\sRD\\.)','ROAD') as line2,city,state,amount;
physician_check_12 = foreach physician_check_11 generate REPLACE(line1,'(\\sRD\\s)','ROAD') as line1,REPLACE(line2,'(\\sRD\\s)','ROAD') as line2,city,state,amount;
physician_check_13 = foreach physician_check_12 generate REPLACE(line1,'(\\sRD$)','ROAD') as line1,REPLACE(line2,'(\\sRD$)','ROAD') as line2,city,state,amount;
physician_check_14 = foreach physician_check_13 generate REPLACE(line1,'(\\s+APT\\s+)','APARTMENT') as line1,REPLACE(line2,'(\\s+APT\\s+)','APARTMENT') as line2,city,state,amount;
physician_check_14 = foreach physician_check_14 generate REPLACE(line1,'(\\s+)','') as line1,REPLACE(line2,'(\\s+)','') as line2,city,state,amount;
physician_check_15 = foreach physician_check_14 generate REPLACE(line1,'(\\s+)','') as line1,REPLACE(line2,'(\\s+)','') as line2,UPPER(city) as city ,UPPER(state) as state,amount;
physician_check_15 = foreach physician_check_15 generate REPLACE(line1,'[,]','') as line1,REPLACE(line2,'[,]','') as line2,city ,state,amount;
physician_check_15 = foreach physician_check_15 generate REPLACE(line1,'[-]','') as line1,REPLACE(line2,'[-]','') as line2,city ,state,amount;
physician_check_15 = foreach physician_check_15 generate REPLACE(line1,'[#]','') as line1,REPLACE(line2,'[#]','') as line2,city ,state,amount;
physician_check_16 = foreach physician_check_15 generate line1,line2,REPLACE(city,'(\\s+)','') as city ,UPPER(state) as state,amount;
physician_check_16 = foreach physician_check_16 generate line1,line2,city,state,(double)amount;
phy_grp = group physician_check_16 by (line1,line2,city,state);
phy_sum_data = foreach phy_grp generate FLATTEN(group) AS (line1,line2,city,state),SUM(physician_check_16.amount) as amount;
phy_sum_data_grp = GROUP phy_sum_data ALL;
phy_sum_data_grp_count = FOREACH phy_sum_data_grp  GENERATE COUNT(phy_sum_data);

data = LOAD '/user/bpotinen/data/Medicare-Physician-and-Other-Supplier-PUF-CY2012.txt' USING PigStorage('\t');
medicare = foreach data generate $7 as street1,$8 as street2,$9 as city,$11 as state,$16 as code,$17 as description,$23 as submitted;	
medicare = foreach medicare generate UPPER(street1) as street1 ,UPPER(street2) as street2,UPPER(city) as city,UPPER(state) as state,code,submitted;
medicare = filter medicare by (code == 93015);
medicare_check_1 = foreach medicare generate REPLACE(street1,'(\\s+ST$)','STREET') as street1,REPLACE(street2,'(\\s+ST$)','STREET') as street2,city,state,submitted;
medicare_check_2 = foreach medicare_check_1 generate REPLACE(street1,'(\\s+ST\\.)','STREET') as street1,REPLACE(street2,'(\\s+ST\\.)','STREET') as street2,city,state,submitted;
medicare_check_3 = foreach medicare_check_2 generate REPLACE(street1,'(\\s+ST\\s)','STREET') as street1,REPLACE(street2,'(\\s+ST\\s)','STREET') as street2,city,state,submitted;
medicare_check_4 = foreach medicare_check_3 generate REPLACE(street1,'(\\s+BLVD\\.)','BOULEVARD') as street1,REPLACE(street2,'(\\s+BLVD\\.)','BOULEVARD') as street2,city,state,submitted; 
medicare_check_5 = foreach medicare_check_4 generate REPLACE(street1,'(\\s+BLVD\\s)','BOULEVARD') as street1,REPLACE(street2,'(\\s+BLVD\\s)','BOULEVARD') as street2,city,state,submitted; 
medicare_check_6 = foreach medicare_check_5 generate REPLACE(street1,'(\\s+BLVD$)','BOULEVARD') as street1,REPLACE(street2,'(\\s+BLVD$)','BOULEVARD') as street2,city,state,submitted;
medicare_check_7 = foreach medicare_check_6 generate REPLACE(street1,'(\\s+STE\\s)','SUITE') as street1,REPLACE(street2,'(\\s+STE\\s)','SUITE') as street2,city,state,submitted;
medicare_check_8 = foreach medicare_check_7 generate REPLACE(street1,'(\\s+STE$)','SUITE') as street1,REPLACE(street2,'(\\s+STE$)','SUITE') as street2,city,state,submitted;
medicare_check_9 = foreach medicare_check_8 generate REPLACE(street1,'(\\s#\\s)','') as street1,REPLACE(street2,'(\\s#\\s)','') as street2,city,state,submitted;
medicare_check_10 = foreach medicare_check_9 generate REPLACE(street1,'(\\sRD\\.)','ROAD') as street1,REPLACE(street2,'(\\sRD\\.)','ROAD') as street2,city,state,submitted;
medicare_check_11 = foreach medicare_check_10 generate REPLACE(street1,'(\\sRD\\s)','ROAD') as street1,REPLACE(street2,'(\\sRD\\s)','ROAD') as street2,city,state,submitted;
medicare_check_12 = foreach medicare_check_11 generate REPLACE(street1,'(\\sRD$)','ROAD') as street1,REPLACE(street2,'(\\sRD$)','ROAD') as street2,city,state,submitted;
medicare_check_13 = foreach medicare_check_12 generate REPLACE(street1,'(\\s+APT\\s+)','APARTMENT') as street1,REPLACE(street2,'(\\s+APT\\s)','APARTMENT') as street2,city,state,submitted;
medicare_check_13 = foreach medicare_check_13 generate REPLACE(street1,'(\\s+)','') as street1,REPLACE(street2,'(\\s+)','') as street2,city,state,submitted;
medicare_check_14 = foreach medicare_check_13 generate REPLACE(street1,'(\\s+)','') as street1,REPLACE(street2,'(\\s+)','') as street2,UPPER(city) as city ,UPPER(state) as state,submitted;
medicare_check_14 = foreach medicare_check_14 generate REPLACE(street1,'[,]','') as street1,REPLACE(street2,'[,]','') as street2,UPPER(city) as city ,UPPER(state) as state,submitted;
medicare_check_14 = foreach medicare_check_14 generate REPLACE(street1,'[-]','') as street1,REPLACE(street2,'[-]','') as street2,UPPER(city) as city ,UPPER(state) as state,submitted;
medicare_check_14 = foreach medicare_check_14 generate REPLACE(street1,'[#]','') as street1,REPLACE(street2,'[#]','') as street2,UPPER(city) as city ,UPPER(state) as state,submitted;
medicare_check_15 = foreach medicare_check_14 generate street1,street2,REPLACE(city,'(\\s+)','') as city ,UPPER(state) as state,submitted;
medicare_check_15 = foreach medicare_check_15 generate street1,street2,city ,state,(double) submitted;
filtered_data_grp = group medicare_check_15 by (street1,street2,city,state);
filtered_data_grp_AVG = foreach filtered_data_grp generate FLATTEN(group) AS (street1,street2,city,state),AVG(medicare_check_15.submitted) as submitted;
filtered_data_grp_AVG_all = GROUP filtered_data_grp_AVG ALL;
filtered_data_grp_AVG_count = FOREACH filtered_data_grp_AVG_all  GENERATE COUNT(filtered_data_grp_AVG);



joined = join filtered_data_grp_AVG by (street1,street2,city,state), phy_sum_data by (line1,line2,city,state) ;

requried_data = foreach joined generate filtered_data_grp_AVG::street1,filtered_data_grp_AVG::street2,filtered_data_grp_AVG::city,filtered_data_grp_AVG::state,filtered_data_grp_AVG::submitted,phy_sum_data::amount;

graph_data = foreach requried_data generate filtered_data_grp_AVG::submitted,phy_sum_data::amount;

store filtered_data_grp_AVG into '/user/bpotinen/project_final/medicare_grouped_Data';
store filtered_data_grp_AVG_count into '/user/bpotinen/project/medicare_grouped_Data_count';
store phy_sum_data into '/user/bpotinen/project/physician_grouped_Data';
store phy_sum_data_grp_count into '/user/bpotinen/project/physician_grouped_Data_count';
store requried_data into '/user/bpotinen/project/joined_data';
store graph_data into '/user/bpotinen/project/graph_data';