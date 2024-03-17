 
 --(Covid 19) Data Exploration 
 --(Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types)

Select * 
From PortfolioProject.dbo.CovidDeaths
Where continent is not null 
Order by 3,4
Select *
From PortfolioProject.dbo.CovidDeaths

-- Select Data that we are going to be starting with
Select Location, date, Total_cases, New_cases,Total_deaths, population
From CovidDeaths
Where continent is not null 
Order By 1,2

	----Total Cases vs Total Deaths

Select Location, date, Total_cases,Total_deaths, (Total_deaths/Total_cases)*100 as DeathPercentage
From CovidDeaths
Where continent is not null 
Order By 1,2
--By States 
Select Location, date, Total_cases,Total_deaths, (Total_deaths/Total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%states%'
And continent is not null 
Order By 1,2
--By United Arab Emirates
Select Location, date, Total_cases,Total_deaths, (Total_deaths/Total_cases)*100 as DeathPercentage
From CovidDeaths
Where location = 'United Arab Emirates'
And continent is not null 
Order By 1,2

		---- Total Cases vs Population
		---- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
Where continent is not null 
Order By 1,2
--By States
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
Where location like '%states%'
And continent is not null 
Order By 1,2
--By United Arab Emirates
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
Where location = 'United Arab Emirates'
And continent is not null 
Order By 1,2

		---- Countries with Highest Infection Rate compared to Population

Select Location, Population,Max( total_cases) as HighestInfectionCount ,  Max (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
Where continent is not null 
Group By Location, Population
Order By PercentPopulationInfected desc


		---- Countries with Highest Death Count per Population 

Select Location, Max(Cast( total_deaths as INT)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
Where continent is not null 
Group By Location
Order By TotalDeathCount desc

		----Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalContintentsDeathCount
From PortfolioProject.dbo.CovidDeaths
Where continent is not null 
Group By continent
Order By TotalContintentsDeathCount desc



	---- GLOBAL NUMBERS -Total Cases vs Total Deaths

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
 SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where continent is not null 
Group By date
Order By 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
 SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as GLOBALDeathPercentage
From PortfolioProject.dbo.CovidDeaths
where continent is not null 
Order By 1,2

		---- Total Population vs Vaccinations
		---- Shows Percentage of Population that has recieved at least one Covid Vaccine 

Select dea.continent ,dea.location,dea.date, dea.population, vac.new_vaccinations
From PortfolioProject.dbo.CovidDeaths as dea
Join PortfolioProject.dbo.CovidVaccinations as vac
ON dea.date = vac.date
And dea. location = vac.location
where dea.continent is not null 
Order By 2,3

--By States
Select dea.continent ,dea.location,dea.date, dea.population, vac.new_vaccinations
From PortfolioProject.dbo.CovidDeaths as dea
Join PortfolioProject.dbo.CovidVaccinations as vac
ON dea.date = vac.date
And dea. location = vac.location
where dea.continent is not null 
And dea.location like '%states%'
Order By 2,3
--By United Arab Emirates
Select dea.continent ,dea.location,dea.date, dea.population, vac.new_vaccinations
From PortfolioProject.dbo.CovidDeaths as dea
Join PortfolioProject.dbo.CovidVaccinations as vac
ON dea.date = vac.date
And dea. location = vac.location
where dea.continent is not null 
And dea.location= 'United Arab Emirates'
Order By 2,3

	
Select dea.continent ,dea.location,dea.date, dea.population, vac.new_vaccinations
,Sum (Cast (vac.new_vaccinations as Int)) Over (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths as dea
Join PortfolioProject.dbo.CovidVaccinations as vac
ON dea.date = vac.date
And dea. location = vac.location
where dea.continent is not null 
Order By 2,3

		
		----- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage 
From PopvsVac
--By States
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null 
And dea.location like '%states%'
)
Select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage 
From PopvsVac
--By United Arab Emirates
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null 
And dea.location= 'United Arab Emirates'
)
Select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage 
From PopvsVac



			----- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table #PercentPopulationVaccinated
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
--Where dea.continent is not null 
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as Vac_Population
From #PercentPopulationVaccinated



			---- Creating View to store data for later visualizations
 
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null 
 
