----Part One: work on One table, calculate, function and General Commands ...-----


--select the Data that we are going to using 

select * 
from portfolioProject.dbo.coviddeaths
where continent is not null
order by 3,4
--select * 
--from portfolioProject.dbo.covidvaccination
--order by 3,4


--Looking at Total cases vs Total deaths:

select country,date,total_cases,new_cases,total_deaths,population 
from portfolioProject.dbo.coviddeaths
order by 1,2

--Show the percentage of death if you contact with covid in your country:

select country,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage 
from portfolioProject.dbo.coviddeaths
where country like '%cana%' 
order by 1,2



--Looking at total cases vs population
-- The percentage of population that got Covid

select country,date,total_cases,population,(total_cases/population)*100 as PercentPopulationinfected
from portfolioProject.dbo.coviddeaths
where country like '%cana%'
and continent is not null
order by 2

--Looking ast the countries have highest infection rate vs population  

select country,Max(Cast(total_cases as int)) as HighestInfectionCount ,Max(total_cases/population)*100 as PercentPopulationinfected 
from portfolioProject.dbo.coviddeaths
--where country like '%cana%' 
group by country 
order by PercentPopulationinfected DESC


--Show the countries with highest deaths per population:

select country,Max(Cast(total_deaths as int)) as TotaldeathCount ,Max(cast(total_deaths as int)/population)*100 as PercentPopulationDeath 
from portfolioProject.dbo.coviddeaths
--where country like '%cana%'
where continent is not null
group by country 
order by TotaldeathCount DESC

--break  Data down by continent

select continent,Max(Cast(total_deaths as int)) as TotaldeathCount 
from portfolioProject.dbo.coviddeaths
--where country like '%cana%'
where continent is not null
group by continent 
order by TotaldeathCount DESC


--Global numbers per every day  and solution for divide by zero condition.

select date,sum(new_cases)as TotalCases,sum(new_deaths) as TotalDeaths,
(select case
			when sum(new_cases) = 0
			then 0
			else sum(new_deaths)/sum(cast(new_cases as int))*100
 End) as DeathPercentage 
from portfolioProject.dbo.coviddeaths
where continent is not null
group by date
order by 1

--Total deaths and infected Covid.

select sum(new_cases)as TotalCases,sum(new_deaths) as TotalDeaths,
(select case
			when sum(new_cases) = 0
			then 0
			else sum(new_deaths)/sum(cast(new_cases as int))*100
 End) as DeathPercentage 
from portfolioProject.dbo.coviddeaths
where continent is not null
--group by date
--order by 1

-----------------END OF PART ONE-----------------

----Part Two: work on two tables, View, Temp Table and ...-----

select * from portfolioProject..covidvaccination
where continent is not null
order by 1



-- Update portfolioProject..covidvaccination set new_vaccinations=0 where new_vaccinations is null
--look at the total population vs vaccinations

select deat.continent,deat.country,deat.date, deat.population, vacc.new_vaccinations,
sum(convert(bigint,vacc.new_vaccinations)) OVER (Partition by vacc.country 
order by vacc.country, vacc.date) as RollingPeopleVaccinated
from portfolioProject..covidvaccination vacc
join portfolioProject..coviddeaths deat
on vacc.country= deat.country
and vacc.date=deat.date
where deat.continent is not null
order by 2,3


--Using CTE:

with vaccinPopulation (continent,country,date,population,new_vaccinations, RollingPeopleVaccinated) 
as
(select deat.continent,deat.country,deat.date, deat.population, vacc.new_vaccinations,
sum(convert(bigint,vacc.new_vaccinations)) OVER (Partition by vacc.country 
order by vacc.country, vacc.date) as RollingPeopleVaccinated
from portfolioProject..covidvaccination vacc
join portfolioProject..coviddeaths deat
on vacc.country= deat.country
and vacc.date=deat.date
where deat.continent is not null)
--order by 2,3)

select * , (RollingPeopleVaccinated/population)*100
from vaccinPopulation




--TEMP Table

Drop table if exists #PercentPopulationVaccinated 
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
country nvarchar(255),
date datetime,
population numeric, 
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

select deat.continent,deat.country,deat.date, deat.population, vacc.new_vaccinations,
sum(convert(bigint,vacc.new_vaccinations)) OVER (Partition by vacc.country 
order by vacc.country, vacc.date) as RollingPeopleVaccinated
from portfolioProject..covidvaccination vacc
join portfolioProject..coviddeaths deat
on vacc.country= deat.country
and vacc.date=deat.date
where deat.continent is not null
--order by 2,3)

select * , (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Create View to store Data for Visualization


Use portfolioProject
go
Create View PercentPopulationVaccinated as 
select deat.continent,deat.country,deat.date, deat.population, vacc.new_vaccinations,
sum(convert(bigint,vacc.new_vaccinations)) OVER (Partition by vacc.country 
order by vacc.country, vacc.date) as RollingPeopleVaccinated
from portfolioProject..covidvaccination vacc
join portfolioProject..coviddeaths deat
on vacc.country= deat.country
and vacc.date=deat.date
where deat.continent is not null

Select * from PercentPopulationVaccinated
