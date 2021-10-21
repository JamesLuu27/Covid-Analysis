
--select * from [Portfolio Project]..['Covid Death$']
--order by 3,4

--select * from [Portfolio Project]..['Covid Vaccination$']
--order by 3,4

select Location,date,total_cases,new_cases,total_deaths,population
from [Portfolio Project]..['Covid Death$']
order by 1,2

--Looking at Total Cases vs Total Deaths
--Show the likelihood of dying from COVID in US
select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as 'Percentage of Death'
from [Portfolio Project]..['Covid Death$']
where location like '%states%' and continent is not null
order by 1,2

--Looking at total cases vs populations
--Show % of Population & Covid
select Location,date,population,total_cases,(total_cases/population)*100 as per_of_covid
from [Portfolio Project]..['Covid Death$']
where location like '%states%' and continent is not null
order by 1,2

--Looking at Countries with Highest Infection Rate Compared to Populations
select Location,date,population,MAX(total_cases) as HighestInfection,MAX((total_cases/population))*100 as per_of_covid
from [Portfolio Project]..['Covid Death$']
--where location like '%states%'
where continent is not null
group by location,date,population
order by per_of_covid desc




--View Countries with Highest Infection Rate
create view HighestInfection as 
with highestinfectionrate as 
(
select Location,date,population,MAX(total_cases) as HighestInfection,MAX((total_cases/population))*100 as per_of_covid
from [Portfolio Project]..['Covid Death$']
--where location like '%states%'
where continent is not null
group by location,date,population
)
select * from highestinfectionrate


--Show Countries with highest death per population
select Location, max(cast(total_deaths as int)) as totaldeathcount
from [Portfolio Project]..['Covid Death$']
--where location like '%states%'
where continent is null
group by location
order by totaldeathcount desc

--Highest Death Per Pop
Create View DeathPerPop as 
select Location, max(cast(total_deaths as int)) as totaldeathcount
from [Portfolio Project]..['Covid Death$']
--where location like '%states%'
where continent is null
group by location


--Showing continent with highest death count per populations
select Location, max(cast(total_deaths as int)) as totaldeathcount
from [Portfolio Project]..['Covid Death$']
--where location like '%states%'
where continent is not null
group by location
order by totaldeathcount desc

--View Highest Death Count
create view HighestDeathCount as 
select Location, max(cast(total_deaths as int)) as totaldeathcount
from [Portfolio Project]..['Covid Death$']
--where location like '%states%'
where continent is not null
group by location


--Global Numbers
select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from [Portfolio Project]..['Covid Death$']
where continent is not null
--group by date
order by 1,2

--Create View
Create View GlobalNumbers as 
select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from [Portfolio Project]..['Covid Death$']
where continent is not null


--Covid Vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..['Covid Vaccination$'] vac join [Portfolio Project]..['Covid Death$'] dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null and new_vaccinations is not null
order by 2,3




create view PercentageofVac as
--USE CTE
with PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as 
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..['Covid Vaccination$'] vac join [Portfolio Project]..['Covid Death$'] dea
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/Population)*100 as PercentageOfVac 
from PopvsVac
--order by 2,3

--USE CTE
with PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as 
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..['Covid Vaccination$'] vac join [Portfolio Project]..['Covid Death$'] dea
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
)


select *,(RollingPeopleVaccinated/Population)*100 as PercentageOfVac 
from PopvsVac
order by 2,3

--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, New_Vaccinations numeric, RollingPeopleVaccinated numeric)
Insert Into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..['Covid Death$'] dea join [Portfolio Project]..['Covid Vaccination$'] vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/Population)*100 as PercentageOfVac 
from #PercentPopulationVaccinated
order by 2,3

--Creating View to store data for later visualizations
create view PercentagePopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..['Covid Death$'] dea join [Portfolio Project]..['Covid Vaccination$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

