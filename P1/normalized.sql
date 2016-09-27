CREATE TABLE R0(
Store Integer primary key,
Type Char(1),
Size Integer
);
CREATE TABLE R1(
WeekDate Date primary key,
IsHoliday Boolean
);
CREATE TABLE R2(
Store Integer,
WeekDate Date,
Temperature Real,
FuelPrice Real,
CPI Real,
UnemploymentRate Real,
PRIMARY KEY(Store, WeekDate),
FOREIGN KEY(WeekDate) REFERENCES R1(WeekDate),
FOREIGN KEY(Store) REFERENCES R0(Store)
);
CREATE TABLE R3(
Store Integer,
Dept Integer,
WeekDate Date,
WeeklySales Real,
PRIMARY KEY(Dept, Store, WeekDate),
FOREIGN KEY(WeekDate) REFERENCES R1(WeekDate),
FOREIGN KEY(Store) REFERENCES R0(Store),
FOREIGN KEY(Store, WeekDate) REFERENCES R2(Store, WeekDate)
);
