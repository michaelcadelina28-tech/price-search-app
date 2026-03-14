# 📱 Price Search App — Flutter (Offline)

Offline Android app para mag-search ng item prices mula sa iyong MySQL `items` table.

## MySQL Table Structure Supported
itemNo | Description | quantity | regularprice | retailprice | vendor | encoded

## SQL Query to Export CSV from SQLyog
```sql
SELECT itemNo, Description, quantity, regularprice, retailprice, vendor, encoded
FROM items
ORDER BY Description;
```
Right-click result → Export → CSV

## How to Build
```bash
flutter pub get
flutter build apk --release
```
APK: build/app/outputs/flutter-apk/app-release.apk

## Features
- Search by Description or Item Number
- Filter by Vendor
- Shows Retail Price + Wholesale Price
- Stock status indicator
- Shows last encoded/updated date
- 100% offline after CSV import
