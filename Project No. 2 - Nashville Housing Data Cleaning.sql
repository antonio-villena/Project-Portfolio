--Nashville Housing Data Cleaning

--Selecting the data with which we are going to work

SELECT *
FROM NashvilleHousing
ORDER BY 3

--Deleting rows with missing data

SELECT *
--DELETE
FROM NashvilleHousing
WHERE UniqueID = '29944'

--Changing date format

SELECT SaleDate, CONVERT(date, SaleDate) AS SaleDate2, CONVERT(datetime2, SaleDate) AS SaleDate3
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate date

--Populating property address data

SELECT *
FROM NashvilleHousing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) NewPropertyAddress
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

--Breaking out property address into individual columns

SELECT PropertyAddress
FROM NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress)) AS City
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress varchar(50)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity varchar(50)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress))


SELECT *
FROM NashvilleHousing

--Breaking out owner's address into individual columns

SELECT OwnerAddress
FROM NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ', ', '.'), 3) AS Address,
PARSENAME(REPLACE(OwnerAddress, ', ', '.'), 2) AS City,
PARSENAME(REPLACE(OwnerAddress, ', ', '.'), 1) AS State
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress varchar(50)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ', ', '.'), 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity varchar(50)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ', ', '.'), 2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState varchar(50)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ', ', '.'), 1)


SELECT *
FROM NashvilleHousing

--Changing 'Y' and 'N' to 'Yes' and 'No' in 'SoldAsVacant' field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS SoldAsVacantCount
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END AS SoldAsVacantFixed
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END

--Removing duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY
		ParcelID,
		PropertyAddress,
		SaleDate,
		SalePrice,
		LegalReference
		ORDER BY UniqueID
		) RowNum
FROM NashvilleHousing
)

SELECT *
--DELETE
FROM RowNumCTE
WHERE RowNum > 1
ORDER BY PropertyAddress

SELECT *
FROM NashvilleHousing

--Removing unused columns

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict