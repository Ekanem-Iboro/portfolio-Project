SELECT * FROM portfolio.covidsdeaths
order by 3,4;


-- select data that we are going to be using

SELECT location,date, total_cases,new_cases,total_deaths,population
 FROM portfolio.covidsdeaths
order by 1,2;

-- looking at the total cases vs total deaths
SELECT location,date, total_cases,total_deaths,
 (total_deaths/total_cases) * 100 as Total_Death_Percentage
 FROM portfolio.covidsdeaths
  where location like '%Nigeria%'
order by 1,2;

-- looking at the total cases vs population
SELECT location,date, total_cases,population,
 (total_cases/population) * 100 as Total_Death_Percentage
 FROM portfolio.covidsdeaths
--   where location like '%Nigeria%'
order by 1,2;

-- looking at the country with the heighest  infection rate compared to population
SELECT location,population,max(total_cases) maxTotalCases,
 max((total_cases/population)) * 100 as Max_Total_Death_Percentage
 FROM portfolio.covidsdeaths
--   where location like '%Nigeria%'
group by population, location
order by Max_Total_Death_Percentage desc;

-- how many people died in a country (with highest death count)
SELECT location, max(cast(total_deaths as signed)) maxTotalDeaths
 FROM portfolio.covidsdeaths
--   where location like '%Nigeria%'
group by population, location
order by maxTotalDeaths desc; 

-- lets break things down by continents
SELECT continent, max(cast(total_deaths as signed)) maxTotalDeaths
 FROM portfolio.covidsdeaths
group by continent
order by maxTotalDeaths desc;

-- showing the continent with the higest death count
SELECT continent, max(cast(total_deaths as signed)) maxTotalDeaths
 FROM portfolio.covidsdeaths
group by continent
order by maxTotalDeaths desc; 


-- global number
SELECT  sum(new_cases) , sum(new_deaths), sum(new_deaths)/sum(new_cases)* 100 as Total_Death_Percentage
 FROM portfolio.covidsdeaths
 where continent is not null
--  group by date
 order by date;
 
 
 -- combining the tables
  SELECT * 
   FROM portfolio.covidsdeaths dea
  join portfolio.covidvaccination vac
on dea.location = vac.location and dea.date = vac.date;

-- looking at total population and total vaccination
  SELECT dea.continent, dea.location,dea.population, vac.new_vaccinations,
  sum(vac.new_vaccinations) over (partition by dea.location 
  order by dea.location ,dea.date) PeopleVacination
   FROM portfolio.covidsdeaths dea
  join portfolio.covidvaccination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- using cte
with popVSvac (Continent, Location,Date, population, New_vaccinations,PeopleVacination) as
(
SELECT dea.continent,dea.date, dea.location,dea.population, vac.new_vaccinations,
  sum(vac.new_vaccinations) over (partition by dea.location 
  order by dea.location ,dea.date) PeopleVacination
   FROM portfolio.covidsdeaths dea
  join portfolio.covidvaccination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)
select *, (PeopleVacination / population) * 100 totalVaccinated from popVSvac;

-- temp table
drop table if exists PercentagepopulationVaccinated;
CREATE TEMPORARY TABLE PercentagepopulationVaccinated
(Continent varchar(255), 
Location  varchar(255),
Date text,
 population  text,
 New_vaccinations text,
 PeopleVacination text
 );  
 
 insert into PercentagepopulationVaccinated 
 SELECT dea.continent,dea.date, dea.location,dea.population, vac.new_vaccinations,
  sum(vac.new_vaccinations) over (partition by dea.location 
  order by dea.location ,dea.date) PeopleVacination
   FROM portfolio.covidsdeaths dea
  join portfolio.covidvaccination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null;

select *, (PeopleVacination / population) * 
100 totalVaccinated from PercentagepopulationVaccinated;


-- view creation to store data for later 

create view PercentagepopulationVaccinated as
SELECT dea.continent,dea.date, dea.location,dea.population, vac.new_vaccinations,
  sum(vac.new_vaccinations) over (partition by dea.location 
  order by dea.location ,dea.date) PeopleVacination
   FROM portfolio.covidsdeaths dea
  join portfolio.covidvaccination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null;

select * from PercentagepopulationVaccinated;