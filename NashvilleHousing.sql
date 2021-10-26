-- Cleaning Data using SQL Queries

SELECT
	*
FROM
	PortfolioProject.dbo.NashvilleHousing


-- Standardize Date Format (Remove time component as SaleDate is currently in a datetime format)
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,Saledate)

SELECT
	SaleDateConverted
FROM
	PortfolioProject.dbo.NashvilleHousing


-- Populate  Property Address Data (Replace null values with PropertyAddress by matching ParcelID)
SELECT
	*
FROM
	PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null 
Order by ParcelID

SELECT 
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
	PortfolioProject.dbo.NashvilleHousing AS a
	JOIN PortfolioProject.dbo.NashvilleHousing AS b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null 


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
	PortfolioProject.dbo.NashvilleHousing AS a
	JOIN PortfolioProject.dbo.NashvilleHousing AS b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null 



-- Breaking Address into Individual Columns (Address, City, State)
SELECT
	PropertyAddress
FROM
	PortfolioProject.dbo.NashvilleHousing
--Order by ParcelID


SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address 
FROM
	PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT
	*
FROM
	PortfolioProject.dbo.NashvilleHousing



-- Break OwnerAddress into Address, City, State (Using PARSENAME is more convenient than using SUBSTRING)
SELECT
	OwnerAddress
FROM
	PortfolioProject.dbo.NashvilleHousing


SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM
	PortfolioProject.dbo.NashvilleHousing


-- Alter table with changes made above to create new columns with their respective variables
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



SELECT
	*
FROM
	PortfolioProject.dbo.NashvilleHousing


-- Change Y and N to Yes and No in "SoldAsVacant" field
Select 
	DISTINCT(SoldAsVacant),
	COUNT(SoldAsVacant)
FROM
	PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


Select
	SoldASVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM
	PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

-- View changes made
Select 
	DISTINCT(SoldAsVacant),
	COUNT(SoldAsVacant)
FROM
	PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2



-- Remove Duplicates (Using ROW_NUMBER)
WITH RowNumCTE AS(
SELECT
	*,
	ROW_NUMBER() OVER(
	PARTITION BY 
		ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference	
		ORDER BY 
			UniqueID
			) row_num
FROM
	PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM 
	RowNumCTE
WHERE row_num > 1


-- Delete Unused Columns
SELECT
	*
FROM
	PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN 
	OwnerAddress,
	TaxDistrict,
	PropertyAddress,
	SaleDate