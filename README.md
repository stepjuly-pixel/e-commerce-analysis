# E-Commerce Analysis

## About the Project

Analysis of account creation and email activity to compare country performance and observe sending dynamics over time.

The dataset was built using SQL with predefined structural requirements and visualized in Looker Studio.

## Objective

- Aggregate account creation metrics

- Calculate total sent emails by country

- Rank countries by account volume and email activity

- Visualize country-level performance

- Show time-series dynamics for sent emails

## Tools

- [SQL](sql/sql.sql) (CTEs, window functions, aggregations)

- BigQuery

- Looker Studio

## Results

- The United States generates the highest volume of sent emails.

- Top 3–5 countries account for the majority of total email traffic.

- Email activity increased toward the end of 2020 and declined after February 2021.

- Country ranking by total accounts and sent emails shows similar leading markets.

## Project Structure
```
e-commerce-analysis/

  sql/sql.sql — final analytical query

  images/image.png — dashboard screenshots

  README.md — project description
```

## Dashboard Preview

<img width="1175" height="825" alt="image" src="https://github.com/user-attachments/assets/aa80b939-9291-45ea-a7f4-f7cf499b2ca0" />

