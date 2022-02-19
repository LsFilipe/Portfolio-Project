Select *
From PortfolioProject..[Covid-deaths]
where continent is not null
order by 3,4

Select *
From PortfolioProject..[covid-vaccinations$']
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..[covid-deaths]
order by 1,2


-- Looking at total cases vs total deaths
-- Shows the likelyhood of dying if infected by covid in Mozambique

Select location, date, total_cases, total_deaths, Cast (Total_deaths as numeric(18,2))/cast (total_cases as numeric (18,2))*100 as DeathPercentage
From PortfolioProject..[covid-deaths]
where location like '%Mozambique%'
order by 1,2


--Looking at total cases vs the population "
-- Shows what percentage of the population got Covid
Select location, date, total_cases, population, Cast (Total_cases as numeric(18,2))/cast (population as numeric (18,2))*100 as PercentagePopulationInfected
From PortfolioProject..[covid-deaths]
where location like '%Mozambique%'
order by 1,2

-- Looking at countries with highest infaction rate compared to Population
Select location, population,date, MAX(Cast (total_cases as numeric(18,2))) as HighestInfectionCount, MAX(Cast (total_cases as numeric(18,2))/cast (population as numeric (18,2)))*100 as PercentagePopulationInfected
From PortfolioProject..[covid-deaths]
--where location like '%Mozambique%'
Group by location, population,[date]
order by PercentagePopulationInfected desc


-- Showing Countries with the highest death count per population
Select location, MAX(Cast (total_deaths as numeric(18,2))) as TotalDeathCount
From PortfolioProject..[covid-deaths]
where continent is not null
--where location like '%Mozambique%'
Group by location
order by TotalDeathCount desc

-- LETS BREAK IT DOWN BY CONTINENT "

Select location, MAX(Cast (total_deaths as numeric(18,2))) as TotalDeathCount
From PortfolioProject..[covid-deaths]
where continent is null
--where location like '%Mozambique%'
Group by [location]
order by TotalDeathCount desc

--Showing the continents with the highest death counts

Select continent, MAX(Cast (total_deaths as numeric(18,2))) as TotalDeathCount
From PortfolioProject..[covid-deaths]
where continent is not null
--where location like '%Mozambique%'
Group by continent
order by TotalDeathCount desc


-- Global numbers

Select SUM(Cast(new_cases as numeric (18,2))) as TotalCases, SUM(cast(new_deaths as numeric (18,2))) as TotalDeaths, SUM(cast(new_deaths as numeric (18,2)))/SUM(Cast(new_cases as numeric (18,2)))*100 as DeathPercentage
From PortfolioProject..[covid-deaths]
where continent is not null 
--Group by date
order by 1,2


--Looking at total Population vs Vaccinations

Select *
From PortfolioProject..[Covid-deaths] dea
Join PortfolioProject..[Covid-vaccinations] vac
    On dea. location = vac. location 
    and dea. date = vac. date 


Select dea.continent, dea. location, dea. date, dea. population, vac. new_vaccinations
From PortfolioProject..[Covid-deaths] dea
Join PortfolioProject..[Covid-vaccinations] vac
    On dea. location = vac. location 
    and dea. date = vac. date 
where dea.continent is not null 
order by 1,2


Select dea.continent, dea. location, dea. date, dea. population, vac. new_vaccinations, SUM(Cast (vac. new_vaccinations as numeric (18,2))) OVER (Partition by dea. Location Order by dea. location, dea. Date) as RollingPeopleVacc
From PortfolioProject..[Covid-deaths] dea
Join PortfolioProject..[Covid-vaccinations] vac
    On dea. location = vac. location 
    and dea. date = vac. date 
where dea.continent is not null 
order by 2,3

--Use CTE 

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVacc)
as
(
Select dea.continent, dea. location, dea. date, dea. population, vac. new_vaccinations
, SUM(Cast (vac. new_vaccinations as numeric (18,2))) OVER (Partition by dea. Location Order by dea. location,
 dea. Date) as RollingPeopleVacc
From PortfolioProject..[Covid-deaths] dea
Join PortfolioProject..[Covid-vaccinations] vac
    On dea. location = vac. location 
    and dea. date = vac. date 
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVacc/population)*100
From PopvsVac 





--Temp table 

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(continent NUMERIC, location NVARCHAR, date DATETIME, population NUMERIC, new_vaccinations NUMERIC, RollingPeopleVacc NUMERIC)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea. location, dea. date, dea. population, vac. new_vaccinations
, SUM(Cast (vac. new_vaccinations as numeric (18,2))) OVER (Partition by dea.location Order by dea.location
, dea.Date) as RollingPeopleVacc
From PortfolioProject..[Covid-deaths] dea
Join PortfolioProject..[Covid-vaccinations] vac
    On dea. location = vac. location 
    and dea. date = vac. date 
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVacc/population)*100
From #PercentPopulationVaccinated

-- CREATING VIEW TO STORE DATA FOR LATER VISUALISATION

Drop view PercentagePopulationVacc;
GO
Create view PercentagePopulationVacc as 
Select date, SUM(Cast(new_cases as numeric (18,2))) as TotalCases, SUM(cast(new_deaths as numeric (18,2))) as TotalDeaths, SUM(cast(new_deaths as numeric (18,2)))/SUM(Cast(new_cases as numeric (18,2)))*100 as DeathPercentage
From PortfolioProject..[covid-deaths]
where continent is not null 
Group by date
--order by 1,2