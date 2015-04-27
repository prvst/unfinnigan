This is presently an unexplored corner of the Finnigan file format. I do not know of the tools that can create or read these files, and I am not aware of anything important hiding in them -- at least as far as reading the scan data is concerned -- with one exception: I see the "Scan Event Details" section in the analyzer method mention Activation Type (=CID), which I was unable to locate in ScanEventPreamble, where I believe it is hiding.

Because some method nodes contain plain text, it is fair to assume that these nodes are the human-readable versions of the data in their sibling binary-encoded nodes. In theory, I could parse these texts to obtain the missing data, but that seems to require more effort that it is probably worth.

Here is one example:

  * Command:
```
uf-meth 20070522_NH_Orbi2_HelaEpo_05.RAW -p LTQ/Text
```

  * Output:
```
Creator: ocx
Last modified: 22.May.07 by ocx

MS Run Time (min): 140.00

Sequence override of method parameters not enabled.

Divert Valve:  not used during run

Contact Closure:  in use during run

                      Contact Time (min)  Valve State
                      ==================  ===========
                              0.00         Open

Syringe Pump:  not used during run

MS Detector Settings:

Real-time modifications to method enabled

Stepped collision energy not enabled

Additional Microscans:  MS2   0
                        MS3   0
                        MS4   0
                        MS5   0
                        MS6   0
                        MS7   0
                        MS8   0
                        MS9   0
                        MS10  0

Segment 1 Information

Duration (min):        140.00
Number of Scan Events: 6
Tune Method:           20070522_NanoESI

Scan Event Details:
 1:  FTMS + p norm res=60000 o(300.0-1700.0)
 2:  ITMS + c norm Dep Wideband MS/MS Most intense ion from (1).
       Activation Type:         CID
       Min. Signal Required:    1000.0
       Isolation Width:         2.00
       Normalized Coll. Energy: 35.0
       Default Charge State:    2
       Activation Q:            0.250
       Activation Time:         30.000
 3:  ITMS + c norm Dep Wideband MS/MS 2nd most intense ion from (1).
       Activation Type:         CID
       Min. Signal Required:    1000.0
       Isolation Width:         2.00
       Normalized Coll. Energy: 35.0
       Default Charge State:    2
       Activation Q:            0.250
       Activation Time:         30.000
 4:  ITMS + c norm Dep Wideband MS/MS 3rd most intense ion from (1).
       Activation Type:         CID
       Min. Signal Required:    1000.0
       Isolation Width:         2.00
       Normalized Coll. Energy: 35.0
       Default Charge State:    2
       Activation Q:            0.250
       Activation Time:         30.000
 5:  ITMS + c norm Dep Wideband MS/MS 4th most intense ion from (1).
       Activation Type:         CID
       Min. Signal Required:    1000.0
       Isolation Width:         2.00
       Normalized Coll. Energy: 35.0
       Default Charge State:    2
       Activation Q:            0.250
       Activation Time:         30.000
 6:  ITMS + c norm Dep Wideband MS/MS 5th most intense ion from (1).
       Activation Type:         CID
       Min. Signal Required:    1000.0
       Isolation Width:         2.00
       Normalized Coll. Energy: 35.0
       Default Charge State:    2
       Activation Q:            0.250
       Activation Time:         30.000

Data Dependent Settings:
       Use separate polarity settings disabled
       Parent Mass List:            (none)
       Reject Mass List:            (none)
       Neutral Loss Mass List:      (none)
       Neutral loss in top:         3
       Most intense if no parent masses found enabled
       Add/subtract mass not enabled
       FT master scan preview mode enabled
       Charge state screening enabled
       Monoisotopic precursor selection enabled
       Non-peptide monoisotopic recognition not enabled
       Charge state rejection enabled
         Unassigned charge states : rejected
                   Charge state 1 : rejected
                   Charge state 2 : not rejected
                   Charge state 3 : not rejected
                   Charge states 4+ : not rejected
       Correlation is disabled


Global Data Dependent Settings:
       Use global parent and reject mass lists not enabled
       Exclude parent mass from data dependent selection enabled
       Exclusion mass width relative to mass
       Exclusion mass width relative to low (ppm):  15.0
       Exclusion mass width relative to high (ppm): 15.0
       Parent mass width by mass
       Parent mass width low:  0.50
       Parent mass width high: 0.50
       Reject mass width by mass
       Reject mass width low:  0.05
       Reject mass width high: 0.05
       Zoom/UltraZoom scan mass width by mass
       Zoom/UltraZoom scan mass width low:  5.00
       Zoom/UltraZoom scan mass width high: 5.00
       Neutral Loss candidates processed by decreasing intensity
       Neutral Loss mass width by mass
       Neutral Loss mass width low:  3.00
       Neutral Loss mass width high: 3.00
       MS mass range:  0.00-1000000.00
       MSn mass range by mass
       MSn mass range:  0.00-1000000.00
       Analog UV data dep. not enabled
       Dynamic exclusion enabled
              Repeat Count:         1
              Repeat Duration:      30.00
              Exclusion List Size:  500
              Exclusion Duration:   180.00
              Exclusion mass width relative to mass
              Exclusion mass width relative to low (ppm):  15.0
              Exclusion mass width relative to high (ppm): 15.0
                Expiration Count:   2
        Expiration S/N Threshold:   3.0
       Isotopic data dependence not enabled
       Mass Tags data dependence not enabled


Custom Data Dependent Settings:
       Not enabled
```