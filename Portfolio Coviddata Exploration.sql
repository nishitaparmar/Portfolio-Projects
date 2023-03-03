-- Covid 19 Data Exploration

Select *
FROM PortfolioProject..CovidDeaths
Where continent is not null
Order By 3,4


-- Select Data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%India%'
and continent is not null
Order By 1,2


--Total cases vs Population
--Shows what percentage of Population infected with covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%India%'
Order By 1,2


--Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%India%'
Group By Location, Population
Order By PercentPopulationInfected DESC


--Countries with Highest Death Count per Population

select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%India%'
Where continent is not null
Group By Location
Order By TotalDeathCount desc


--Breaking Things Down By Continent

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By continent
Order By TotalDeathCount desc


--Global Numbers of Total deaths petrcentage

Select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 1,2


--Total Population vs New Vaccinations
-- Shows Percentage of Population that has received at least one Covid Vaccine


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3

--Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using TEMP TABLE to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Select *
From PercentPopulationVaccinated


