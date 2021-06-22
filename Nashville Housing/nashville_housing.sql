/* 

Cleaning Data 

*/

SELECT * 
FROM PortfolioProject..nashville_housing


--------------------------------------------------------------------------------
-- Standardize Date Format

SELECT SaleDate, CONVERT(Date,SaleDate) 
FROM PortfolioProject..nashville_housing

Update PortfolioProject..nashville_housing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE nashville_housing
ADD SaleDateConverted Date;

Update PortfolioProject..nashville_housing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--------------------------------------------------------------------------------

-- Populate Property Address Data 

SELECT *
FROM PortfolioProject..nashville_housing
--WHERE PropertyAddress is null
ORDER BY ParcelID 


SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..nashville_housing a
JOIN PortfolioProject..nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..nashville_housing a
JOIN PortfolioProject..nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null



--------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..nashville_housing
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

FROM PortfolioProject..nashville_housing


ALTER TABLE nashville_housing
ADD PropertySplitAddress Nvarchar(255);

Update nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 


ALTER TABLE nashville_housing
ADD PropertySplitCity Nvarchar(255);

Update nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


SELECT * 
FROM PortfolioProject..nashville_housing


-- Splitting OwnerAddress

SELECT OwnerAddress 
FROM PortfolioProject..nashville_housing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM PortfolioProject..nashville_housing


ALTER TABLE nashville_housing
ADD OwnerSplitAddress Nvarchar(255);

Update nashville_housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


ALTER TABLE nashville_housing
ADD OwnerSplitCity Nvarchar(255);

Update nashville_housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE nashville_housing
ADD OwnerSplitState Nvarchar(255);

Update nashville_housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

SELECT * 
FROM PortfolioProject..nashville_housing


--------------------------------------------------------------------------------

-- Change Y and N in "Sold as Vacant"

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2

-- Case statement
	SELECT SoldAsVacant
	, CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		   WHEN SoldAsVacant = 'N' THEN 'NO'
		   ELSE SoldAsVacant
		   END
	FROM PortfolioProject..nashville_housing

Update PortfolioProject..nashville_housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		   WHEN SoldAsVacant = 'N' THEN 'NO'
		   ELSE SoldAsVacant
		   END



--------------------------------------------------------------------------------

-- Removing Duplicates

-- CTE

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num

FROM PortfolioProject..nashville_housing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1 


--------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE PortfolioProject..nashville_housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..nashville_housing
DROP COLUMN SaleDate

