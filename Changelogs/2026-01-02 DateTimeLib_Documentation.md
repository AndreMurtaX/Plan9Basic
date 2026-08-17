# Plan9Basic - DateTimeLib Documentation

## Date and Time Library Reference Manual

**Version:** 1.0  
**Date:** January 2026

---

## Table of Contents

1. [Overview](#overview)
2. [Understanding Date/Time Values](#understanding-datetime-values)
3. [Getting Current Date and Time](#getting-current-date-and-time)
4. [Conversion Functions](#conversion-functions)
5. [Date Component Extraction](#date-component-extraction)
6. [Time Component Extraction](#time-component-extraction)
7. [Date Arithmetic - Differences](#date-arithmetic---differences)
8. [Date Arithmetic - Incrementing](#date-arithmetic---incrementing)
9. [Calendar Information](#calendar-information)
10. [Boolean Test Functions](#boolean-test-functions)
11. [Custom Formatting](#custom-formatting)
12. [Complete Examples](#complete-examples)
13. [Quick Reference](#quick-reference)

---

## Overview

The DateTimeLib library provides comprehensive support for date and time operations in Plan9Basic. It allows you to:

- Get the current date and time
- Convert between date/time values and strings
- Extract components (year, month, day, hour, minute, second)
- Calculate differences between dates
- Add or subtract time intervals
- Check calendar properties (leap years, days in month, etc.)
- Format dates and times for display

---

## Understanding Date/Time Values

In Plan9Basic, dates and times are represented as **numeric values** (floating-point numbers):

- The **integer part** represents the date (days since December 30, 1899)
- The **fractional part** represents the time (fraction of a 24-hour day)

```basic
dt = now()              ' e.g., 45658.75 means January 2, 2025 at 6:00 PM
println "Raw value: "; dt

' The value 0.5 represents noon (12:00:00)
' The value 0.25 represents 6:00 AM
' The value 0.75 represents 6:00 PM
```

### Default String Formats

When converting to strings, Plan9Basic uses these standard formats:

| Type | Format | Example |
|------|--------|---------|
| Date | `yyyy-MM-dd` | `2025-01-02` |
| Time | `hh:mm:ss.zzz` | `14:30:45.123` |
| DateTime | `yyyy-MM-dd hh:mm:ss` | `2025-01-02 14:30:45` |

---

## Getting Current Date and Time

### now()

Returns the current date and time as a numeric value.

**Syntax:**
```basic
dateTimeValue = now()
```

**Returns:** Numeric value representing current date and time

**Example:**
```basic
dt = now()
println "Current date/time value: "; dt
println "Formatted: "; datetimetostr$(dt)
```

---

### date()

Returns the current date as a numeric value (time portion is zero).

**Syntax:**
```basic
dateValue = date()
```

**Returns:** Numeric value representing current date at midnight

**Example:**
```basic
d = date()
println "Today's date value: "; d
println "Formatted: "; datetostr$(d)
```

---

### date$()

Returns the current date as a formatted string.

**Syntax:**
```basic
dateString$ = date$()
```

**Returns:** String in `yyyy-MM-dd` format

**Example:**
```basic
println "Today is: "; date$()
' Output: Today is: 2025-01-02
```

---

### time()

Returns the current time as a numeric value (date portion is zero).

**Syntax:**
```basic
timeValue = time()
```

**Returns:** Numeric value representing current time (fractional part of a day)

**Example:**
```basic
t = time()
println "Current time value: "; t
println "Formatted: "; timetostr$(t)
```

---

### time$()

Returns the current time as a formatted string.

**Syntax:**
```basic
timeString$ = time$()
```

**Returns:** String in `hh:mm:ss.zzz` format

**Example:**
```basic
println "Current time: "; time$()
' Output: Current time: 14:30:45.123
```

---

### gettime()

Returns the current time as a numeric value. Functionally identical to `time()`.

**Syntax:**
```basic
timeValue = gettime()
```

---

### datetime$()

Returns the current date and time as a formatted string.

**Syntax:**
```basic
dateTimeString$ = datetime$()
```

**Returns:** String in `yyyy-MM-dd hh:mm:ss` format

**Example:**
```basic
println "Now: "; datetime$()
' Output: Now: 2025-01-02 14:30:45
```

---

### today()

Returns today's date as a numeric value (at midnight).

**Syntax:**
```basic
todayValue = today()
```

**Example:**
```basic
t = today()
println "Today: "; datetostr$(t)
```

---

### yesterday()

Returns yesterday's date as a numeric value.

**Syntax:**
```basic
yesterdayValue = yesterday()
```

**Example:**
```basic
y = yesterday()
println "Yesterday was: "; datetostr$(y)
```

---

### tomorrow()

Returns tomorrow's date as a numeric value.

**Syntax:**
```basic
tomorrowValue = tomorrow()
```

**Example:**
```basic
t = tomorrow()
println "Tomorrow will be: "; datetostr$(t)
```

---

## Conversion Functions

### datetostr$()

Converts a date value to a string.

**Syntax:**
```basic
dateString$ = datetostr$(dateValue)
```

**Parameters:**
- `dateValue`: Numeric date/time value

**Returns:** String in `yyyy-MM-dd` format

**Example:**
```basic
dt = now()
println datetostr$(dt)    ' Output: 2025-01-02
```

---

### strtodate()

Converts a date string to a numeric value.

**Syntax:**
```basic
dateValue = strtodate(dateString$)
```

**Parameters:**
- `dateString$`: Date string in `yyyy-MM-dd` format

**Returns:** Numeric date value

**Example:**
```basic
d = strtodate("2025-12-25")
println "Christmas 2025: "; datetostr$(d)
```

---

### timetostr$()

Converts a time value to a string.

**Syntax:**
```basic
timeString$ = timetostr$(timeValue)
```

**Parameters:**
- `timeValue`: Numeric time value

**Returns:** String in `hh:mm:ss.zzz` format

**Example:**
```basic
t = time()
println timetostr$(t)    ' Output: 14:30:45.123
```

---

### strtotime()

Converts a time string to a numeric value.

**Syntax:**
```basic
timeValue = strtotime(timeString$)
```

**Parameters:**
- `timeString$`: Time string (e.g., `"14:30:00"`)

**Returns:** Numeric time value

**Example:**
```basic
t = strtotime("09:30:00")
println "9:30 AM as value: "; t
```

---

### datetimetostr$()

Converts a date/time value to a string.

**Syntax:**
```basic
dateTimeString$ = datetimetostr$(dateTimeValue)
```

**Parameters:**
- `dateTimeValue`: Numeric date/time value

**Returns:** String in `yyyy-MM-dd hh:mm:ss` format

**Example:**
```basic
dt = now()
println datetimetostr$(dt)    ' Output: 2025-01-02 14:30:45
```

---

### strtodatetime()

Converts a date/time string to a numeric value.

**Syntax:**
```basic
dateTimeValue = strtodatetime(dateTimeString$)
```

**Parameters:**
- `dateTimeString$`: Date/time string in `yyyy-MM-dd hh:mm:ss` format

**Returns:** Numeric date/time value

**Example:**
```basic
dt = strtodatetime("2025-07-04 12:00:00")
println "Independence Day noon: "; datetimetostr$(dt)
```

---

## Date Component Extraction

### yearof()

Extracts the year from a date/time value.

**Syntax:**
```basic
year = yearof(dateTimeValue)
```

**Returns:** Year as a number (e.g., 2025)

**Example:**
```basic
dt = now()
println "Year: "; yearof(dt)    ' Output: Year: 2025
```

---

### monthof() / monthoftheyear()

Extracts the month from a date/time value.

**Syntax:**
```basic
month = monthof(dateTimeValue)
month = monthoftheyear(dateTimeValue)
```

**Returns:** Month number (1 = January, 12 = December)

**Example:**
```basic
dt = now()
println "Month: "; monthof(dt)    ' Output: Month: 1 (for January)
```

---

### dayof() / dayofthemonth()

Extracts the day of the month from a date/time value.

**Syntax:**
```basic
day = dayof(dateTimeValue)
day = dayofthemonth(dateTimeValue)
```

**Returns:** Day of month (1-31)

**Example:**
```basic
dt = now()
println "Day: "; dayof(dt)    ' Output: Day: 2
```

---

### dayofweek()

Returns the day of the week (Sunday = 1).

**Syntax:**
```basic
dow = dayofweek(dateTimeValue)
```

**Returns:** Day of week (1 = Sunday, 2 = Monday, ..., 7 = Saturday)

**Example:**
```basic
dt = now()
dow = dayofweek(dt)

select case dow
    case 1: println "Sunday"
    case 2: println "Monday"
    case 3: println "Tuesday"
    case 4: println "Wednesday"
    case 5: println "Thursday"
    case 6: println "Friday"
    case 7: println "Saturday"
endselect
```

---

### dayoftheweek()

Returns the day of the week using ISO standard (Monday = 1).

**Syntax:**
```basic
dow = dayoftheweek(dateTimeValue)
```

**Returns:** Day of week (1 = Monday, 2 = Tuesday, ..., 7 = Sunday)

**Example:**
```basic
dt = now()
dow = dayoftheweek(dt)
println "ISO day of week: "; dow
```

---

### dayoftheyear()

Returns the day number within the year.

**Syntax:**
```basic
doy = dayoftheyear(dateTimeValue)
```

**Returns:** Day of year (1-366)

**Example:**
```basic
dt = now()
println "Day of year: "; dayoftheyear(dt)
' January 2nd would output: Day of year: 2
```

---

### weekof() / weekoftheyear()

Returns the week number within the year.

**Syntax:**
```basic
week = weekof(dateTimeValue)
week = weekoftheyear(dateTimeValue)
```

**Returns:** Week number (1-53)

**Example:**
```basic
dt = now()
println "Week of year: "; weekof(dt)
```

---

### weekofthemonth()

Returns the week number within the month.

**Syntax:**
```basic
week = weekofthemonth(dateTimeValue)
```

**Returns:** Week of month (1-5)

**Example:**
```basic
dt = now()
println "Week of month: "; weekofthemonth(dt)
```

---

## Time Component Extraction

### hourof()

Extracts the hour from a date/time value.

**Syntax:**
```basic
hour = hourof(dateTimeValue)
```

**Returns:** Hour (0-23)

**Example:**
```basic
dt = now()
println "Hour: "; hourof(dt)    ' e.g., Hour: 14
```

---

### minuteof()

Extracts the minute from a date/time value.

**Syntax:**
```basic
minute = minuteof(dateTimeValue)
```

**Returns:** Minute (0-59)

**Example:**
```basic
dt = now()
println "Minute: "; minuteof(dt)    ' e.g., Minute: 30
```

---

### secondof()

Extracts the second from a date/time value.

**Syntax:**
```basic
second = secondof(dateTimeValue)
```

**Returns:** Second (0-59)

**Example:**
```basic
dt = now()
println "Second: "; secondof(dt)    ' e.g., Second: 45
```

---

### millisecondof()

Extracts the millisecond from a date/time value.

**Syntax:**
```basic
ms = millisecondof(dateTimeValue)
```

**Returns:** Millisecond (0-999)

**Example:**
```basic
dt = now()
println "Millisecond: "; millisecondof(dt)
```

---

## Date Arithmetic - Differences

Plan9Basic provides two types of difference functions:

- **"Between" functions**: Return **whole units** (integer count)
- **"Span" functions**: Return **fractional units** (precise difference)

### Days

```basic
' Whole days between two dates
wholeDays = daysbetween(date1, date2)

' Fractional days between two dates
fractionalDays = dayspan(date1, date2)
```

**Example:**
```basic
d1 = strtodate("2025-01-01")
d2 = strtodate("2025-01-15")

println "Days between: "; daysbetween(d1, d2)    ' Output: 14
println "Day span: "; dayspan(d1, d2)            ' Output: 14.0
```

---

### Hours

```basic
' Whole hours between two date/times
wholeHours = hoursbetween(dt1, dt2)

' Fractional hours between two date/times
fractionalHours = hourspan(dt1, dt2)
```

**Example:**
```basic
dt1 = strtodatetime("2025-01-01 10:00:00")
dt2 = strtodatetime("2025-01-01 14:30:00")

println "Hours between: "; hoursbetween(dt1, dt2)    ' Output: 4
println "Hour span: "; hourspan(dt1, dt2)            ' Output: 4.5
```

---

### Minutes

```basic
' Whole minutes between two date/times
wholeMinutes = minutesbetween(dt1, dt2)

' Fractional minutes between two date/times
fractionalMinutes = minutespan(dt1, dt2)
```

---

### Seconds

```basic
' Whole seconds between two date/times
wholeSeconds = secondsbetween(dt1, dt2)

' Fractional seconds between two date/times
fractionalSeconds = secondspan(dt1, dt2)
```

**Example:**
```basic
dt1 = strtodatetime("2025-01-02 10:00:00")
dt2 = strtodatetime("2025-01-02 10:05:30")

println "Seconds between: "; secondsbetween(dt1, dt2)    ' Output: 330
println "Second span: "; secondspan(dt1, dt2)            ' Output: 330.0
```

---

### Milliseconds

```basic
' Whole milliseconds between two date/times
wholeMs = millisecondsbetween(dt1, dt2)

' Fractional milliseconds between two date/times
fractionalMs = millisecondspan(dt1, dt2)
```

---

### Weeks

```basic
' Whole weeks between two dates
wholeWeeks = weeksbetween(date1, date2)

' Fractional weeks between two dates
fractionalWeeks = weekspan(date1, date2)
```

**Example:**
```basic
d1 = strtodate("2025-01-01")
d2 = strtodate("2025-01-22")

println "Weeks between: "; weeksbetween(d1, d2)    ' Output: 3
println "Week span: "; weekspan(d1, d2)            ' Output: 3.0
```

---

### Months

```basic
' Whole months between two dates
wholeMonths = monthsbetween(date1, date2)

' Fractional months between two dates
fractionalMonths = monthspan(date1, date2)
```

**Example:**
```basic
d1 = strtodate("2025-01-15")
d2 = strtodate("2025-04-15")

println "Months between: "; monthsbetween(d1, d2)    ' Output: 2 (approximation)
println "Month span: "; monthspan(d1, d2)            ' Output: ~2.96 (fractional)
```

---

### Years

```basic
' Whole years between two dates
wholeYears = yearsbetween(date1, date2)

' Fractional years between two dates
fractionalYears = yearspan(date1, date2)
```

**Example:**
```basic
birthdate = strtodate("1990-06-15")
today = today()

println "Age in years: "; yearsbetween(birthdate, today)
println "Precise age: "; yearspan(birthdate, today)
```

---

## Date Arithmetic - Incrementing

These functions add (or subtract, using negative values) time units to a date/time value.

### incday()

Adds days to a date/time value.

**Syntax:**
```basic
newDate = incday(dateTimeValue, numberOfDays)
```

**Example:**
```basic
today = today()
nextWeek = incday(today, 7)
lastWeek = incday(today, -7)

println "Today: "; datetostr$(today)
println "Next week: "; datetostr$(nextWeek)
println "Last week: "; datetostr$(lastWeek)
```

---

### inchour()

Adds hours to a date/time value.

**Syntax:**
```basic
newDateTime = inchour(dateTimeValue, numberOfHours)
```

**Example:**
```basic
dt = now()
later = inchour(dt, 3)
println "3 hours from now: "; datetimetostr$(later)
```

---

### incminute()

Adds minutes to a date/time value.

**Syntax:**
```basic
newDateTime = incminute(dateTimeValue, numberOfMinutes)
```

**Example:**
```basic
dt = now()
later = incminute(dt, 45)
println "45 minutes from now: "; datetimetostr$(later)
```

---

### incsecond()

Adds seconds to a date/time value.

**Syntax:**
```basic
newDateTime = incsecond(dateTimeValue, numberOfSeconds)
```

**Example:**
```basic
dt = now()
later = incsecond(dt, 90)
println "90 seconds from now: "; datetimetostr$(later)
```

---

### incmillisecond()

Adds milliseconds to a date/time value.

**Syntax:**
```basic
newDateTime = incmillisecond(dateTimeValue, numberOfMilliseconds)
```

---

### incweek()

Adds weeks to a date/time value.

**Syntax:**
```basic
newDate = incweek(dateTimeValue, numberOfWeeks)
```

**Example:**
```basic
today = today()
twoWeeksLater = incweek(today, 2)
println "Two weeks from today: "; datetostr$(twoWeeksLater)
```

---

### incyear()

Adds years to a date/time value.

**Syntax:**
```basic
newDate = incyear(dateTimeValue, numberOfYears)
```

**Example:**
```basic
today = today()
nextYear = incyear(today, 1)
fiveYearsAgo = incyear(today, -5)

println "Next year: "; datetostr$(nextYear)
println "Five years ago: "; datetostr$(fiveYearsAgo)
```

---

## Calendar Information

### daysinamonth()

Returns the number of days in a specific month.

**Syntax:**
```basic
days = daysinamonth(year, month)
```

**Parameters:**
- `year`: The year (e.g., 2025)
- `month`: The month (1-12)

**Example:**
```basic
println "Days in February 2024: "; daysinamonth(2024, 2)    ' Output: 29 (leap year)
println "Days in February 2025: "; daysinamonth(2025, 2)    ' Output: 28
```

---

### daysinmonth()

Returns the number of days in the month of a given date.

**Syntax:**
```basic
days = daysinmonth(dateTimeValue)
```

**Example:**
```basic
dt = now()
println "Days in current month: "; daysinmonth(dt)
```

---

### daysinayear()

Returns the number of days in a specific year.

**Syntax:**
```basic
days = daysinayear(year)
```

**Example:**
```basic
println "Days in 2024: "; daysinayear(2024)    ' Output: 366 (leap year)
println "Days in 2025: "; daysinayear(2025)    ' Output: 365
```

---

### daysinyear()

Returns the number of days in the year of a given date.

**Syntax:**
```basic
days = daysinyear(dateTimeValue)
```

**Example:**
```basic
dt = now()
println "Days in current year: "; daysinyear(dt)
```

---

### weeksinayear()

Returns the number of weeks in a specific year.

**Syntax:**
```basic
weeks = weeksinayear(year)
```

**Example:**
```basic
println "Weeks in 2025: "; weeksinayear(2025)
```

---

### weeksinyear()

Returns the number of weeks in the year of a given date.

**Syntax:**
```basic
weeks = weeksinyear(dateTimeValue)
```

**Example:**
```basic
dt = now()
println "Weeks in current year: "; weeksinyear(dt)
```

---

## Boolean Test Functions

These functions return `1` for true and `0` for false.

### isam()

Tests if the time is in the AM (before noon).

**Syntax:**
```basic
result = isam(dateTimeValue)
```

**Example:**
```basic
dt = now()
if isam(dt) then
    println "Good morning!"
else
    println "Good afternoon/evening!"
endif
```

---

### ispm()

Tests if the time is in the PM (noon or later).

**Syntax:**
```basic
result = ispm(dateTimeValue)
```

**Example:**
```basic
dt = now()
if ispm(dt) then
    println "It's afternoon or evening"
endif
```

---

### isinleapyear()

Tests if a date falls within a leap year.

**Syntax:**
```basic
result = isinleapyear(dateTimeValue)
```

**Example:**
```basic
d = strtodate("2024-06-15")
if isinleapyear(d) then
    println "2024 is a leap year"
endif
```

---

### istoday()

Tests if a date is today.

**Syntax:**
```basic
result = istoday(dateTimeValue)
```

**Example:**
```basic
eventDate = strtodate("2025-01-02")
if istoday(eventDate) then
    println "The event is TODAY!"
else
    println "The event is not today"
endif
```

---

### issameday()

Tests if two date/time values represent the same calendar day.

**Syntax:**
```basic
result = issameday(dateTimeValue1, dateTimeValue2)
```

**Example:**
```basic
dt1 = strtodatetime("2025-01-02 09:00:00")
dt2 = strtodatetime("2025-01-02 18:30:00")

if issameday(dt1, dt2) then
    println "Both times are on the same day"
endif
```

---

## Custom Formatting

### formatdatetime$()

Formats a date/time value using a custom format string.

**Syntax:**
```basic
formattedString$ = formatdatetime$(formatPattern$, dateTimeValue)
```

**Parameters:**
- `formatPattern$`: A format string using format specifiers
- `dateTimeValue`: The date/time value to format

### Format Specifiers

| Specifier | Description | Example |
|-----------|-------------|---------|
| `yyyy` | 4-digit year | 2025 |
| `yy` | 2-digit year | 25 |
| `MM` | 2-digit month | 01, 12 |
| `M` | Month without leading zero | 1, 12 |
| `dd` | 2-digit day | 01, 31 |
| `d` | Day without leading zero | 1, 31 |
| `hh` | 2-digit hour (24-hour) | 00, 23 |
| `h` | Hour without leading zero | 0, 23 |
| `nn` | 2-digit minute | 00, 59 |
| `ss` | 2-digit second | 00, 59 |
| `zzz` | 3-digit millisecond | 000, 999 |
| `ddd` | Abbreviated day name | Mon, Tue |
| `dddd` | Full day name | Monday |
| `MMM` | Abbreviated month name | Jan, Dec |
| `MMMM` | Full month name | January |
| `AM/PM` | AM or PM indicator | AM, PM |

**Examples:**

```basic
dt = now()

' US format
println formatdatetime$("MM/dd/yyyy", dt)

' European format
println formatdatetime$("dd/MM/yyyy", dt)

' Full date with time
println formatdatetime$("dddd, MMMM d, yyyy 'at' hh:nn AM/PM", dt)

' ISO format
println formatdatetime$("yyyy-MM-dd'T'hh:nn:ss", dt)

' Time only
println formatdatetime$("hh:nn:ss", dt)
```

---

## Complete Examples

### Example 1: Age Calculator

```basic
' Age Calculator
println "=== Age Calculator ==="

' Set a birthdate
birthdate = strtodate("1971-12-11")
today = today()

' Calculate age
years = yearsbetween(birthdate, today)
println "Birthdate: "; datetostr$(birthdate)
println "Today: "; datetostr$(today)
println "Age: "; years; " years"

' More precise age
preciseAge = yearspan(birthdate, today)
println "Precise age: "; preciseAge; " years"

' Days until next birthday
thisYearBirthday = strtodate(formatdatetime$("yyyy", today) + "-06-15")
if thisYearBirthday < today then
    ' Birthday has passed, calculate for next year
    nextBirthday = incyear(thisYearBirthday, 1)
else
    nextBirthday = thisYearBirthday
endif

daysUntil = daysbetween(today, nextBirthday)
println "Days until next birthday: "; daysUntil
```

---

### Example 2: Meeting Scheduler

```basic
' Meeting Scheduler
println "=== Meeting Scheduler ==="

' Schedule a meeting for next Monday at 10:00 AM
today = today()
currentDow = dayoftheweek(today)  ' ISO: 1=Monday

' Calculate days until next Monday
if currentDow = 1 then
    daysUntilMonday = 7  ' If today is Monday, next Monday
else
    daysUntilMonday = 8 - currentDow
endif

meetingDate = incday(today, daysUntilMonday)
meetingTime = strtotime("10:00:00")
meetingDateTime = meetingDate + meetingTime

println "Meeting scheduled for:"
println formatdatetime$("dddd, MMMM d, yyyy 'at' hh:mm AM/PM", meetingDateTime)

' Reminder 1 hour before
reminderTime = inchour(meetingDateTime, -1)
println "Reminder at: "; formatdatetime$("hh:mm AM/PM", reminderTime)
```

---

### Example 3: Countdown Timer

```basic
' Countdown to New Year
println "=== New Year Countdown ==="

today = now()
currentYear = yearof(today)
newYear = strtodatetime(formatdatetime$("yyyy", incyear(today, 1)) + "-01-01 00:00:00")

println "Current date/time: "; datetimetostr$(today)
println "New Year: "; datetimetostr$(newYear)
println ""

days = daysbetween(today, newYear)
hours = hoursbetween(today, newYear) - (days * 24)
minutes = minutesbetween(today, newYear) - (daysbetween(today, newYear) * 24 * 60) - (hours * 60)

println "Time until New Year:"
println days; " days, "; hours; " hours, "; minutes; " minutes"
```

---

### Example 4: Working Days Calculator

```basic
' Count working days between two dates
function countWorkDays(startDate, endDate) local workDays, currentDate, dow
    workDays = 0
    currentDate = startDate
    
    while currentDate <= endDate
        dow = dayoftheweek(currentDate)  ' ISO: 1=Mon, 7=Sun
        
        ' If not Saturday (6) or Sunday (7)
        if dow < 6 then
            workDays = workDays + 1
        endif
        
        currentDate = incday(currentDate, 1)
    endwhile
    
    return workDays
endfunction

' Test the function
d1 = strtodate("2025-01-01")
d2 = strtodate("2025-01-31")

println "From: "; datetostr$(d1)
println "To: "; datetostr$(d2)
println "Working days: "; countWorkDays(d1, d2)
```

---

### Example 5: Date Validation and Leap Year Check

```basic
' Leap Year Information
println "=== Leap Year Checker ==="

for year = 2020 to 2030
    d = strtodate(Str$(year) + "-01-01")
    
    if isinleapyear(d) = 1 then
        leapStr$ = "YES"
        febDays = 29
    else
        leapStr$ = "NO"
        febDays = 28
    endif
    
    println year; ": Leap year? "; leapStr$; " ("; daysinayear(year); " days, Feb has "; febDays; " days)"
next
```

---

### Example 6: Digital Clock Display

```basic
' Simple Digital Clock (displays current time components)
println "=== Current Time Details ==="

dt = now()

println "Date: "; formatdatetime$("dddd, MMMM d, yyyy", dt)
println ""
println "Time Components:"
println "  Hour: "; hourof(dt)
println "  Minute: "; minuteof(dt)
println "  Second: "; secondof(dt)
println "  Millisecond: "; millisecondof(dt)
println ""

if isam(dt) = 1 then
    println "Period: AM (Morning)"
else
    println "Period: PM (Afternoon/Evening)"
endif

println ""
println "Calendar Position:"
println "  Day of week: "; dayofweek(dt); " (1=Sun, 7=Sat)"
println "  Day of year: "; dayoftheyear(dt)
println "  Week of year: "; weekoftheyear(dt)
```

---

## Quick Reference

### Getting Current Date/Time
```basic
now()           ' Current date and time (numeric)
date()          ' Current date only (numeric)
date$()         ' Current date as string "yyyy-MM-dd"
time()          ' Current time only (numeric)
time$()         ' Current time as string "hh:mm:ss.zzz"
datetime$()     ' Current date/time as string
today()         ' Today at midnight
yesterday()     ' Yesterday at midnight
tomorrow()      ' Tomorrow at midnight
```

### String Conversion
```basic
datetostr$(n)        ' Date number → "yyyy-MM-dd"
strtodate(s$)        ' "yyyy-MM-dd" → date number
timetostr$(n)        ' Time number → "hh:mm:ss.zzz"
strtotime(s$)        ' "hh:mm:ss" → time number
datetimetostr$(n)    ' DateTime number → string
strtodatetime(s$)    ' String → datetime number
formatdatetime$(fmt$, n)  ' Custom formatted string
```

### Extracting Components
```basic
yearof(n)            ' Year (e.g., 2025)
monthof(n)           ' Month (1-12)
dayof(n)             ' Day of month (1-31)
dayofweek(n)         ' Day of week (1=Sun, 7=Sat)
dayoftheweek(n)      ' Day of week ISO (1=Mon, 7=Sun)
dayoftheyear(n)      ' Day of year (1-366)
weekof(n)            ' Week of year
hourof(n)            ' Hour (0-23)
minuteof(n)          ' Minute (0-59)
secondof(n)          ' Second (0-59)
millisecondof(n)     ' Millisecond (0-999)
```

### Differences (Whole Units)
```basic
daysbetween(n1, n2)
hoursbetween(n1, n2)
minutesbetween(n1, n2)
secondsbetween(n1, n2)
millisecondsbetween(n1, n2)
weeksbetween(n1, n2)
monthsbetween(n1, n2)
yearsbetween(n1, n2)
```

### Differences (Fractional)
```basic
dayspan(n1, n2)
hourspan(n1, n2)
minutespan(n1, n2)
secondspan(n1, n2)
millisecondspan(n1, n2)
weekspan(n1, n2)
monthspan(n1, n2)
yearspan(n1, n2)
```

### Incrementing
```basic
incday(n, count)
inchour(n, count)
incminute(n, count)
incsecond(n, count)
incmillisecond(n, count)
incweek(n, count)
incyear(n, count)
```

### Calendar Information
```basic
daysinamonth(year, month)  ' Days in specific month
daysinmonth(n)             ' Days in month of date
daysinayear(year)          ' Days in specific year
daysinyear(n)              ' Days in year of date
weeksinayear(year)         ' Weeks in specific year
weeksinyear(n)             ' Weeks in year of date
```

### Boolean Tests
```basic
isam(n)              ' Is morning? (1=yes, 0=no)
ispm(n)              ' Is afternoon/evening?
isinleapyear(n)      ' Is in leap year?
istoday(n)           ' Is today?
issameday(n1, n2)    ' Are same day?
```

---

*End of DateTimeLib Documentation*
