##Cleaning-Analyzing-Tech-Layoffs-Data-Using-SQL-

🧹 Phase 1: Data Cleaning using SQL
Real-world data is messy — and this dataset was no exception. Here's what I did to clean it:

1️⃣ Removed Duplicates

Used ROW_NUMBER() with a PARTITION BY on all columns to detect duplicates.

Created a staging table and removed rows where row_num > 1 — keeping only unique records.

2️⃣ Standardized the Data

Trimmed extra spaces in fields like company.

Corrected inconsistent values (e.g., "Crypto Trading" → "Crypto").

Removed trailing punctuation from country names (e.g., "United States." → "United States").

Used STR_TO_DATE() to convert string-formatted dates into actual DATE types.

3️⃣ Handled Null & Blank Values

Replaced blank strings with NULL to make filtering easier.

Used self-joins to populate missing industry values based on matching company and location.

Removed rows where key metrics like total_laid_off and percentage_laid_off were both NULL, as they weren’t helpful for analysis.

4️⃣ Dropped Unnecessary Columns

Removed helper fields like row_num after cleaning.

✅ End Result: A clean, structured dataset ready for analysis.

🔍 Phase 2: Exploratory Data Analysis (EDA)
Once the data was cleaned, I asked several questions to uncover trends and patterns:

📌 Q: What’s the highest number of layoffs in a single event?

Over 12,000 employees were laid off in a single round.

Some companies had 100% workforce layoffs, especially among heavily funded startups.

📌 Q: Which companies laid off the most people?

Google, Amazon, and Meta topped the charts in terms of total layoffs.

📌 Q: Which industries were hit hardest?

The Consumer, Retail, and Crypto sectors saw the most cuts.

📌 Q: What about geography?

The United States saw the overwhelming majority of layoffs in this dataset.

📌 Q: Any trends by company stage?

Companies in the Post-IPO stage faced the largest layoffs — even publicly traded firms weren’t spared.

📌 Q: What does the trend over time look like?

Layoffs surged in 2022, with rolling cumulative totals highlighting a steep upward curve through late 2022 and early 2023.

📌 Q: Which companies led layoffs each year?

Using DENSE_RANK() and a CTE, I ranked the top 5 companies by layoffs per year.

Interesting shifts in leadership appeared between years, with some companies recurring while others spiked temporarily.

🔗 Key Takeaways:

SQL can do so much more than just simple queries — from data cleaning to trend detection.

Real-world data projects like this are the best way to sharpen skills and demonstrate impact.

In the end, clean data is what powers trusted insights.

📁 Tools Used:
✅ SQL (Data Cleaning & Analysis)



#SQL #EDA #DataCleaning #LayoffsAnalysis #PowerBI #DataAnalytics #PortfolioProject #CareerGrowth #RealWorldData #TechTrends #DataScience
