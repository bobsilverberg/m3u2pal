
<cfset showfile = "testFile.mp3">
<cfset m3ufile = "C:\Users\trafferty.H2\Dropbox\CodebassRadio(webRat)\Processing Directive - Episode 10\episode_10.m3u">
<cfset PALname = "episode_10.PAL">
<cfset outputPAL2Directory = "C:\">
<cfset CRNL = CHR(10)>


<!--- Beginning of PAL file --->
<cfsavecontent variable="beginning">
; This script on execution will automatically add to the queue and fade to next, then trigger the meta data to start outputting
; It will even handle the case of SAM not playing anything at all.
PAL.LockExecution;
var updSong : TSongInfo;
var ip : TPlayer;
updSong := TSongInfo.Create;
; JUST CHANGE THIS TO POINT TO THE SHOW FILE
<cfoutput>Queue.AddFile('#showFile#',ipTop);</cfoutput>
If ActivePlayer = nil then
begin
   { If the active player is nill nothing is playing. So empty all decks }
   DeckA.Eject;
   DeckB.Eject;
   ip := DeckA;
end;
If (ActivePlayer <> nil) and (ActivePlayer.Status = 0) then
begin
   { If music is playing, trigger a fade to the next track - first in queue.
        If the queued player is not nil eject it to force the next track to be from the queue }
   If QueuedPlayer <> nil then
      QueuedPlayer.Eject;
   ActivePlayer.FadeToNext();
 end
else
begin
   { Nothing is playing, so ask the idle player to load up the next track from the queue }
   ip.Next();
   ip.Play();
end;
</cfsavecontent>
<!--- LOOP AROUND SONGS / END OF PAL FILE --->
<cfsavecontent variable="songs"><cfloop file="#m3ufile#" index="line"><cfif listFirst(line,':') EQ "##EXTINF"><cfset localline = replace(line,'##EXTINF:','','ALL')><cfset mp3info = { time = secsToTime(listFirst(localline,','),'s'), artist = listFirst(listLast(localline,','),'-'), title = listLast(listLast(localline,','),'-')}><cfoutput>
PAL.WaitForTime(T['+00:#trim(mp3info.time)#]);
updSong['title'] := '#trim(mp3info.title)#';
updSong['artist'] := '#trim(mp3info.artist)#';
Encoders.SongChange(updSong);#CRNL#</cfoutput></cfif></cfloop></cfsavecontent>

<!--- WRITE PAL FILE --->
<cfset fileData = beginning & trim(songs)>
<cffile action="write" file="#outputPAL2Directory#\#PALname#" output="#fileData#"> 






<!--- UDF --->
	<cfscript>
	// Credit: Kevin Miller - http://cflib.org/index.cfm?event=page.udfbyid&udfid=1161
	// Modified by webRat
	function secsToTime(seconds,format) {
	    var output = "";
	    var timeval_w = "";
	    var remaining_time = "";
	    var t_w = "";
	    var timeval_d = "";
	    var t_d = "";
	    var timeval_h = "";
	    var t_h = "";
	    var timeval_m = "";
	    var t_m = "";
	    var timeval_s = "";
	    var t_s = "";
	    var f_w = "";
	    var f_d = "";
	    var f_h = "";
	    var f_m = "";
	    var f_s = "";
	
	    // handle format syntax
	    arguments.format = 's';
	    remaining_time = arguments.seconds;
	  	 // hours
	    timeval_h = remaining_time/3600;
	        if(timeval_h gte 1) {
	                timeval_h = int(timeval_h); t_h = "#timeval_h#";
	                remaining_time = remaining_time - (timeval_h * 3600); }
	        else {
	                t_h = ""; }
	    // minutes
	        timeval_m = remaining_time/60;
	            if(timeval_m gte 1) {
	                timeval_m = int(timeval_m); t_m = "#timeval_m#";
	                remaining_time = remaining_time - (timeval_m * 60); }
	            else {
	                t_m = ""; }
	    // seconds
	        timeval_s = remaining_time; 
	            if(timeval_s gt 0) {
	                t_s = "#round(timeval_s)#"; }
	            else {
	                t_s = ""; }
	
	    switch (arguments.format) { 
	        case "s":
	            f_w = ""; f_d = ""; f_h = "0"; f_m = ":"; f_s = "";
	            break;
	    }
	
	    if(val(t_h)) {
	        output = output & "#t_h##f_h#";
	    }
	    if(val(t_m)) {
	        output = output & "#t_m##f_m#";
	    }
	    if(val(t_s)) {
	        output = output & "#t_s##f_s#";
	    }
	    return output;
	}
	</cfscript>