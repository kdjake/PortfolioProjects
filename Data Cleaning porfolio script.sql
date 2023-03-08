

--cleaning Data in Sql Queries

Select *
From PortfolioProject..NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------

--Standardize Date format

Select SaleDateConverted, convert(date,SaleDate)
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

Alter Table NashvilleHousing
add SaledateConverted date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)

----------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Adress data 

Select *
From PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

----------------------------------------------------------------------------------------------------------------------------------
--Breaking out Adress into Individual Columns (Address, city, state)

Select PropertyAddress
From PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress) -1 ) as address,
SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as address

From PortfolioProject..NashvilleHousing


ALTER Table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress) -1 )

ALTER Table NashvilleHousing
add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET  PropertySplitCity = SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress) + 1 , LEN(PropertyAddress))


SELECT *
From PortfolioProject..NashvilleHousing





SELECT OwnerAddress
From PortfolioProject..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing



ALTER Table NashvilleHousing
add OwnerySplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerySplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER Table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET  OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER Table NashvilleHousing
add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT *
From PortfolioProject..NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------

-----change Y and N to YES and NO in "Solid  as Vacat" field

SELECT Distinct(SoldAsVacant), count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2



SELECT SoldAsVacant,
 CASE	when SoldAsVacant = 'Y' THEN 'YES'
		when SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
From PortfolioProject..NashvilleHousing



Update NashvilleHousing
SET SoldAsVacant = CASE	when SoldAsVacant = 'Y' THEN 'YES'
		when SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END

----------------------------------------------------------------------------------------------------------------------------------
--Remove Duplicates 
with RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				Saledate,
				LegalReference
				ORDER BY 
					UniqueID
					)	row_num

FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
SELECT * 
FROM RowNumCTE
where row_num > 1
--order by PropertyAddress

----------------------------------------------------------------------------------------------------------------------------------

--- Delete Unused columns 


SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, taxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN Saledate