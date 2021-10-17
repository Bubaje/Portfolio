--Convert Date
Select *
From PortfolioProject..NashvilleHousing
Alter Table PortfolioProject..NashvilleHousing
Drop Column SaleDateConverted

Alter Table PortfolioProject..NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject..NashvilleHousing
Set SaleDateConverted = CONVERT(date,SaleDate) 

-- Populate Property Address data
Select a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null 


-- Breaking out Address
Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress)) as Address2
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1)

Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress)) 

-- Breaking out Address using Parsename
Select 
Parsename(replace(OwnerAddress, ',','.'),3),
Parsename(replace(OwnerAddress, ',','.'),2),
Parsename(replace(OwnerAddress, ',','.'),1)
From PortfolioProject..NashvilleHousing
Order by ParcelID


Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitAddressOwner Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set PropertySplitAddressOwner = Parsename(replace(OwnerAddress, ',','.'),3)

Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitCityOwner Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set PropertySplitCityOwner = Parsename(replace(OwnerAddress, ',','.'),2)

Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitStateOwner Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set PropertySplitStateOwner = Parsename(replace(OwnerAddress, ',','.'),1)

Select *
From PortfolioProject..NashvilleHousing
Order by ParcelID

--Change Y and N to Yes an No in SoldAsVacant column

Select Distinct(SoldAsVacant),Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2



Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 END

From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
Set SoldAsVacant= Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 END



--Remowe duplicates

With RowNumCTE AS(
Select *,
	Row_number() Over(
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID)row_num
From PortfolioProject..NashvilleHousing)

Delete
From RowNumCTE
Where row_num >1


--Remowe Unused Columns
Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Select * 
From PortfolioProject..NashvilleHousing
Order by ParcelID