SELECT *
FROM PorfolioProject..CovidDeaths
where continent is not NULL
order by 3,4

--SELECT *
--FROM PorfolioProject..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
from PorfolioProject..CovidDeaths
where continent is not NULL
order by 1,2



-- Looking at Total Cases vs Total Deaths
-- Shows the liklihood of dying if you contract Covid in your country.

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PorfolioProject..CovidDeaths
Where location like '%states%' and continent is not NULL
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

Select location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
from PorfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2


-- Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
from PorfolioProject..CovidDeaths
--where location like '%states%'
group by population, location
order by PercentPopulationInfected DESC
	


-- Showing the countries with the highest death count per population
	
Select location, MAX(cast(total_deaths As int)) AS TotalDeathCount
from PorfolioProject..CovidDeaths
--where location like '%states%'
where continent is not NULL
group by location
order by TotalDeathCount DESC

	
	
--  Breaking numbers down by continent 
	
Select location, MAX(cast(total_deaths As int)) AS TotalDeathCount
from PorfolioProject..CovidDeaths
--where location like '%states%'
where continent is NULL
group by location
order by TotalDeathCount DESC

	

-- Showing the continents with the highest death count per population 

Select continent, MAX(cast(total_deaths As int)) AS TotalDeathCount
from PorfolioProject..CovidDeaths
--where location like '%states%'
where continent is not NULL
group by continent
order by TotalDeathCount DESC


	
-- GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPerentage
From PorfolioProject..CovidDeaths
Where continent is not NULL 
order by 1, 2 

	

-- Looking at Total  Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) As RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

	

-- Using CONVERT
	
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

	
--Use a CTE

With PopvsVac (Continent, Location, Date, population, New_vaccinations, RollingPeopleVaccinated)
as  
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) As RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
SELECT*, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) As RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

SELECT*, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



	
--Creating View to Store Data for Later Visualizations 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) As RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Create View TotalVacvsTotalPop as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) As RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Create View GlobalNumbers AS 
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPerentage
From PorfolioProject..CovidDeaths
Where continent is not NULL 

Create view  HighestInfectionRate As 
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
from PorfolioProject..CovidDeaths
--where location like '%states%'
group by population, location

Create View HighestDeathCount AS
Select location, MAX(cast(total_deaths As int)) AS TotalDeathCount
from PorfolioProject..CovidDeaths
--where location like '%states%'
where continent is not NULL
group by location
