data = LOAD '/user/bpotinen/data/Medicare-Physician-and-Other-Supplier-PUF-CY2012.txt' USING PigStorage('\t');
needed_data = foreach data generate $0 as id,$11 as state,$12 as country,$13 as provider,$16 as code,$23 as submitted;
ranked = rank needed_data;
raw_data = filter ranked by (rank_needed_data >2);
Ordered = Order raw_data by rank_needed_data;
code_data = filter Ordered by (code == 93015);
state_filter = filter code_data by (state != 'zz' or state != 'xx' or state != '');
VA_data = filter code_data by (state == 'VA');
VA_group_Data = group VA_data by provider;
state_group_data = group state_filter by state;
state_avg_data = foreach state_group_data generate
	group as state,
	AVG(state_filter.submitted) as cost;
store state_avg_data into '/user/bpotinen/ass3/grad_out';
Avg_data = foreach VA_group_Data generate
	COUNT (VA_data) as Records,
	group as provider,
	AVG(VA_data.submitted) as cost;
store Avg_data into '/user/bpotinen/ass3/ug_out';
