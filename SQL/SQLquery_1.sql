SELECT *
FROM Portfolio.dbo.deaths_malaysia$

SELECT *
FROM Portfolio..deaths_state$

SELECT *
FROM Portfolio.dbo.vax_state$

SELECT *
FROM Portfolio..vax_malaysia$

-- DEATH ORDER BY STATE
SELECT state, SUM(deaths_new) as total_death
FROM Portfolio..deaths_state$
GROUP BY [state]
ORDER BY 2 DESC

-- VACCINATION ORDER BY STATE

SELECT state, SUM(daily_full) as total_vaccinated
FROM Portfolio..vax_state$
GROUP BY [state]
ORDER BY 2 DESC


--JOIN TABLE

SELECT vax.state, MAX(cumul_full), SUM(pfizer1), SUM(sinovac1)
FROM Portfolio..vax_state$ vax
JOIN Portfolio..deaths_state$ dea
    On vax.[state] = dea.[state]
    and vax.[date] = dea.[date]
GROUP BY vax.state 


--SEE THE PERCENTAGE THAT HAS BEEN DIED BY COVID EVEN FULLY VACCINATED
SELECT vax.[state], SUM(dea.deaths_fvax) as total_death, SUM(vax.daily_full) as total_fully_vaccinated, SUM(cast(dea.deaths_new as int))/SUM(daily_full)*100 as Percentage
FROM Portfolio..vax_state$ vax
JOIN Portfolio..deaths_state$ dea
    On vax.[state] = dea.[state]
    and vax.[date] = dea.[date]
GROUP BY vax.[state]
ORDER BY Percentage ASC


--SEE THE PERCENTAGE THAT HAS BEEN DIED BY COVID WITHOUT VACCINE
SELECT state, SUM(deaths_new) as total_death, 
SUM(deaths_unvax) as total_death_antivax, 
SUM(cast(deaths_unvax as int))/SUM(deaths_new) *100 as percentage_antivax_death,
SUM(deaths_fvax) as total_death_fvax,
SUM(cast(deaths_fvax as int))/SUM(deaths_new)*100 as percentage_fvcax_death
FROM Portfolio.dbo.deaths_state$
GROUP BY state
ORDER BY percentage_fvcax_death DESC
