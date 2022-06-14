--Data cleaning in SQL

select *
from PortfolioProject..NashvilleHousing


-- Standardize Date Format

select SaledateConverted,CONVERT(Date,SaleDate)
from PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Add SaledateConverted Date;

 
Update PortfolioProject..NashvilleHousing
Set SaledateConverted =CONVERT (Date,SaleDate)


--populate property address data

select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
  JOIN PortfolioProject..NashvilleHousing b
  on a.ParcelID=b.ParcelID
  and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
  JOIN PortfolioProject..NashvilleHousing b
  on a.ParcelID=b.ParcelID
  and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out address into Individual Columns (Address,city,state)

select PropertyAddress
from PortfolioProject..NashvilleHousing


SELECT 
SUBSTRING(propertyaddress,1,CHARINDEX(',',PropertyAddress)-1)as Address
,SUBSTRING(propertyaddress,CHARINDEX(',',PropertyAddress)-1 ,len(PropertyAddress)) as City
from PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set PropertySplitAddress =SUBSTRING(propertyaddress,1,CHARINDEX(',',PropertyAddress)-1)


Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set PropertySplitCity =SUBSTRING(propertyaddress,CHARINDEX(',',PropertyAddress)+1 ,len(PropertyAddress))

Select * 
from PortfolioProject..NashvilleHousing



--Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct(SoldAsVacant),count(SoldAsVacant) 
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
ORDER BY 2

Select SoldAsVacant
,CASE when SoldAsVacant ='Y' then 'Yes'
      when SoldAsVacant ='N' then 'No'
	  else SoldAsVacant
	  END
from PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant ='Y' then 'Yes'
      when SoldAsVacant ='N' then 'No'
	  else SoldAsVacant
	  END
from PortfolioProject..NashvilleHousing



--Removing Duplicates

WITH RowNumCTE as(
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

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



Select *
From PortfolioProject.dbo.NashvilleHousing



-- Delete Unused Columns



Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
