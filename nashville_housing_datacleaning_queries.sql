/*

Cleaning Data in SQL Queries

*/

-- #1 STANDARDIZE DATE FORMAT

--SELECT SaleDateConverted
--FROM housing

--ALTER TABLE housing
--Add SaleDateConverted Date;

--Update housing
--SET SaleDateConverted = CONVERT(Date, SaleDate)

-- #2 POPULATE PROPERTY ADDRESS DATA
/*
	INVESTIGATE THE % OF PROPERTY ADDRESSES THAT ARE NULL 
	(Answer based on the query below is 0.05%, or 29 rows out of over 56,000 rows)
	With such a low percentage of NULL data, I would typically not have a problem with deleting the
	rows altogether; however, we are going to instead populate them with real address data based on 
	the information available in the ParcelID column
*/

--WITH null_address_stats AS (
--	SELECT 
--		COUNT(CASE WHEN PropertyAddress IS NULL THEN UniqueID END) AS null_property_address_count,
--		COUNT(*) AS all_properties_count
--	FROM housing
--)
--SELECT
--	ROUND(100.0 * null_property_address_count / all_properties_count, 2) AS percent_property_address_null
--FROM null_address_stats

/*
complete a self-join of the housing table and populate the null propertyaddress 
column with the non-null property address column, based on the ParcelID value
*/

--Update h1
--SET PropertyAddress = ISNULL(h1.PropertyAddress, h2.PropertyAddress)
--FROM housing h1
--JOIN 
--	housing h2
--	ON h1.ParcelID = h2.ParcelID
--		AND h1.[UniqueID ] <> h2.[UniqueID ]
--WHERE h1.PropertyAddress IS NULL

/*
Test if it worked: the following query should return no results, 
because no null values should exist in the PropertyAddress column.
*/

--SELECT 
--	h1.ParcelID, 
--	h1.PropertyAddress,
--	h2.ParcelID,
--	h2.PropertyAddress
--FROM housing h1
--JOIN 
--	housing h2
--	ON h1.ParcelID = h2.ParcelID
--		AND h1.[UniqueID ] <> h2.[UniqueID ]
--WHERE h1.PropertyAddress IS NULL

-- #3 BREAKING OUT PROPERTY ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

--ALTER TABLE housing
--Add PropertySplitAddress Nvarchar(255);

--Update housing
--SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

--ALTER TABLE housing
--Add PropertySplitCity Nvarchar(255)

--Update housing
--SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--Test if it works: select both of the newly added columns from the table

--SELECT
--	PropertySplitAddress,
--	PropertySplitCity
--FROM housing

-- #4 BREAKING OUT OWNER ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

--ALTER TABLE housing
--Add OwnerSplitState Nvarchar(255);

--Update housing
--SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--ALTER TABLE housing
--Add OwnerSplitCity Nvarchar(255);

--Update housing
--SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

--ALTER TABLE housing
--Add OwnerSplitAddress Nvarchar(255);

--Update housing
--SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

--TEST IF IT WORKED
--SELECT
--	*
--FROM housing

-- #5 CHANGE 'Y' AND 'N' TO 'YES' AND 'NO' IN "SOLD AS VACANT" FIELD

--Update housing
--SET SoldAsVacant = 
--	CASE 
--		WHEN SoldAsVacant = 'Y' THEN 'Yes'
--		WHEN SoldAsVacant = 'N' THEN 'No'
--		ELSE SoldAsVacant
--	END

--TEST IF IT WORKED: SELECT THE SOLD AS VACANT COLUMN. DO 'Y' AND 'N' STILL EXIST IN THE COLUMN?	
--SELECT
--	SoldAsVacant
--FROM housing

-- #6 REMOVE DUPLICATES

-- CONFIRM THE EXISTENCE OF DUPLICATES.
--WITH duplicate_finder AS (
--	SELECT 
--		*,
--		ROW_NUMBER() OVER(
--			PARTITION BY 
--				ParcelId, 
--				PropertyAddress, 
--				SalePrice, 
--				SaleDate,
--				LegalReference
--			ORDER BY UniqueID
--			) AS row_num
--	FROM housing
--)
--SELECT
--	*
--FROM duplicate_finder
--WHERE 
--	OwnerSplitAddress LIKE '%1728%pecan%st%'

--DELETE DUPLICATES
--WITH duplicate_finder AS (
--	SELECT 
--		*,
--		ROW_NUMBER() OVER(
--			PARTITION BY 
--				ParcelId, 
--				PropertyAddress, 
--				SalePrice, 
--				SaleDate,
--				LegalReference
--			ORDER BY UniqueID
--			) AS row_num
--	FROM housing
--)
--DELETE
--FROM duplicate_finder
--WHERE row_num > 1

-- #7 DELETE UNUSED COLUMNS

--ALTER TABLE housing
--DROP COLUMN
--	OwnerAddress,
--	TaxDistrict,
--	PropertyAddress

--ALTER TABLE housing
--DROP COLUMN SaleDate


-- test if the columns were removed from the table
--SELECT *
--FROM housing

