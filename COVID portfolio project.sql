Select * 
From portfolio_project..Covid_Deaths
where continent is not null
Order by 3,4 

--Select *
--From portfolio_project..CovidVaccinations
--Order by 3,4 

-- Select Data that we are going to be using 
Select Location, date,total_cases, new_cases, total_deaths, population
From portfolio_project..Covid_Deaths
where continent is not null
order by 1,2


-- Checking data types 


-- Looking at the Total Cases Vs Total Deaths 
-- Shows the likelihood of dying if you contract COVID in your country 
Select Location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From portfolio_project..Covid_Deaths
Where location like '%states%'
and continent is not null 
order by 1,2

-- Look at Total Cases Vs Population 
-- Shows what percentage of population got COVID 
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentOfPopulationInfected
From portfolio_project..Covid_Deaths
-- Where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population 
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentOfPopulationInfected
From portfolio_project..Covid_Deaths
-- Where location like '%states%'
Group by Location,Population
order by PercentOfPopulationInfected desc

-- Showing Countries with the Hightest Death Count per Population 
Select Location, MAX(total_deaths) as TotalDeathCount
From portfolio_project..Covid_Deaths
-- Where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc

--BREAKING THINGS DOWN BY CONTINENT 
Select continent, MAX(total_deaths) as TotalDeathCount
From portfolio_project..Covid_Deaths
-- Where location like '%states%'
where continent is null
Group by continent
order by TotalDeathCount desc

-- Showing continents with the highest death count 
Select continent, MAX(total_deaths) as TotalDeathCount
From portfolio_project..Covid_Deaths
-- Where location like '%states%'
where continent is null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS 

Select date, SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths , SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From portfolio_project..Covid_Deaths
-- Where location like '%states%'
where continent is not null 
Group by date
order by 1,2

-- total cases for the world 
Select SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths , SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From portfolio_project..Covid_Deaths
-- Where location like '%states%'
where continent is not null 
--Group by date
order by 1,2

--Looking at Total Population vs Vaccinations 
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From portfolio_project..Covid_Deaths dea
Join portfolio_project..Covid_Vaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- USE CTE 
With PopvsVac (Contient, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From portfolio_project..Covid_Deaths dea
Join portfolio_project..Covid_Vaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/population)*100
From PopvsVac

--TEMP TABLE 
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime, 
Population float, 
New_vaccinations float,
RollingPeopleVaccinated float
)

Insert into #PercentPopulationVaccinated 
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From portfolio_project..Covid_Deaths dea
Join portfolio_project..Covid_Vaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
Select *,(RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualization 
Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From portfolio_project..Covid_Deaths dea
Join portfolio_project..Covid_Vaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3



