[LIB.GENERAL.PRO]
[Required : LIB.NULL.DEF]
[Required : LIB.GENERAL.DEF]

[
Summary of Procedures (not everything is documented):

 lib12HourTime - converts time to 12 hour format
  args: libTime <number>
  ret:  libChar <character>
  
 libNumLen - calculates the length of a number if it were converted to character
  args: libNumber <number>
  ret:  libLength <number>
  
 libRemoveLeadChrs - removes leading specified characters from a character value
  args: libRemoveChar <chracter, default=" ", overrides are reset>
        libChar <character>
  ret:  libChar <character>
  
 libRemoveEndChrs - removes ending specified characters from a character value,
                   handles values ending with spaces
  args: libRemoveChar <chracter, default=" ">
        libChar <character>
  ret:  libChar <character>
  
 libChrMoney - converts money value to character, variable format
  args: libMoney <money>
        libFormat <character, default="#,###,###,##9.99", overrides are reset>
  ret:  libChar <character>
  
 libChrRate - converts rate value to character, variable format
  args: libRate <rate>
        libFormat <character, default="##9.999", overrides are reset>
  ret:  libChar <character>
  
 libChrNumber - converts number value to character, variable format
  args: libNumber <number>
        libFormat <character, default="##########9", overrides are reset>
  ret:  libChar <character>
  
 libGetMonthChr - Returns name of month for any given date
  args: libDate
  ret : libChar
  
 libGetMonthCount - calculates the number of months between two dates.
  args: libDate, (libDateEnd)
  ret : libNumber
  
 libChrIsNumeric
  args: libChar
  ret : libFlag
  
 libChrIsAlpha
  args: libChar
  ret : libFlag
  
 libChrIsAlphaNumeric
  args: libChar
  ret : libFlag
  
 libAdjMinutes
  args: libDate, libTime, libNumber (offset)
  ret : libDate, libTime
  
 libDueDateAdvance
  args: libDDAdvDirection   (direction, use -1 to go backwards)
        libDDAdvFreq        (frequency code)
        libDDAdvStartDate   (starting date, procedure does nothing if this isn't defined)
        libDDAdvDay1        (day 1, if used)
        libDDAdvDay2        (day 2, if used)
  ret:
        libDate
  
]


PROCEDURE lib12HourTime
[Prints time in 12hr AM/PM format.  Requires libTime be defined as NUMBER]
 libChar="" 
 if HOUR(libTime)<13 then do
  if HOUR(libTime) < 1 then libChar="12"
  else libChar=FORMAT("#9",HOUR(libTime))
 end
  else libChar=FORMAT("#9",(HOUR(libTime)-12))
 libChar=libChar+":"
 libChar=libChar+FORMAT("99",MINUTE(libTime))
 if HOUR(libTime)<12 then libChar=libChar+" AM"
 else libChar=libChar+" PM"
END

PROCEDURE libNumLen
[gives the length of a number. Uses libNumber to create the value of libLength]
 libLength=0
 libChar=FORMAT("#########9",libNumber)
 call libRemoveLeadChrs
 libLength=LENGTH(libChar)
END


PROCEDURE libRemoveLeadChrs         [ Removes leading characters from a string. ]
 if libRemoveChar="" then libRemoveChar=" "
 libLength=LENGTH(libChar)
 while (libLength>1 and 
        SEGMENT(libChar,1,1)=libRemoveChar) do
  libChar=SEGMENT(libChar,2,libLength)
 end
 if libChar=libRemoveChar then libChar=""
 libRemoveChar=""
END

PROCEDURE libRemoveEndChrs
 if libRemoveChar="" then libRemoveChar=" "
 if libRemoveChar<>" " then do
  libLength=LENGTH(libChar)
  while (libLength>1 and
         SEGMENT(libChar,libLength,libLength)=libRemoveChar) do
   libChar=SEGMENT(libChar,1,libLength-1)
  end
  if libChar=libRemoveChar then libChar=""
 end
 else if libRemoveChar=" " then do
  libLength=LENGTH(libChar)
  if libLength=0 then do
   libChar=""
  end
  else do
   libChar=SEGMENT(libChar,1,libLength)
  end
 end
 libRemoveChar=""
END

PROCEDURE libChrRate
 if libFormat=NULLCHR then libFormat="##9.999"
 libChar=FORMAT(libFormat,libRate)
 call libRemoveLeadChrs
 libFormat=NULLCHR
END

PROCEDURE libChrDivRate
 libFormat="##9.999"
 libChar=FORMAT(libFormat,libRate)
 libNumber=VALUE(SEGMENT(libChar,1,6))
 if VALUE(SEGMENT(libChar,7,7))>=5 then do
  libNumber=libNumber+1
 end
 libFormat="##9.99"
 libChar=FORMAT(libFormat,libNumber)
 call libRemoveLeadChrs
 libFormat=NULLCHR
END

PROCEDURE libChrDate
 if libFormat=NULLCHR then libFormat="99/99/9999"
 libChar=FORMAT(libFormat,libDate)
 libFormat=NULLCHR
END

PROCEDURE libAltChrDate
 libChar=FORMAT("9999",FULLYEAR(libDate))
 libChar=libChar+FORMAT("99",MONTH(libDate))
 libChar=libChar+FORMAT("99",DAY(libDate))
END

PROCEDURE libChrTime
 if libFormat=NULLCHR then libFormat="99:99"
 libChar=FORMAT(libFormat,libTime)
 libFormat=NULLCHR
END

PROCEDURE libUnixTimeStamp
 call libAltChrDate
 libBuff=libChar
 call libChrTime
 libChar=libBuff+" "+libChar
END

PROCEDURE libChrNumber
 if libFormat=NULLCHR then libFormat="##########9"
 libChar=FORMAT(libFormat,libNumber)
 call libRemoveLeadChrs
 if libNumber<0 then libChar="-"+libChar
 libFormat=NULLCHR
END

PROCEDURE libChrMoney
 if libFormat=NULLCHR then libFormat="#,###,###,##9.99"
 libChar=FORMAT(libFormat,libMoney)
 call libRemoveLeadChrs
 if libMoney<$0.00 then libChar="-"+libChar
 libFormat=NULLCHR
END

PROCEDURE libGetFlags  [arg: libNumber  ret: libFlagList]
 libChar=FORMAT("9999999999",libNumber)
 for libI=1 to 10 do
  if VALUE(SEGMENT(libChar,libI,libI))>0 then libFlagList(11-libI)=1
  else libFlagList(11-libI)=0
 end
END

PROCEDURE libSetFlags  [arg: libFlagList  ret: libNumber]
 libChar=""
 for libI=1 to 10 do
  if libFlagList(11-libI)>1 then libFlagList(11-libI)=1
  if libFlagList(11-libI)<0 then libFlagList(11-libI)=0
  libChar=libChar+FORMAT("9",libFlagList(11-libI))
  libNumber=VALUE(libChar)
 end
END

PROCEDURE libParseLineInput [arg: libListDelimiter,libLineInput ret: libReturnList,libIndex ]
 for libIndex=1 to 50 do
  libReturnList(libIndex)=""
 end
 libIndex=0
 libFlag=false
 if libListDelimiter="" then libListDelimiter=","
 libListDelLen=LENGTH(libListDelimiter)
 while libFlag=false and libLineInput<>"" do
  libPoint=charactersearch(libLineInput,libListDelimiter)
  if libPoint=0 then do
   libIndex=libIndex+1
   libReturnList(libIndex)=libLineInput
   libFlag=true
  end
  else do
   libIndex=libIndex+1
   if libPoint>1 then libReturnList(libIndex)=segment(libLineInput,1,libPoint-1)
   else libReturnList(libIndex)=""
   if libIndex>=50 then libFlag=true
   libLineInput=segment(libLineInput,libPoint+libListDelLen,length(libLineInput))
  end
 end
END


PROCEDURE libDecToHex
 libHex=""
 libHexTab(0)="0"
 libHexTab(1)="1"
 libHexTab(2)="2"
 libHexTab(3)="3"
 libHexTab(4)="4"
 libHexTab(5)="5"
 libHexTab(6)="6"
 libHexTab(7)="7"
 libHexTab(8)="8"
 libHexTab(9)="9"
 libHexTab(10)="A"
 libHexTab(11)="B"
 libHexTab(12)="C"
 libHexTab(13)="D"
 libHexTab(14)="E"
 libHexTab(15)="F"
 libI=FLOOR(NUMBER(libNumber/16))
 libHex=libHexTab(libI)
 libI=MOD(libNumber,16)
 libHex=libHex+libHexTab(libI)
END

PROCEDURE libHexToDec
 libNumber=0
 libHex=UPPERCASE(libHex)
 libHexTab(0)="0"
 libHexTab(1)="1"
 libHexTab(2)="2"
 libHexTab(3)="3"
 libHexTab(4)="4"
 libHexTab(5)="5"
 libHexTab(6)="6"
 libHexTab(7)="7"
 libHexTab(8)="8"
 libHexTab(9)="9"
 libHexTab(10)="A"
 libHexTab(11)="B"
 libHexTab(12)="C"
 libHexTab(13)="D"
 libHexTab(14)="E"
 libHexTab(15)="F"
 libLength=LENGTH(libHex)
 for libPoint=libLength to 1 by -1 do
  for libI=0 to 15 do
   if libHexTab(libI)=SEGMENT(libHex,libPoint,libPoint) then do
    libNumber=libNumber+(libI*PWR(16,libLength-libPoint))
   end
  end
 end
END 

PROCEDURE libNumberChr
 libBuff=""
 libI=0
 while LENGTH(libBuff)<10 and libI<LENGTH(libChar) do
  libI=libI+1
  if CHARACTERSEARCH("0123456789",SEGMENT(libChar,libI,libI))<>0 then do
   libBuff=libBuff+SEGMENT(libChar,libI,libI)
  end
 end
 libNumber=VALUE(libBuff)
END

PROCEDURE libPadFrontChar
 if libPadChar=NULLCHR then libPadChar=" "
 libPoint=LENGTH(libChar)
 if libLength<>0 and libLength-libPoint>0 then do
  libChar=repeatchr(libPadChar,libLength-libPoint)+libChar
 end
 libLength=0
END

PROCEDURE libGetMonthChr
 libMonthChar(00)=""
 libMonthChar(01)="January"
 libMonthChar(02)="February"
 libMonthChar(03)="March"
 libMonthChar(04)="April"
 libMonthChar(05)="May"
 libMonthChar(06)="June"
 libMonthChar(07)="July"
 libMonthChar(08)="August"
 libMonthChar(09)="September"
 libMonthChar(10)="October"
 libMonthChar(11)="November"
 libMonthChar(12)="December"

 libChar=libMonthChar(MONTH(libDate))
END

PROCEDURE libLongDate
 if MONTH(libDate)=1 then libChar="January "
 if MONTH(libDate)=2 then libChar="February "
 if MONTH(libDate)=3 then libChar="March "
 if MONTH(libDate)=4 then libChar="April "
 if MONTH(libDate)=5 then libChar="May "
 if MONTH(libDate)=6 then libChar="June "
 if MONTH(libDate)=7 then libChar="July "
 if MONTH(libDate)=8 then libChar="August "
 if MONTH(libDate)=9 then libChar="September "
 if MONTH(libDate)=10 then libChar="October "
 if MONTH(libDate)=11 then libChar="November "
 if MONTH(libDate)=12 then libChar="December "

 if DAY(libDate)<10 then libChar=libChar+FORMAT("9",DAY(libDate))+", "
 else libChar=libChar+FORMAT("99",DAY(libDate))+", "
 libChar=libChar+FORMAT("9999",FULLYEAR(libDate))
END

PROCEDURE libChrReplace
 if libChar<>NULLCHR and libSearch<>NULLCHR then do
  libPoint=CHARACTERSEARCH(libChar,libSearch)
  while libPoint<>0 do
   libLength=LENGTH(libChar)
   libBuff=SEGMENT(libChar,libPoint+LENGTH(libSearch),libLength)
   libChar=SEGMENT(libChar,1,libPoint-1)+libReplace+libBuff
   libPoint=CHARACTERSEARCH(libChar,libSearch)
  end
  libSearch=NULLCHR
 end
END

PROCEDURE libMonthToNumber
 if libChar=NULLCHR then libNumber=0
 else if LOWERCASE(libChar)="january" then libNumber=1
 else if LOWERCASE(libChar)="february" then libNumber=2
 else if LOWERCASE(libChar)="march" then libNumber=3
 else if LOWERCASE(libChar)="april" then libNumber=4
 else if LOWERCASE(libChar)="may" then libNumber=5
 else if LOWERCASE(libChar)="june" then libNumber=6
 else if LOWERCASE(libChar)="july" then libNumber=7
 else if LOWERCASE(libChar)="august" then libNumber=8
 else if LOWERCASE(libChar)="september" then libNumber=9
 else if LOWERCASE(libChar)="october" then libNumber=10
 else if LOWERCASE(libChar)="november" then libNumber=11
 else if LOWERCASE(libChar)="december" then libNumber=12
END

PROCEDURE libNumberToBinary
 for libI=0 to 32 do
  libBinary(libI)=0
 end
 libI=0
 if libNumber<0 then do
  libBinary(31)=1
  libNumber=ABS(libNumber)
 end
 while libNumber>0 and libI<31 do
  libBinary(libI)=MOD(libNumber,2)
  libNumber=FLOOR(libNumber/2)
  libI=libI+1
 end
END

PROCEDURE libBinaryToNumber
 libNumber=0
 for libI=30 to 0 by -1 do
  libNumber=libNumber*2+libBinary(libI)
[  libBinary(libI)=0 ]
 end
 if libBinary(31)=1 then do
  libNumber=-1*libNumber
[  libBinary(31)=0 ]
 end
END

PROCEDURE libDaysToMonths
[
  args: libDate   ~ starting date
        libNumber ~ days
        libFlag   ~ suppress month rounding                    
        
  internal:  libIndex  ~ months
  
  ret:  libIndex ~ months
        libPoint ~ remainder days
]
 libIndex=0
 libPoint=0
 if libNumber>0 then do
  if libDate=NULLDATE then libDate=SYSTEMDATE 
  
  while (DATEOFFSET(libDate,libIndex,0)<libDate+libNumber) do
    libIndex=libIndex+1
  end
  
  if (DATEOFFSET(libDate,libIndex,0)>libDate+libNumber) then do
   libIndex=libIndex-1
   libPoint=(libDate+libNumber)-DATEOFFSET(libDate,libIndex,0)
   if libPoint>14 and libFlag=false then do
    libIndex=libIndex+1
   end
  end
  
 end
END

PROCEDURE libDueDateAdvance
[
 This procedure calculates a date based on the standard fileds in a LOAN or EFT record. 
  
 This supports ALL frequency codes.
   
 It will advance the date once, in whichever direction was specified.
 To move the date more than once, assign result (libDate) to start date (libDueDateAdvance) and call it again. 
 
 arg:
  libDDAdvDirection   (direction, use -1 to go backwards)
  libDDAdvFreq        (frequency code)
  libDDAdvStartDate   (starting date, procedure does nothing if this isn't defined)
  libDDAdvDay1        (day 1, if used)
  libDDAdvDay2        (day 2, if used)
 ret:
  libDate
  
 internal: 
  libNumber
]

 if libDDAdvDirection>=0 then libDDAdvDirection=1
 else if libDDAdvDirection<0 then libDDAdvDirection=-1
 
 if libDDAdvStartDate<>NULLDATE then do
  if libDDAdvFreq=0 then do             [one time]
   libDate=libDDAdvStartDate
  end
  else if libDDAdvFreq=1 then do        [annual]
   libDate=DATEOFFSET(libDDAdvStartDate,libDDAdvDirection*12,libDDAdvDay1)
  end
  else if libDDAdvFreq=2 then do        [semiannual]
   libDate=DATEOFFSET(libDDAdvStartDate,libDDAdvDirection*6,libDDAdvDay1)
  end
  else if libDDAdvFreq=3 then do        [quarterly]
   libDate=DATEOFFSET(libDDAdvStartDate,libDDAdvDirection*3,libDDAdvDay1)
  end
  else if libDDAdvFreq=4 then do        [monthly]
   libDate=DATEOFFSET(libDDAdvStartDate,libDDAdvDirection*1,libDDAdvDay1)
  end
  else if libDDAdvFreq=5 then do        [semimonthly]
   if libDDAdvDay1>libDDAdvDay2 then do
    libNumber=libDDAdvDay2
    libDDAdvDay2=libDDAdvDay1
    libDDAdvDay1=libNumber
   end
   if DAY(libDDAdvStartDate)>=libDDAdvDay1 and
      DAY(libDDAdvStartDate)<libDDAdvDay2 and
      DATEOFFSET(libDDAdvStartDate,0,31)<>libDDAdvStartDate then do
    if libDDAdvDirection>=0 then do
     libDate=DATEOFFSET(libDDAdvStartDate,0,libDDAdvDay2)
    end
    else do
     libDate=DATEOFFSET(libDDAdvStartDate,-1,libDDAdvDay2)
    end
   end
   else do
    if libDDAdvDirection>=0 then do
     libDate=DATEOFFSET(libDDAdvStartDate,1,libDDAdvDay1)
    end
    else do
     libDate=DATEOFFSET(libDDAdvStartDate,0,libDDAdvDay1)
    end
   end
  end
  else if libDDAdvFreq=6 then do       [biweekly, skip first if 3 in month]
   libDate=libDDAdvStartDate+(libDDAdvDirection*14)
   if MONTH(libDate)=MONTH(libDate+28) then do
    libDate=libDDAdvStartDate+(libDDAdvDirection*28)
   end
  end
  else if libDDAdvFreq=7 then do       [biweekly, skip last if 3 in month]
   libDate=libDDAdvStartDate+(libDDAdvDirection*14)
   if MONTH(libDate)=MONTH(libDate-28) then do
    libDate=libDDAdvStartDate+(libDDAdvDirection*28)
   end
  end
  else if libDDAdvFreq=8 then do       [biweekly]
   libDate=libDDAdvStartDate+(libDDAdvDirection*14)
  end
  else if libDDAdvFreq=9 then do       [weekly]
   libDate=libDDAdvStartDate+(libDDAdvDirection*7)
  end
  else if libDDAdvFreq=10 then do      [immediate]
   libDate=SYSTEMDATE
  end
  else if libDDAdvFreq=11 then do      [weekly, skip first if 5 in month]
   libDate=libDDAdvStartDate+(libDDAdvDirection*7)
   if MONTH(libDate)=MONTH(libDate+28) then do
    libDate=libDDAdvStartDate+(libDDAdvDirection*14)
   end
  end
  else if libDDAdvFreq=12 then do      [weekly, skip last if 5 in month]
   libDate=libDDAdvStartDate+(libDDAdvDirection*7)
   if MONTH(libDate)=MONTH(libDate-28) then do
    libDate=libDDAdvStartDate+(libDDAdvDirection*14)
   end
  end
  else if libDDAdvFreq=13 then do      [bimonthly]
   libDate=DATEOFFSET(libDDAdvStartDate,libDDAdvDirection*2,libDDAdvDay1)
  end
 end
END

PROCEDURE libGetMonthCount  [arg: libDate, (libDateEnd)  ret: libNumber]
 libNumber=0
 if libDateEnd=NULLDATE then libDateEnd=SYSTEMDATE
 
 if libDate<>NULLDATE then do
  libPoint=-1
  if libDate>libDateEnd then libPoint=1
  
  libI=0
  libNumber=-1
  while libNumber=-1 do
   if libDate>=DATEOFFSET(libDateEnd,libPoint*libI,1) and
      libDate<=DATEOFFSET(libDateEnd,libPoint*libI,31) then do
    libNumber=libI
   end
   libI=libI+1
  end
 end
END

PROCEDURE libChrIsNumeric [args: libChar  ret : libFlag]
 libFlag=false

 if libChar<>NULLCHR then do
  libFlag=true
  libLength=LENGTH(libChar)
  for libI=1 to libLength do
   if CHARACTERSEARCH("0123456789",SEGMENT(libChar,libI,libI))=0 then do
    libFlag=false
   end
  end
 end
END

PROCEDURE libChrIsAlpha [args: libChar  ret : libFlag]
 libFlag=false

 if libChar<>NULLCHR then do
  libFlag=true
  libLength=LENGTH(libChar)
  for libI=1 to libLength do
   if CHARACTERSEARCH("abcdefghijklmnopqrstuvwxyz",LOWERCASE(SEGMENT(libChar,libI,libI)))=0 then do
    libFlag=false
   end
  end
 end
END

PROCEDURE libChrIsAlphaNumeric [args: libChar  ret : libFlag]
 libFlag=false

 if libChar<>NULLCHR then do
  libFlag=true
  libLength=LENGTH(libChar)
  for libI=1 to libLength do
   if CHARACTERSEARCH("0123456789abcdefghijklmnopqrstuvwxyz",LOWERCASE(SEGMENT(libChar,libI,libI)))=0 then do
    libFlag=false
   end
  end
 end
END

PROCEDURE libAdjMinutes 
[  args: libDate, libTime, libNumber (offset) ]
[  ret : libDate, libTime ]

 if libDate=NULLDATE then libDate=SYSTEMDATE
 
 libI=VALUE(SEGMENT(FORMAT("9999",libTime),1,2))
 libPoint=VALUE(SEGMENT(FORMAT("9999",libTime),3,4))
 libIndex=((60*libI)+libPoint)+libNumber
 libLength=NUMBER(FLOOR(libIndex/3600))
 libIndex=MOD(libIndex,3600)
 libI=NUMBER(libIndex/60)
 libPoint=MOD(libIndex,60)
 libTime=VALUE(FORMAT("99",libI)+FORMAT("99",libPoint))
 libDate=libDate+libLength
END

