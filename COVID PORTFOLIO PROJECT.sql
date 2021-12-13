select *
from dbo.CovidDeaths
order by 3,4

select *
from CovidVac
order by 3,4

--Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population 
from dbo.CovidDeaths
order by 1,2

--Looking at Total cases vs Total Deaths
--Most likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100  death_percentage 
from dbo.CovidDeaths
where location like 'Pakistan'
order by 1,2

--Looking at the Total Cases vs the Population
--Shows what percentage of people got Covid

Select location, date, total_cases, population, (total_cases/population)*100  NewCasesPercentage 
from dbo.CovidDeaths
--where location like 'Pakistan'
order by 1,2

--Looking at countries with Highest Infection Rate compared to Population

Select location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100  InfectionPercentage 
from dbo.CovidDeaths
--where location like 'Pakistan'
group by location, population
order by 4 DESC

--Showing Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int))  TotslDeathCount 
from dbo.CovidDeaths
--where location like 'Pakistan'
Where continent is not null
group by location
order by 2 Desc

--LETS BREAKDOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int))  TotslDeathCount 
from dbo.CovidDeaths
--where location like 'Pakistan'
Where continent is not null
group by continent
order by 2 Desc

--Showing continents with Highest Death Count per population

Select continent, MAX(cast(total_deaths as int))  TotslDeathCount 
from dbo.CovidDeaths
--where location like 'Pakistan'
Where continent is not null
group by continent


--GLOBAL NUMBERS

Select SUM(new_cases)  total_cases, SUM(cast(new_deaths as int))  total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100  DeathPercentage 
from dbo.CovidDeaths
--where location like 'Pakistan'
Where continent is not null
--group by date
order by 1,2


--Looking at Total Population vs Tatal Vaccinations


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollngPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVac vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollngPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVac vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *
From PopvsVac


--TEMP Tables
DROP TABLE IF exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinatiions numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollngPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVac vac
    on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

select *
from #PercentPopulationVaccinated

