--Data Cleaning Portfolio

Select *
From dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------

--Standardize Date Format

Select SaleDateConverted --CONVERT(Date,SaleDate)
From dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)

--------------------------------------------------------------------------------------------------------

--Populate Property Address Data

Select *
From dbo.NashvilleHousing
--Where PropertyAddress is NULL
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From dbo.NashvilleHousing a
Join dbo.NashvilleHousing b
      on a.ParcelID = b.ParcelID
	  And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From dbo.NashvilleHousing a
Join dbo.NashvilleHousing b
      on a.ParcelID = b.ParcelID
	  And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

------------------------------------------------------------------------------------------------------

--Breaking out Address into individual columns (Address, City, State)
	
Select PropertyAddress
From dbo.NashvilleHousing


Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address 
From dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select OwnerAddress
From dbo.NashvilleHousing

Select PARSENAME(REPLACE(OwnerAddress, ',', '.'), +3)
From dbo.NashvilleHousing

Select PARSENAME(REPLACE(OwnerAddress, ',', '.'), +2)
From dbo.NashvilleHousing

Select PARSENAME(REPLACE(OwnerAddress, ',', '.'), +1)
From dbo.NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), +3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), +2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), +1)

Select *
From dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------

--Change Y & N to YES & NO in SoldAsVacant Column

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From dbo.NashvilleHousing
Group by SoldAsVacant

Select SoldAsVacant
,Case When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' then 'No'
     Else SoldAsVacant
	 End
From dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' then 'No'
     Else SoldAsVacant
	 End

--------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates

With RowNumCTE AS(
Select *,
    ROW_NUMBER() Over (
	Partition by ParcelID,
                 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
				     UniqueID
					 )  row_num
From dbo.NashvilleHousing
)
Select * 
From RowNumCTE
Where row_num > 1
 --order by PropertyAddress

---------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns

Select *
From dbo.NashvilleHousing

Alter Table NashvilleHousing
Drop Column PropertyAddress, TaxDistrict, SaleDate, OwnerAddress






