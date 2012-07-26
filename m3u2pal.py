
import sys

def file_split(f, delim='\r', bufsize=1024):
    prev = ''
    while True:
        s = f.read(bufsize)
        if not s:
            break
        split = s.split(delim)
        if len(split) > 1:
            yield prev + split[0]
            prev = split[-1]
            for x in split[1:-1]:
                yield x
        else:
            prev += s
    if prev:
        yield prev


filename = sys.argv[1]
mp3_filename = sys.argv[2]

pal_filename = filename.replace('.m3u','.pal')
pal = open(pal_filename, 'w')

beginning = [
    '; This script on execution will automatically add to the queue and fade to next, then trigger the meta data to start outputting',
    '; It will even handle the case of SAM not playing anything at all.',
    'PAL.LockExecution;',
    'var updSong : TSongInfo;',
    'var ip : TPlayer;',
    'updSong := TSongInfo.Create;',
    '; JUST CHANGE THIS TO POINT TO THE SHOW FILE',
    "Queue.AddFile('%s',ipTop);" % mp3_filename,
    'If ActivePlayer = nil then',
    'begin',
    '   { If the active player is nil nothing is playing. So empty all decks }',
    'DeckA.Eject;',
    'DeckB.Eject;',
    'ip := DeckA;',
    'end;',
    'If (ActivePlayer <> nil) and (ActivePlayer.Status = 0) then',
    'begin',
    '   { If music is playing, trigger a fade to the next track - first in queue.',
    'If the queued player is not nil eject it to force the next track to be from the queue }',
    'If QueuedPlayer <> nil then',
    'QueuedPlayer.Eject;',
    'ActivePlayer.FadeToNext();',
    'end',
    'else',
    'begin',
    '   { Nothing is playing, so ask the idle player to load up the next track from the queue }',
    'ip.Next();',
    'ip.Play();',
    'end;'
]

for line in beginning:
    pal.write('%s\n' % line)

with open(filename, 'r') as m3u:
    for line in file_split(m3u):
        if line.startswith('#EXTINF:'):
            line_list = line[8:].split(',')
            track_seconds = int(line_list[0])
            hours, remainder = divmod(track_seconds, 3600)
            minutes, seconds = divmod(remainder, 60)
            track_info = line_list[1].split(' - ')
            artist = track_info[0]
            title = track_info[1]
            pal.write("PAL.WaitForTime(T['+00:%s:%s']);\n" % (minutes, seconds))
            pal.write("updSong['title'] := '%s';\n" % title)
            pal.write("updSong['artist'] := '%s';\n" % artist)
            pal.write("Encoders.SongChange(updSong);\n")

pal.write("PAL.UnLockExecution;\n")
pal.close()
