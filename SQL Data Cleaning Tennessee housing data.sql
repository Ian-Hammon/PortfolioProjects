SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--Change Sale Date Column

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

-- For some reason the code below did not work,

--Update NashvilleHousing
--SET SaleDate = CONVERT(Date, SaleDate)

-- Since the code above did not work,I added a new column with the desired format

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate Property Address data

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL( a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID]<>b.[UniqueID]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL( a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID]<>b.[UniqueID]
WHERE a.PropertyAddress is null

--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address

FROM PortfolioProject.dbo.NashvilleHousing;



SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address

FROM PortfolioProject.dbo.NashvilleHousing;



ALTER TABLE NashvilleHousing
ADD PropertyStreetAddress NVARCHAR(255);

Update NashvilleHousing
SET PropertyStreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)



ALTER TABLE NashvilleHousing
ADD PropertyCity NVARCHAR(255);

Update NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))







SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',','.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',','.') , 1)
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerStreetAddress NVARCHAR(255);

Update NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',','.') , 3)



ALTER TABLE NashvilleHousing
ADD OwnerCity NVARCHAR(255);

Update NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',','.') ,2)


ALTER TABLE NashvilleHousing
ADD OwnerState NVARCHAR(255);

Update NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',','.') , 1)


--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
Order by 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant='Y' THEN 'YES'
	   WHEN SoldAsVacant='N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject.dbo.NashvilleHousing



Update NashvilleHousing
SET SoldAsVacant=
CASE WHEN SoldAsVacant='Y' THEN 'YES'
	   WHEN SoldAsVacant='N' THEN 'NO'
	   ELSE SoldAsVacant
	   END

-- Remove Duplicates

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
FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
--DELETE
SELECT *
FROM RowNumCTE
WHERE row_num >1
ORDER BY PropertyAddress


--Delete Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate