SET SQL_SAFE_UPDATES = 0;
UPDATE covid_world.coviddeaths
SET date = str_to_date(date, '%d/%m/%Y');
SET SQL_SAFE_UPDATES = 1;


SELECT continent, location, date, total_cases, new_cases, total_deaths, population FROM covid_world.coviddeaths
GROUP BY continent, location;


# Total cases vs total deaths
# Chances of dying if you got Covid in Brazil 2020-2021

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS Death_Percentage
FROM covid_world.coviddeaths
WHERE location = 'Brazil'
AND Continent != '';

# What percentage of our population got Covid

SELECT location, date, population, total_cases, (total_cases/population) * 100 AS Cases_Percentage
FROM covid_world.coviddeaths
WHERE location = 'Brazil'
AND Continent != '';

# Countries with highest infection rate

SELECT location, population, MAX(total_cases) AS Highest_Infection, MAX(total_cases/population) * 100 AS Cases_Percentage
FROM covid_world.coviddeaths
WHERE continent != ''
GROUP BY population, location
ORDER BY Cases_Percentage DESC;

# Countries with highest death percentage

SELECT location, population, MAX(CAST(total_deaths AS UNSIGNED)) AS Highest_Death_Count
FROM covid_world.coviddeaths
WHERE continent != '' # IS NOT NULL wasn't returning the correct results for me, so I had to go for an empty string
GROUP BY location
ORDER BY Highest_Death_Count DESC;

# Breaking it down by continent

SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS Highest_Death_Count
FROM covid_world.coviddeaths
WHERE continent = ''
GROUP BY location
ORDER BY Highest_Death_Count DESC;

# Global numbers

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, ROUND(SUM(new_deaths)/SUM(new_cases),4)*100 AS death_percentage
FROM covid_world.coviddeaths
WHERE continent != ''
ORDER BY total_cases;

SELECT Death.location, Death.continent, Death.date, Death.population, Vacc.new_vaccinations,
SUM(Vacc.new_vaccinations) OVER (PARTITION BY Vacc.location ORDER BY Vacc.location, Vacc.date) AS total_vaccination
FROM covid_world.coviddeaths AS Death
JOIN covid_world.covidvaccinations AS Vacc
ON Death.location = Vacc.location
AND Death.date = Vacc.date
WHERE Death.continent != ''
ORDER BY Death.location;

# Creating a CTE 

WITH PopvsVacc (location, continent, date, population, new_vaccinations, total_vaccination)
AS
	(SELECT Death.location, Death.continent, Death.date, Death.population, Vacc.new_vaccinations,
SUM(Vacc.new_vaccinations) OVER (PARTITION BY Vacc.location ORDER BY Vacc.location, Vacc.date) AS total_vaccination
FROM covid_world.coviddeaths AS Death
JOIN covid_world.covidvaccinations AS Vacc
	ON Death.location = Vacc.location
	AND Death.date = Vacc.date
WHERE Death.continent != '')

SELECT *, ROUND((total_vaccination/population)*100,2) as Vaccination_percentage FROM PopvsVacc;

# Creating a view for future visualization

CREATE VIEW PercentagePopulationVaccinatate AS
WITH PopvsVacc (location, continent, date, population, new_vaccinations, total_vaccination)
AS
	(SELECT Death.location, Death.continent, Death.date, Death.population, Vacc.new_vaccinations,
SUM(Vacc.new_vaccinations) OVER (PARTITION BY Vacc.location ORDER BY Vacc.location, Vacc.date) AS total_vaccination
FROM covid_world.coviddeaths AS Death
JOIN covid_world.covidvaccinations AS Vacc
	ON Death.location = Vacc.location
	AND Death.date = Vacc.date
WHERE Death.continent != '')
SELECT *, ROUND((total_vaccination/population)*100,2) as Vaccination_percentage FROM PopvsVacc;

