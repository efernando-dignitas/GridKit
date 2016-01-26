begin;
drop table if exists shared_nodes;
create table shared_nodes (
    node_id bigint,
    way_id  text[],
    power_type char(1) array,
    path_idx float array,
    primary key (node_id)
);
insert into shared_nodes (node_id, way_id, power_type, path_idx)
    select node_id, array_agg(way_id order by way_id), 
        array_agg(power_type order by way_id), 
        array_agg(path_idx order by way_id) from (
        select concat('w',id) as way_id, unnest(nodes) as node_id,  power_type, 
            (generate_subscripts(nodes, 1)::float - 1.0)/(array_length(nodes, 1)-1) as path_idx
            from planet_osm_ways join power_type_names on power_name = hstore(tags)->'power'
    ) f group by node_id having count(*) > 1;
commit;