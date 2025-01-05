use case_study;

select * from balls;
select * from matches;
select * from matches2;

-- 1) Top 5 batsman in given season
	
		select batter,sum(batsman_run) as "total_runs"from balls b
        join matches m on b.id=m.id 
        where m.season=2016
        group by batter order by total_runs desc limit 5;
		
-- 2) Top 5 bowler(wicket Taken) in given season

		select bowler,sum(isWicketDelivery) "Most_Wicket" from balls b
        join matches m on b.id=m.id 
        where m.season=2016 and kind != 'run out'
        group by bowler order by Most_wicket desc limit 5;
        
-- 3) Bowlers with most five wicket hauls in Indian Premier League

		select bowler,count(f_Hauls) as "NO_5_Hauls" from 
					(select id,bowler,sum(isWicketDelivery) as "f_Hauls" 
					from balls
					where kind !="run out"
					group by id,bowler having sum(isWicketDelivery)>=5) hauls
		group by bowler order by NO_5_Hauls desc ;
    
-- 4) Top 5 team score
		
        select total_runs,battingteam,season from 
					(select id,battingteam,sum(total_run)  as "Total_runs" from balls
					group by id,battingteam ) t
		join matches m on t.id = m.id order by t.Total_runs desc limit 5;
	
 -- 5) Top 5 individual score
	
		select total_runs,batter,season from 
					(select id,batter,sum(batsman_run)  as "Total_runs" from balls
					group by id,batter) t
		join matches m on t.id = m.id order by t.Total_runs desc limit 5;
		
-- 6) Players with most centuries in Indian Premier League
		
        select batter , count(total) as "Centuries" from 
										(select id,batter,sum(batsman_run) as "Total" 
                                        from balls 
                                        group by id,batter having sum(batsman_run)>=100)t
		group by batter order by Centuries desc;
        
-- 7) Number of Most half centuries 
	
		select batter , count(total) as "Centuries" from 
										(select id,batter,sum(batsman_run) as "Total" 
                                        from balls 
                                        group by id,batter having sum(batsman_run) between 50 and 99)t
		group by batter order by Centuries desc;
		
-- 8) Number of centuries of given batter

		select count(total) as "Centuries" from 
										(select id,sum(batsman_run) as "Total" 
                                        from balls where batter = 'JC Buttler'
                                        group by id having sum(batsman_run)>=100)t;
                                        
                                        
-- 9) specific batsman vs given bowler

		select bowler,sum(batsman_run) as  "runs" from balls where batter = "v kohli" group by bowler order by runs desc;
        
-- 10) top 5 run scorer of each teams

		with ranks as (
						select*, 
						rank() over (partition by battingteam order by total_runs desc) as "ranking"
						from 
							(select batter,battingteam,sum(batsman_run) as "total_runs" 
							from balls 
							group by batter,battingteam)t)
		select * from ranks where ranking<=5;
        

		
-- 11) innings taken by given batter to complete given total run

			select distinct inning, inning_runs from (select id,sum(batsman_run) over (rows between unbounded preceding and current row) as "inning_runs",
						dense_rank() over (order by id desc) as "inning"
							from balls where batter = "V Kohli"  order by  inning_runs) t where inning_runs between 5003 and 5009;
			
        
 -- 12) Players with most sixes in Indian Premier League
		
        select batter,count(batsman_run) as "sixes" from balls  where batsman_run = 6 group by batter order by sixes desc;

        
-- 13) Batsman dismissed by Harbhajan most time in IPL

		select batter,count(iswicketdelivery) "wicket" from balls where bowler like "%Harbhajan singh%" and iswicketdelivery!="run out" group by batter order by wicket desc ;
        
-- 14) Stadium wise matches hosted in IPL

		select distinct venue_name,home_team from matches2;
        
-- 15) Team , Season wise boundaries in IPL

		select battingteam,season,count(batsman_run) as "boundry" from balls b
        join matches m on b.id=m.id where batsman_run in(4,6) group by battingteam,season;
        
-- 16) Players who has taken most catches in IPL

		select fielders_involved,count(fielders_involved) "fielder" 
        from balls 
        where fielders_involved is not null and kind = "caught" 
        group by fielders_involved order by fielder desc;

-- 17) Players with most man-of-the-matches in IPL

		select player_of_match,count(player_of_match) as "mvp" from matches group by  player_of_match order by mvp desc;
        
