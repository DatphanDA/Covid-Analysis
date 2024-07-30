Select *
From Covid_Analysis..CovidDeaths$
where continent is not null
Order by 3, 4

--Select *
--From Covid_Analysis..CovidVaccinations$
--Order by 3, 4

Select location, date, total_cases, new_cases, total_deaths, population
From Covid_Analysis..CovidDeaths$
Order by 1,2

--Total Cases vs Total Deaths
Select location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as DeathPercentage
From Covid_Analysis..CovidDeaths$
where location like '%canada%'
Order by 2 desc

--Total Cases vs Population
Select location, date, population, total_cases, (total_cases/population)*100 as InfectionRate
From Covid_Analysis..CovidDeaths$
where location like '%canada%'
Order by 2

--Countries with Highest Infection Rate (With Population over 10mil)
Select location, population,max (total_cases) HighestInfectionCount,max( (total_cases/population))*100 as InfectionRate
From Covid_Analysis..CovidDeaths$
where population > 10000000
and continent is not null
group by location, population
Order by InfectionRate desc

--Countries with Highest Death Rate over Population (With Population over 10mil)
Select location, population, max(cast (total_deaths as int)) TotalDeaths,max( (total_deaths/population))*100 as DeathRateOverPop
From Covid_Analysis..CovidDeaths$
where population > 10000000
and continent is not null
group by location, population
Order by DeathRateOverPop desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Covid_Analysis..CovidDeaths$
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Covid_Analysis..CovidDeaths$
where continent is not null 
order by 1,2


--CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Covid_Analysis..CovidDeaths$ dea
Join Covid_Analysis..CovidVaccinations$ vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
)
Select Location, max((RollingPeopleVaccinated/Population)*100)
From PopvsVac
Group by Location


--TEMP TABLE

Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated int
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Covid_Analysis..CovidDeaths$ dea
Join Covid_Analysis..CovidVaccinations$ vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null

Select *
From #PercentagePopulationVaccinated



-- Creating View for Visualization
USE Covid_Analysis
GO
Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid_Analysis..CovidDeaths$ dea
Join Covid_Analysis..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Drop View PercentagePopulationVaccinated