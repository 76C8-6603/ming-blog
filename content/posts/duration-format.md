---

    title: "Duration format PnDTnHnMn.nS ISO-8601"
    date: 2021-02-20
    tags: ["protocol"]

---

The ASCII letter "P" is next in upper or lower case. There are then four sections, each consisting of a number and a suffix.   
The sections have suffixes in ASCII of "D", "H", "M" and "S" for days, hours, minutes and seconds, accepted in upper or lower case. The suffixes must occur in order.   
The ASCII letter "T" must occur before the first occurrence, if any, of an hour, minute or second section. At least one of the four sections must be present, and if "T" is present there must be at least one section after the "T". The number part of each section must consist of one or more ASCII digits. The number may be prefixed by the ASCII negative or positive symbol. The number of days, hours and minutes must parse to an long. The number of seconds must parse to an long with optional fraction. The decimal point may be either a dot or a comma. The fractional part may have from zero to 9 digits.  

Examples:
```
          "PT20.345S" -- parses as "20.345 seconds"
          "PT15M"     -- parses as "15 minutes" (where a minute is 60 seconds)
          "PT10H"     -- parses as "10 hours" (where an hour is 3600 seconds)
          "P2D"       -- parses as "2 days" (where a day is 24 hours or 86400 seconds)
          "P2DT3H4M"  -- parses as "2 days, 3 hours and 4 minutes"
```