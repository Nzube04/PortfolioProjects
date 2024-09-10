-- DATA CLEANING WITH SQL

Select *
FROM PortfolioProject..NashvilleHousing

-- Standardize the SaleDate Column

Select SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)


Alter Table PortfolioProject..NashvilleHousing
Add SaleDateConverted Date

Update PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted, SaleDate
FROM PortfolioProject.dbo.NashvilleHousing



--Populate Property Address Data (Taking care of the Null Values in the PropertyAddress Column)

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
Where a.PropertyAddress is null
AND a.UniqueID <> b.UniqueID

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
Where a.PropertyAddress is null
AND a.UniqueID <> b.UniqueID

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is null
Order BY ParcelID


-- Breaking the Address (PropertyAdrress and OwnerAddress) into individual Columns

SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS PropertySplitAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS PropertySplitCity
FROM PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Varchar(255)

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Varchar(255)

Update PortfolioProject.dbo.NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT PropertyAddress,
PropertySplitAddress,
PropertySplitCity
FROM PortfolioProject.dbo.NashvilleHousing


--Split OwnerAddress

SELECT OwnerAddress,
PARSENAME(Replace(OwnerAddress, ',', '.'),3),
PARSENAME(Replace(OwnerAddress, ',', '.'),2),
PARSENAME(Replace(OwnerAddress, ',', '.'),1)
FROM PortfolioProject.dbo.NashvilleHousing 

Alter Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress varchar(255), 
    OwnerSplitCity varchar(255),
    OwnerSplitState varchar(255)

Update PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'),3),
    OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'),2),
	OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'),1)



	-- Standardize SoldAsVacant Column

	SELECT Distinct(SoldAsVacant), count(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant

SELECT Distinct(SoldAsVacant), 
Case When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
END
FROM PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant

Update PortfolioProject.dbo.NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
END


-- Remove Duplicate Columns

With RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER(
Partition By ParcelID,
             PropertyAddress,
			 SaleDate,
			 SalePrice,
			 LegalReference,
			 OwnerAddress
Order By     UniqueID) Row_Num
FROM PortfolioProject.dbo.NashvilleHousing)

Delete
From RowNumCTE
Where Row_Num > 1

-- Standardize Column Names

Alter Table PortfolioProject.dbo.NashvilleHousing
ADD PropertyCity Varchar(255),
    OwnerCity Varchar(255),
	OwnerState Varchar(255)

Update PortfolioProject.dbo.NashvilleHousing
Set PropertyAddress = PropertySplitAddress,
    PropertyCity = PropertySplitCity,
	OwnerAddress = OwnerSplitAddress,
	OwnerCity = OwnerSplitCity,
	OwnerState = OwnerSplitState



-- Delete Unused Columns

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column SaleDate, 
       PropertySplitAddress, 
	   PropertySplitCity, 
	   OwnerSplitAddress, 
	   OwnerSplitCity, 
	   OwnerSplitState