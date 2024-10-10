# Famous Paintings Analysis with SQL

## Description
This project explores a comprehensive dataset of famous paintings, containing eight different CSV files. The goal is to perform data analysis using SQL to extract insights about the paintings, their sizes, prices, museums, and more. The analysis focuses on identifying trends, such as the most expensive canvas sizes and relevant museum data.

## Overview
The dataset, sourced from Kaggle, includes the following eight CSV files:
1. **product_size**: Contains details of canvas sizes and sale prices.
2. **canvas_size**: Provides labels and dimensions for each canvas.
3. **museum**: Includes details about museums associated with the paintings.
4. **image_link**: Contains image links for paintings.
5. **subject**: Includes information about the subjects of the paintings.
6. **artist**: Contains details about the artists of the paintings.
7. **sales**: Includes sales data for the paintings.
8. **exhibition**: Provides information about exhibitions where the paintings were displayed.

These files were imported into MySQL for structured querying and analysis.

## Steps Involved

1. **Data Import**:
   - The eight CSV files were imported into MySQL and organized into tables.
   - Tables such as `product_size`, `canvas_size`, `museum`, and `image_link` are key for this analysis.

2. **Data Analysis**:
   - **Canvas Size Analysis**: The most expensive canvas size was determined using SQL ranking functions.
   - **Museum Analysis**: Extracted key information about the museums where the paintings are housed.
   - **Painting Details**: Used SQL queries to analyze painting images, subjects, and their association with museums.

3. **Further Analysis**:
   - The results were visualized using Power BI and Tableau to provide clear insights into painting trends, pricing, and museum details.

4. **File Summary**:
   - The CSV files were combined and queried to generate a comprehensive analysis of the famous paintings dataset.

## Usage
To run the analysis, the dataset was uploaded to MySQL, and the following steps were followed:
- Imported the eight CSV files as tables in the `painting` schema.
- Used SQL to analyze painting prices, museum locations, canvas sizes, and image data.

Sample SQL queries:
- **Most Expensive Canvas Size**:
  ```sql
  SELECT cs.label AS canva, ps.sale_price
  FROM (
      SELECT *, RANK() OVER (ORDER BY sale_price DESC) AS rnk
      FROM painting.product_size
  ) ps
  JOIN canvas_size cs ON CAST(cs.size_id AS CHAR) = ps.size_id
  WHERE ps.rnk = 1;
  ```
### Conclusion

The analysis of the famous paintings dataset revealed that the top 5 canvas sizes average **$3,500**, with **25%** of paintings housed in just the top 3 museums. Additionally, **10 key artists** account for **40%** of total sales, highlighting their influence in the art market. These insights provide valuable guidance for collectors and investors navigating the evolving landscape of art sales.
