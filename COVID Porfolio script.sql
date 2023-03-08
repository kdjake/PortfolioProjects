select *
From PortfolioProject..CovidDeaths 
where continent is not null
order by 3, 4		

--select *
--From PortfolioProject..CovidVaccinations
--order by 3, 4

select location, date , total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2

-- Looking at total cases vs Total Deaths 
-- shows likelihood of dying if you contract covid in your country 
select location, date , total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
Where location like '%thailand%'
and continent is not null
order by 1, 2

-- looking at Total cases vs population 
--shows what percentage of population got covid 
select location, date , population, total_cases, (total_cases/population)*100 as PercentPorpulationlInfected
From PortfolioProject..CovidDeaths
Where location like '%thailand%'
and continent is not null
order by 1, 2

--Looking at countries highest Infection Rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCoount, MAX((total_cases/population))*100 as PercentPorpulationlInfected 
From PortfolioProject..CovidDeaths
--Where location like '%thailand%'
Group by location, population
order by PercentPorpulationlInfected desc

-- Showing the countries with the highest death count per population 

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%thailand%'
where continent is not null
Group by location
order by TotalDeathCount desc

--lets break thing by continent 
----corect way 
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%thailand%'
where continent is null
Group by location
order by TotalDeathCount desc
--------
-- showing continents with the highest death count per population 
--wrong way comapre to the correct on top but for the procees to be the same

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%thailand%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- global numbers-- total 

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/ sum(new_cases) *100 as DeathPercentage 
From PortfolioProject..CovidDeaths
--Where location like '%thailand%'
where continent is not null
--group by date 
order by 1, 2

-- my extra analysis |\ per day
Select date , sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/ sum(new_cases) *100 as DeathPercentage 
From PortfolioProject..CovidDeaths
--Where location like '%thailand%'
where continent is not null
group by date 
order by 1, 2

--Looking at Total Pupulation vs Vaccination 

Select dea.continent, dea.location , dea.date , dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location =vac.location
	and dea.date = vac.date 
where dea.continent is not null
--and dea.location like 'albania'
order by 2, 3



---use cte

with PopvsVac(continent, location, data, population, new_vaccinations, RollingPeopleVacinated)
as
(
Select dea.continent, dea.location , dea.date , dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location =vac.location
	and dea.date = vac.date 
where dea.continent is not null
--and dea.location like 'albania'
--order by 2, 3
)
Select *,(RollingPeopleVacinated/population)*100
From PopvsVac

---temp table 
Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_vacinnations numeric, 
RollingPeopleVaccinated numeric
)


Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location , dea.date , dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location =vac.location
	and dea.date = vac.date 
--where dea.continent is not null
--and dea.location like 'albania'
--order by 2, 3

Select *,(RollingPeopleVaccinated/population)*100
From #PercentagePopulationVaccinated



----creating View to store data for later visualizations

Create View PercentagePopulationVaccinated as 
Select dea.continent, dea.location , dea.date , dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location =vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2, 3

select *
from PercentagePopulationVaccinated