-- 18) Orange Cap/Purple cap holders season wise in IPL
		
        select season,batter as "Orange cap holder",runs from 
			(select season,batter,sum(batsman_run) as "runs" ,
					rank() over(partition by season order by sum(batsman_run) desc) as "top_runs"
			from balls b
			join matches m on b.id = m.id 
			group by season,batter) t
         where top_runs=1;
         
			select season,bowler as "Purple cap holder" , wicket from 
					(select season,bowler,count(iswicketdelivery) as "wicket",
							rank() over(partition by season order by count(iswicketdelivery) desc) as "top_wicket"
					from balls  b
					join matches m on b.id = m.id 
					where iswicketdelivery!="run out"
					group by season,bowler)t 
			where top_wicket=1;
        
-- 19) Number of 200+ per team

			select battingteam,count(runs) as "n_200" from (select id,battingteam,sum(total_run) as "runs" from balls group by id,battingteam having sum(total_run)>=200) t
            group by battingteam
            order by n_200 desc;
            
-- 20) Strike rate of specific batsman in specific over_type(power_play,middle_overs,death_overs)

	with powerplay as
						(select distinct sum(batsman_run) over ()/count(ballnumber) over ()*100 as "1_to_6"
									from  balls 
                                    where batter = "V KOHLI" AND overs between 0 and 5 ),
		middleover as 	(select distinct sum(batsman_run) over ()/count(ballnumber) over ()*100 as "7_to_15"
									from  balls 
                                    where batter = "V KOHLI" AND overs between 6 and 14),
		deathover as 	(select distinct sum(batsman_run) over ()/count(ballnumber) over ()*100 as "16_to_20"
									from  balls 
									where batter = "V KOHLI" AND overs between 15 and 19)
	select *
	from  powerplay p
    join middleover m
    join deathover d;

			
-- 21) Highest/Lowest scores of each season by wich team
			
		select * from 
					(select distinct season,
							case when
									runs=max(runs) over (partition by t.season) then battingteam 
							end as "team",        
									max(runs) over (partition by t.season) as "max_run" 
					from 
						 (select b.id,b.battingteam,season,sum(total_run)  as "runs" from balls b
						  join matches m on b.id=m.id
						  group by id,battingteam,season)t
					)t2
				where t2.team is not null;
                
			
            select * from 
					(select distinct season,
							case when
									runs=min(runs) over (partition by t.season) then battingteam 
							end as "team",        
									min(runs) over (partition by t.season) as "min_run" 
					from 
						 (select b.id,b.battingteam,season,sum(total_run)  as "runs" from balls b
						  join matches m on b.id=m.id
						  group by id,battingteam,season)t
					)t2
				where t2.team is not null;
				
-- 22) Highest run scorer and highest wicket taker team of each season
		
		 select * from 
				(select season,
						case when 
								rank() over w then battingteam end,
						total_runs,
								rank() over w as "ranking"
				from 
					(select season,battingteam,sum(batsman_run) as "total_runs" from balls b
					join matches m on m.id=b.id
					group by season,b.battingteam)t 
				window w as (partition by season order by total_runs desc))t2 
        where ranking=1;
        
        
-- 23) In which overs given bowler takes most wicktes

		select overs,sum(iswicketdelivery) as "wicket"from balls
        where bowler = 'YS CHAHAL'
        group by overs
        order by wicket desc;
        
-- 24) How toss win impacts the match win (which team utilized the toss win most)
	
			select count(*)/(select count(*) as "total" from matches) * 100 as "percent" from matches
            where tosswinner=winningteam;
-- 25) Which Player has played for most number of Teams in IPL

		select * from matches where FIND_IN_SET('V Kohli',Team2Players);
        select * from matches where JSON_SEARCH(your_column, 'V Kohli') IS NOT NULL;
        
        select * from matches where Team2players like "%V k";
        ;

-- 26) Most matches captained by players
		
      with cap  as 
				(select home_captain,count(id) as "captaion"from matches2
				group by home_captain
								union
				select away_captain,count(id) as "captaion"from matches2
				group by away_captain)
        
        select home_captain as "captain",sum(captaion) as "matches" from cap group by home_captain order by matches desc;
        
-- 27) Players involved in most IPL final

-- 28) Most matches played by team on sunday

		with sun as (
			select team1,count(id) as "cot" from matches where dayname(date)="Sunday"group by team1
            union
            select team2,count(id) from matches where dayname(date)="Sunday"group by team2)
		select team1 as "team",sum(cot) as "matches" from sun 
        group by team1 order by matches desc;
        
-- 29) On which day virat kohli scored century

	select * from (select distinct m.id,dayname(date) as "day ",sum(batsman_run) over( partition by m.id) AS "RUN" from matches m
    join balls b on m.id=b.id
    where batter = "V Kohli") t where run >=100;
    

    
            