-- Cleaning Data

SELECT * 
FROM PortfolioProject..NashvilleHousing



-- Adjusting Date format

SELECT SaleDate, CONVERT(date, SaleDate)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate date


-- Getting rid of NULLS in PropertyAddress / self-joining

SELECT *
FROM PortfolioProject..NashvilleHousing
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Breaking out Address into (address, city, state)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject..NashvilleHousing

-- Breaking out Address into (address, city, state) WITH PARSENAME

SELECT PARSENAME(REPLACE(PropertyAddress,',', '.'),1),
PARSENAME(REPLACE(PropertyAddress,',', '.'),2)
FROM PortfolioProject..NashvilleHousing

-- Adding additional columns for split data

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT OwnerAddress 
FROM PortfolioProject..NashvilleHousing


-- OwnerAddress data split via SUBSTRING

SELECT SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress)-1) AS OwnerAddress,
SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress)+1, LEN(OwnerAddress)) AS OwnerCityState

FROM PortfolioProject..NashvilleHousing


-- OwnerAddress data split via PARSENAME

SELECT 
PARSENAME(REPLACE(OwnerAddress,',', '.'),3),
PARSENAME(REPLACE(OwnerAddress,',', '.'),2),
PARSENAME(REPLACE(OwnerAddress,',', '.'),1)

FROM PortfolioProject.dbo.NashvilleHousing

-- Adding additional columns for OwnerAddress split data

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'),1)


SELECT * 
FROM PortfolioProject..NashvilleHousing

-- Adjusting data in SoldAsVacant field to match (ex. Y to Yes, N to No)

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END



-- Removing Duplicates

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)


-- to remove duplicates replace Select with Delete
SELECT *
FROM RowNumCTE
WHERE row_num >1
ORDER BY PropertyAddress

-- Query that shows duplicate LegalReference number for different UniqueIDs

SELECT a.UniqueID, a.LegalReference, b.UniqueID, b.LegalReference
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.[UniqueID ] <> b.[UniqueID ]
AND a.LegalReference = b.LegalReference
--WHERE a.LegalReference = Null



-- Deleting PropertyAddress and OwnerAddress

SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress



