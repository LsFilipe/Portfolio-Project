select *
from DataCleaning..Housing

-- Cleaning data 


-- The data provided has many mistakes such as the wrong time (00:00) included in the date sale therefore making it unusable,
-- Therefore I firstly converted the column type into a date then used the Alter function to add a new column with date formate. 
-- Lastly I updated the orinal table


-- Sale date

select SaleDateConverted, CONVERT (Date, SaleDate)
from DataCleaning..Housing

ALTER Table Housing
Add SaleDateConverted Date;

Update Housing
Set SaleDateConverted = Convert (date, SaleDate)

--There are null vallues in some PropertyAddresses but this column could be populated if we have a reference
--Upon research and looking closely at the data parcelID is the same as PropertyAddress
-- Therefore if PropertyAddress has a null value and it has the same parcelID as another row
-- Then that property PropertyAddress can be used to populate the property Address.


-- Property Address

select*
from DataCleaning..Housing
--where PropertyAddress is null
order by ParcelID

select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
from DataCleaning..Housing A
JOIN DataCleaning..Housing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
where A.PropertyAddress is null

update A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
from DataCleaning..Housing A
JOIN DataCleaning..Housing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
where A.PropertyAddress is null

-- Here the Address, city are all mushed together, but separed by a comma as a dilimiter. 
-- The first paragraph with substrings is used to separete 2 commas where the delimiter is.
-- then the following paragraphs I created 2 new columns for the values above.


-- Breaking out Address into individual columns

Select PropertyAddress
From DataCleaning..Housing

Select 
SUBSTRING (propertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING (propertyAddress, CHARINDEX(',', PropertyAddress) +1 , Len(PropertyAddress)) as Address

From DataCleaning..Housing

USE DataCleaning
ALTER Table Housing
Add PropertySplit_Address Nvarchar(255);

Update Housing
Set PropertySplit_Address = SUBSTRING (propertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER Table Housing
Add PropertySplit_City nvarchar(255);

Update Housing
Set PropertySplit_City = SUBSTRING (propertyAddress, CHARINDEX(',', PropertyAddress) +1 , Len(PropertyAddress))

Select *
From DataCleaning..Housing

-- Here, the OwnerAddress column entails Address, City, State all in one 
-- Instead of substrings I used parsename but parsenames to separe the data only looks for dots and not commas as OVER
-- As a dilimiter therefore I had to replace it first. 
-- And the other paragraphs are for creating columns to fit the data.

-- Owner Address

Select OwnerAddress
From DataCleaning..Housing

Select 
PARSENAME (Replace(OwnerAddress,',','.'),3),
PARSENAME (Replace(OwnerAddress,',','.'),2),
PARSENAME (Replace(OwnerAddress,',','.'),1)
From DataCleaning..Housing

Drop OwnerSplit_Address
USE DataCleaning
ALTER Table Housing
Add Owner_Split_Address Nvarchar(255);

Update Housing
Set Owner_Split_Address = PARSENAME (Replace(OwnerAddress,',','.'),3)

ALTER Table Housing
Add OwnerSplit_City nvarchar(255);

Update Housing
Set OwnerSplit_City = PARSENAME (Replace(OwnerAddress,',','.'),2)

ALTER Table Housing
Add OwnerSplit_State Nvarchar(255);

Update Housing
Set OwnerSplit_State = PARSENAME (Replace(OwnerAddress,',','.'),1)

Select *
From DataCleaning..Housing

-- The row named soldAsVacant was not standardized, some rows had y as yes and n as no.
-- The funtion Case When was used to replace y for yes and n for n, then the same column was updated

-- Change Y and N to Yes and No in "sold as vacant" field

Select distinct (SoldAsVacant), Count (SoldAsVacant)
From DataCleaning..Housing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant, CASE when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	END
From DataCleaning..Housing

Update Housing
set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	END

-- Here in the first paragraph I found the rows that had been duplicated,
-- Then used the delete function.

--Romove Duplicates

WITH RowNumCTE AS(
select *, 
Row_number () OVER (
Partition by ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			Order by UniqueID
) Row_num
From DataCleaning..Housing
--order by ParcelID
)
Delete
from RowNumCTE
where Row_num > 1
--Order by PropertyAddress

-- All the columns that where rendered useless by the new columns I created had to be removed. 
-- The drop funtion was used to remove them

-- Delete unused columns

Select *
from DataCleaning..Housing

ALTER TABLE DataCleaning..Housing
Drop COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE DataCleaning..Housing
Drop COLUMN SaleDate, PropertySplitAddress, PropertySplitCity