--select *
--from CovidDeaths$

--Select location, date, total_cases, new_cases, total_deaths,Population
--From CovidDeaths$
--order by 1,2

--Total cases vs total deaths
--Show likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths,(cast(total_deaths as float)/cast(total_cases as float))*100 as 'Death%'
From PortfolioProject..CovidDeaths$
Where location = 'Poland'
order by 1,2

-- Looking at total cases vs Population
-- What procentage of population got Covid
Select location, date, total_cases,Population,(cast(total_cases as float)/cast(Population as float))*100 as 'PopuationInfected%'
From PortfolioProject..CovidDeaths$
Where location = 'Poland'
order by 1,2

-- Looking at Cantries with Highest infation rate compared to population
Select location, Population,max(cast(total_cases as float)) as 'HighestInfectionCount',Max((cast(total_cases as float)/cast(Population as float)))*100 as 'PopuationInfected%'
From PortfolioProject..CovidDeaths$
--Where location = 'Poland'
group by location, Population
order by 'PopuationInfected%' desc

--Showing Countires with  Highest Death Coun per Population
Select location, MAX(cast(total_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
--Where location = 'Poland'
group by location, Population
order by TotalDeathCount desc

--BREAK BY CONTINENT
-- Showing the continents with the highest deathcount
Select location, MAX(cast(total_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is null
group by location
order by TotalDeathCount desc


-- Global numbers
Select sum(cast(new_cases as float)) as SumOfCases,sum(cast(new_deaths as float)) as SumOfDeaths, sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as 'TotalDeaths%'
From PortfolioProject..CovidDeaths$
Where continent is not null

--Looking at Total Populaition vs Vaccinations
Select dea.continent, dea.location, dea.date, Population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as AddingPeopleVaccinates
,
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--Use CTE
with PopvsVac ( Continent,Location,Date,Population,AddingPeopleVaccinates, New_Vaccinations)
as
(
Select dea.continent, dea.location, dea.date, Population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as AddingPeopleVaccinates
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select*, (cast(AddingPeopleVaccinates as float)/Population)*100
From PopvsVac
Where Location = 'Albania'
Order by 2,3


--TEMP Table
Drop Table if exists #ProcentPopulatonVaccinated1
Create Table #ProcentPopulatonVaccinated1
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
AddingPeopleVaccinates numeric
)
Insert into #ProcentPopulatonVaccinated1
Select dea.continent, dea.location, dea.date, Population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as AddingPeopleVaccinates
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From #ProcentPopulatonVaccinated1


--Creating View to later visualizations
Drop View if exists ProcentPopulatonVaccinated
Create View ProcentPopulatonVaccinated1 as
Select dea.continent, dea.location, dea.date, Population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as AddingPeopleVaccinates
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3