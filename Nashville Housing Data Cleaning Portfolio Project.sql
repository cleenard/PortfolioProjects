---DATA CLEANING

Select *
From NashvilleHousingData

-- Standardize Date Format 
Select Sale_Date_Converted, convert (Date, SaleDate)
From portfolio_project..NashvilleHousingData

Update NashvilleHousingData
SET SaleDate = Convert(Date, SaleDate)

Alter Table portfolio_project..NashvilleHousingData
Add  Sale_Date_Converted Date; 

Update portfolio_project..NashvilleHousingData
SET Sale_Date_Converted = CONVERT(Date, SaleDate)

------------------------------------------------------------------------------------------------------

--Populate Property Adress data 

Select *
From portfolio_project..NashvilleHousingData
-- Where PropertyAddress is null 
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From portfolio_project..NashvilleHousingData a
JOIN portfolio_project..NashvilleHousingData b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID]<>b.[UniqueID]
Where a.PropertyAddress is NULL

-- Now we want to Update the table
Update a
SET PropertyAddress =ISNULL(a.PropertyAddress, b.PropertyAddress)
From portfolio_project..NashvilleHousingData a
JOIN portfolio_project..NashvilleHousingData b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID]<>b.[UniqueID]
Where a.PropertyAddress is NULL

-- If we went back and checked it, there will be no values 

Select *
From portfolio_project..NashvilleHousingData
Where PropertyAddress is null 
order by ParcelID

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From portfolio_project..NashvilleHousingData
-- Where PropertyAddress is null 
--order by ParcelID

Select 
SUBSTRING(PropertyAddress,1, CHARINDEX (',', PropertyAddress)-1) as Address 
, SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress) +1, LEN(PropertyAddress)) as Address 
from Portfolio_project..NashvilleHousingData

Alter Table portfolio_project..NashvilleHousingData
Add  PropertySplitAddress Nvarchar(255); 

Update portfolio_project..NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX (',', PropertyAddress)-1) 

Alter Table portfolio_project..NashvilleHousingData
Add  PropertySplitCity Nvarchar(255)

Update portfolio_project..NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From portfolio_project..NashvilleHousingData



Select OwnerAddress
From portfolio_project..NashvilleHousingData

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) 
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 
From portfolio_project..NashvilleHousingData

Alter Table portfolio_project..NashvilleHousingData
Add  OwnerSplitAddress Nvarchar(255); 

Update portfolio_project..NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 

Alter Table portfolio_project..NashvilleHousingData
Add  OwnerSplitCity Nvarchar(255)

Update portfolio_project..NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) 

Alter Table portfolio_project..NashvilleHousingData
Add  OwnerSplitState Nvarchar(255)

Update portfolio_project..NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From portfolio_project..NashvilleHousingData

-- Change 1 and 0 to Yes and No in "Sold as Vacant" field 

Select Distinct (SoldAsVacant), Count(SoldAsVacant)
From portfolio_project..NashvilleHousingData
Group by SoldAsVacant


--The data for SoldAsVacant was imported as bit, which led to an error with the CASE function. Hence, it was converted to Varchar. 
Alter Table portfolio_project..NashvilleHousingData
Alter Column SoldAsVacant VARCHAR(3) 

Select SoldAsVacant
, CASE When SoldASVacant='1' THEN 'Yes'
	ELSE 'No'
	END 
From portfolio_project..NashvilleHousingData


Update portfolio_project..NashvilleHousingData
SET SoldAsVacant = CASE When SoldASVacant='1' THEN 'Yes'
	ELSE 'No'
	END 

-----------------------------------------------------------------------------------------------------

-- Remove Duplicates 

WITH RowNumCTE AS (
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				PropertyAddress, 
				SalePrice, 
				SaleDate, 
				LegalReference
				ORDER BY 
					UniqueID
					) row_num
	 
From portfolio_project..NashvilleHousingData
--Order by ParcelID
)
Delete 
From RowNumCTE
Where row_num >1 
--Order By PropertyAddress

-- Now to check if it works 
WITH RowNumCTE AS (
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				PropertyAddress, 
				SalePrice, 
				SaleDate, 
				LegalReference
				ORDER BY 
					UniqueID
					) row_num
	 
From portfolio_project..NashvilleHousingData
--Order by ParcelID
)
select * 
From RowNumCTE
Where row_num >1 
Order By PropertyAddress

------------------------------------------------------------------------------------------

--Delete Unused Columns 

Select *
From portfolio_project..NashvilleHousingData

ALTER TABLE portfolio_project..NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE portfolio_project..NashvilleHousingData
DROP COLUMN SaleDateConverted, SaleDate

