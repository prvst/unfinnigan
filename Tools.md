## General exploration tools ##

The following tools can be useful in the exploration of new file formats and unknown format variants:

<table cellpadding='5' border='0' cellspacing='0'>
<blockquote><tr>
<blockquote><td><a href='http://bitbucket.org/haypo/hachoir/wiki/hachoir-core'>Hachoir</a></td>
<td>a digital forensics framework</td>
</blockquote></tr>
<tr>
<blockquote><td></td>
<td>keys in <b>hachoir-urwid</b>:<br>
<blockquote><ul>
<blockquote><li><b>a</b>: absolute/relative addresses</li>
<li><b>b</b>: binary/decimal addresses</li>
<li><b>d</b>: show description</li>
<li><b>h</b>: hex-dump strings; size in bytes/megabytes</li>
<li><b>s</b>: show size</li>
<li><b>t</b>: show type</li>
<li><b>v</b>: show value</li>
<li><b>q</b>: quit</li>
</blockquote></ul>
</blockquote></blockquote><blockquote></td>
</blockquote></tr>
<tr>
<blockquote><td><a href='HachoirParser.md'>finnigan.py</a></td>
<td>an Hachoir parser for Finnigan files, recently updated to read the 64-bit raw files (<b>v.64</b>)</td>
</blockquote></tr>
<tr>
<blockquote><td><a href='UnixStrings.md'>strings</a></td>
<td>unix text finder</td>
</blockquote></tr>
<tr>
<blockquote><td><a href='Iconv.md'>iconv</a></td>
<td>character encoding converter</td>
</blockquote></tr>
<tr>
<blockquote><td><a href='Hexdump.md'>hexdump</a></td>
<td>BSD hexadecimal dump utility</td>
</blockquote></tr>
<tr>
<blockquote><td><a href='bgrep.md'>bgrep</a></td>
<td>Binary string search</td>
</blockquote></tr>
</table></blockquote>

## Unfinigan (uf-) tools ##

### Query tools ###
These tools extract data from the Finnigan files of known format versions. They are listed roughly in the order in which the structures they read occur in the data file.

<table cellpadding='5' border='0' cellspacing='0'>
<blockquote><tr>
<blockquote><td><a href='UnfinniganHeader.md'>uf-header</a></td>
<td>read the <a href='FileHeader.md'>FileHeader</a> structure</td>
</blockquote></tr>
<tr>
<blockquote><td><a href='UnfinniganSeqRow.md'>uf-seqrow</a></td>
<td>read the SeqRow structure (Sequence Table Row)</td>
</blockquote></tr>
<tr>
<blockquote><td><a href='UnfinniganASInfo.md'>uf-asinfo</a></td>
<td>read the ASInfo structure (autosampler info)</td>
</blockquote></tr>
<tr>
<blockquote><td><a href='UnfinniganRawFileInfo.md'>uf-rfi</a></td>
<td>read RawFileInfo, the top-level index structure</td>
</blockquote></tr>
<tr>
<blockquote><td><a href='UnfinniganMethodFile.md'>uf-meth</a></td>
<td>unravel the embedded MethodFile</td>
</blockquote></tr>
<tr>
<blockquote><td><a href='UnfinniganScan.md'>uf-scan</a></td>
<td>examine the scan profile and peak data in a single MS scan</td>
</blockquote></tr>
<tr>
<blockquote><td><a href='UnfinniganScanLight.md'>uf-scan-light</a></td>
<td>list the profile or centroids in a single MS scan</td>
</blockquote></tr>
<tr>
<blockquote><td><a href='UnfinniganRunHeader.md'>uf-runheader</a></td>
<td>read RunHeader, the secondary index structure</td>
</blockquote></tr>
<blockquote><tr>
<blockquote><td><a href='UnfinniganInstID.md'>uf-instrument</a></td>
<td>read the instrument IDs (the InstID structure)</td>
</blockquote></blockquote></tr>
<tr>
<blockquote><td><a href='UnfinniganLog.md'>uf-log</a></td>
<td>list or dump the InstrumentLog  stream</td>
</blockquote></tr>
<tr>
<blockquote><td><a href='UnfinniganError.md'>uf-error</a></td>
<td>list the error log (a steam of <a href='Error.md'>Error</a> structures)</td>
</blockquote></tr>
<tr>
<blockquote><td><a href='UnfinniganSegments.md'>uf-segments</a></td>
<td>dump the ScanEventTemplate structures in the order of segment hierarchy </td>
</blockquote></tr>
<tr>
<blockquote><td><a href='UnfinniganScanParameters.md'>uf-params</a></td>
<td>print or dump the ScanParameters stream</td>
</blockquote></tr>
<tr>
<blockquote><td><a href='UnfinniganTuneFile.md'>uf-tune</a></td>
<td>print or dump the TuneFile structure</td>
</blockquote></tr>
<tr>
<blockquote><td><a href='UnfinniganIndex.md'>uf-index</a></td>
<td>read the stream of ScanIndexEntry records</td>
</blockquote></tr>
<tr>
<blockquote><td><a href='UnfinniganTrailer.md'>uf-trailer</a></td>
<td>read the stream of ScanEvent records</td>
</blockquote></tr>
</table></blockquote>

### Conversion tools ###
The following are the conversion tools, transcoding the entire raw files into alternative representations.

<table cellpadding='5' border='0' cellspacing='0'>
<blockquote><tr>
<blockquote><td><a href='UnfinniganMzXML.md'>uf-mzxml</a></td>
<td>convert a raw file to mzXML</td>
</blockquote></tr>
<tr>
<blockquote><td><a href='UnfinniganMzML.md'>uf-mzml</a></td>
<td>convert a raw file to mzML</td>
</blockquote></tr>
<tr>
<blockquote><td><a href='MzXMLUnpack.md'>mzxml-unpack</a></td>
<td>unpack the base64-encoded scan data in mzXML or mzML files</td>
</blockquote></tr>
<tr>
<blockquote><td><a href='MzXMLScan.md'>mzxml-scan</a></td>
<td>decode a single scan from an mzXML or mzML file</td>
</blockquote></tr>
</table></blockquote>


All tools contain their own POD sections. To read the documentation for a tool, use

```
  man <tool>
  perldoc <tool>
```

### Odd recipes ###

  * I need to assemble data from different parts of mzXML files to check which conversion software calculates incorrect SHA1 sums for the original data file. This command line generates a table listing the base name of the raw file (derived from the mzXML file name), the sum, and the software version:
```
find -name "*mzXML" | xargs -i bash -c 'basename `grep -lm 1 fileSha {}`; grep -m 1 fileSha {}; grep -m 1 conversion {}; ' | perl -npe 's/.mzXML\n/\t/m; s/(<parentFile*+)?[^\n+]+fileSha1="([^"]+)".*\n/$2\t/gm; s/<software.*conversion"\s*//; s/ +name=/name=/; s% */>%%' > sha1.conv.tab
```

  * This command applies `shasum` to all raw files found in the current directory:
```
(find -type f -name "*.raw"; find -type f -name "*.RAW") | xargs -i bash -c 'basename {}; shasum {} | cut -d\  -f1' | perl -npe 's/.(raw|RAW)\n/\t/m'
```

  * When I load the tables generated by the above two commands into a database, I can then compare the results with:
```
SELECT s1.file, s1.digest, s2.digest, s1.digest = s2.digest AS match, s1.software FROM sha1conv s1, sha1real s2 WHERE s1.file = s2.file;
```