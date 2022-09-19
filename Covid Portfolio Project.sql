Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- looking at total cases vs Total deaths
-- shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From PortfolioProject..CovidDeaths 
where location like '%states%'
order by 1,2


-- looking at the total cases vs the population 
-- shows what percentage of population got covid


Select Location, date, total_cases, Population, (total_cases/population)*100 as percentpopulationinfected
From PortfolioProject..CovidDeaths 
--where location like '%states%'
order by 1,2


-- looking at countries with highest infection rate compared to population


Select Location, MAX(total_cases) as highestInfectioncount, Population, MAX(total_cases/population)*100 as percentpopulationinfected
From PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by percentpopulationinfected desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

Select location, MAX(cast(total_deaths as int)) as totaldeathcount
From PortfolioProject..CovidDeaths
--where location like '%states%'
 where continent is null
group by location
order by totaldeathcount desc

--showing the countries with highest death count per population 


Select Location, MAX(cast(total_deaths as int)) as totaldeathcount
From PortfolioProject..CovidDeaths
--where location like '%states%'
 where continent is not null
group by location, population
order by totaldeathcount desc




-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM
(new_cases)*100 as deathpercentage
From PortfolioProject..CovidDeaths 
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


--looking at total population vs vaccinations

select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
   order by 1,2


 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date)
as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
   order by 2,3




   -- USE CTEW

With popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date)
as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
   --order by 2,3
   )
   select *, (rollingpeoplevaccinated/population)*100
   from popvsvac


-- TEMP TABLE

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date)
as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
  where dea.continent is not null
   order by 2,3

select *, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated

-- creating view to store for later visualizations

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date)
as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
  where dea.continent is not null
   --order by 2,3

select *
from percentpopulationvaccinated